import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사용량 항목 유형
enum UsageType {
  sonioxSession,  // Soniox STT 세션 1회
  geminiCall,     // Gemini API 호출 1회
}

/// 사용자 티어
enum UserTier { test, free, premium }

/// 사용량 제한 및 추적 서비스
///
/// - test : 개발/테스트 — 하루 단위 엄격 제한 (API 비용 절감)
/// - free : 무료 사용자 — 월/일 단위 제한
/// - premium : 유료 사용자 — 제한 없음 (또는 매우 높은 한도)
///
/// 카운터는 SharedPreferences에 저장. 날짜/월이 바뀌면 자동 리셋.
class UsageLimitService {
  static UsageLimitService? _instance;
  static UsageLimitService get instance =>
      _instance ??= UsageLimitService._();
  UsageLimitService._();

  // ── 한도 상수 ─────────────────────────────────────

  static int _envInt(String key, int fallback) {
    final v = dotenv.env[key];
    return v != null ? int.tryParse(v) ?? fallback : fallback;
  }

  int get _sonioxTestDaily => _envInt('USAGE_SONIOX_TEST_DAILY', 3);
  int get _sonioxFreeMonthly => _envInt('USAGE_SONIOX_FREE_MONTHLY', 10);
  int get _geminiTestDaily => _envInt('USAGE_GEMINI_TEST_DAILY', 10);
  int get _geminiFreeDaily => _envInt('USAGE_GEMINI_FREE_DAILY', 20);
  int get _rewardSoniox => _envInt('USAGE_REWARD_SONIOX', 3);
  int get _rewardGemini => _envInt('USAGE_REWARD_GEMINI', 5);

  // ── 사용자 티어 ───────────────────────────────────

  UserTier _tier = UserTier.free;
  UserTier get tier => _tier;

  void setTier(UserTier t) {
    _tier = t;
    debugPrint('UsageLimitService: 티어 변경 → $t');
  }

  bool get isTest => dotenv.env['ENVIRONMENT'] == 'development';

  // ── 한도 조회 ─────────────────────────────────────

  /// 특정 UsageType의 최대 허용량 반환 (null = 무제한)
  int? limitFor(UsageType type) {
    if (_tier == UserTier.premium) return null;

    final useTest = isTest;
    switch (type) {
      case UsageType.sonioxSession:
        return useTest ? _sonioxTestDaily : _sonioxFreeMonthly;
      case UsageType.geminiCall:
        return useTest ? _geminiTestDaily : _geminiFreeDaily;
    }
  }

  // ── 사용량 카운터 ────────────────────────────────

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  String _key(UsageType type) {
    final period = _periodSuffix(type);
    return 'usage_${type.name}_$period';
  }

  /// 일/월 기준 suffix (날짜 바뀌면 카운터 자동 리셋용)
  String _periodSuffix(UsageType type) {
    final now = DateTime.now();
    // Soniox: test=일별, free=월별
    // Gemini: test/free 모두 일별
    if (type == UsageType.sonioxSession && !isTest) {
      return '${now.year}-${now.month}';
    }
    return '${now.year}-${now.month}-${now.day}';
  }

  /// 현재 사용량 조회
  Future<int> currentCount(UsageType type) async {
    final prefs = await _prefs;
    return prefs.getInt(_key(type)) ?? 0;
  }

  /// 사용량 증가 (사용 전에 canUse 체크 필수)
  Future<void> increment(UsageType type) async {
    final prefs = await _prefs;
    final key = _key(type);
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
    debugPrint('UsageLimitService: ${type.name} +1 → ${current + 1}');
  }

  /// 사용 가능 여부 확인
  Future<bool> canUse(UsageType type) async {
    if (_tier == UserTier.premium) return true;
    final limit = limitFor(type);
    if (limit == null) return true;
    final count = await currentCount(type);
    return count < limit;
  }

  /// 남은 사용량
  Future<int> remaining(UsageType type) async {
    if (_tier == UserTier.premium) return 9999;
    final limit = limitFor(type);
    if (limit == null) return 9999;
    final count = await currentCount(type);
    return (limit - count).clamp(0, limit);
  }

  // ── 보상형 광고 쿠폰 ─────────────────────────────

  /// 광고 시청 보상: 사용량 추가
  Future<void> applyReward(UsageType type) async {
    final prefs = await _prefs;
    final bonusKey = 'bonus_${type.name}_${_periodSuffix(type)}';
    final current = prefs.getInt(bonusKey) ?? 0;
    final add = type == UsageType.sonioxSession ? _rewardSoniox : _rewardGemini;
    await prefs.setInt(bonusKey, current + add);
    debugPrint('UsageLimitService: 보상 +$add → ${type.name}');
  }

  /// 보너스 사용량 포함한 최종 남은 량
  Future<int> remainingWithBonus(UsageType type) async {
    if (_tier == UserTier.premium) return 9999;
    final limit = limitFor(type);
    if (limit == null) return 9999;

    final prefs = await _prefs;
    final bonusKey = 'bonus_${type.name}_${_periodSuffix(type)}';
    final bonus = prefs.getInt(bonusKey) ?? 0;
    final count = await currentCount(type);
    return (limit + bonus - count).clamp(0, limit + bonus);
  }

  /// 보너스 포함 사용 가능 여부
  Future<bool> canUseWithBonus(UsageType type) async {
    if (_tier == UserTier.premium) return true;
    return await remainingWithBonus(type) > 0;
  }

  // ── 사용 정책 안내 ─────────────────────────────────

  static const _shownKey = 'usage_policy_shown_v1';

  /// AI 기능 최초 사용 전 정책 안내 다이얼로그를 표시.
  /// 이미 동의한 경우(SharedPreferences에 플래그 존재)는 표시하지 않음.
  /// 반환값: true = 계속 진행, false = 취소
  Future<bool> showPolicyIfNeeded(BuildContext context, UsageType type) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool(_shownKey) ?? false;
    if (alreadyShown) return true;

    // Build 사이클 외부에서 dialog 열기
    if (!context.mounted) return false;

    final agreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UsagePolicyDialog(type: type),
    );

    if (agreed == true) {
      await prefs.setBool(_shownKey, true);
      return true;
    }
    return false;
  }

  // ── 사용량 요약 (디버그/UI용) ─────────────────────

  Future<Map<String, dynamic>> summary() async {
    final sonioxRemain = await remainingWithBonus(UsageType.sonioxSession);
    final geminiRemain = await remainingWithBonus(UsageType.geminiCall);
    return {
      'tier': _tier.name,
      'isTest': isTest,
      'soniox': {
        'remaining': sonioxRemain,
        'limit': limitFor(UsageType.sonioxSession),
        'period': isTest ? '오늘' : '이번 달',
      },
      'gemini': {
        'remaining': geminiRemain,
        'limit': limitFor(UsageType.geminiCall),
        'period': '오늘',
      },
    };
  }
}

// ── 정책 안내 다이얼로그 ─────────────────────────────

class _UsagePolicyDialog extends StatelessWidget {
  const _UsagePolicyDialog({required this.type});
  final UsageType type;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isVoice = type == UsageType.sonioxSession;
    final title = isVoice ? '음성 AI 대화 안내' : 'AI 분석 안내';
    final icon = isVoice ? Icons.mic_rounded : Icons.psychology_outlined;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: cs.primary),
            const SizedBox(height: 12),
            Text(title,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _policyRow(cs, tt, Icons.info_outline_rounded,
                      'AI 기능은 외부 API(Gemini, Soniox)를 사용해 비용이 발생합니다.'),
                  const SizedBox(height: 8),
                  _policyRow(cs, tt, Icons.lock_clock_outlined,
                      '무료 버전: ${isVoice ? "음성 대화 월 10회" : "AI 분석 하루 20회"} 제한'),
                  const SizedBox(height: 8),
                  _policyRow(cs, tt, Icons.ondemand_video_rounded,
                      '광고 시청으로 추가 횟수를 얻을 수 있어요.'),
                  const SizedBox(height: 8),
                  _policyRow(cs, tt, Icons.science_outlined,
                      '테스트 환경에서는 하루 횟수가 더 낮게 설정됩니다.'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('확인했어요'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _policyRow(
      ColorScheme cs, TextTheme tt, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: tt.bodySmall
                  ?.copyWith(color: cs.onSurface.withOpacity(0.75))),
        ),
      ],
    );
  }
}
