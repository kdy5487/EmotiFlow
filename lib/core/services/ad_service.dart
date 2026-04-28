import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'usage_limit_service.dart';

/// AdMob 광고 서비스
///
/// ## 광고 배치 전략
/// - Banner : AI 페이지 하단, 일기 목록 하단
/// - Interstitial : 일기 저장 완료 후 (5번에 1번)
/// - Rewarded : 음성 AI 또는 Gemini 사용량 소진 시 "광고 보고 추가하기"
class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();
  AdService._();

  bool _initialized = false;

  // ── Ad Unit IDs ──────────────────────────────────

  String get _bannerUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_BANNER_ANDROID'] ??
          'ca-app-pub-3940256099942544/6300978111';
    }
    return dotenv.env['ADMOB_BANNER_IOS'] ??
        'ca-app-pub-3940256099942544/2934735716';
  }

  String get _rewardedUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_REWARDED_ANDROID'] ??
          'ca-app-pub-3940256099942544/5224354917';
    }
    return dotenv.env['ADMOB_REWARDED_IOS'] ??
        'ca-app-pub-3940256099942544/1712485313';
  }

  String get _interstitialUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_INTERSTITIAL_ANDROID'] ??
          'ca-app-pub-3940256099942544/1033173712';
    }
    return dotenv.env['ADMOB_INTERSTITIAL_IOS'] ??
        'ca-app-pub-3940256099942544/4411468910';
  }

  // ── 초기화 ────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    debugPrint('AdService: AdMob 초기화 완료');
  }

  // ── 배너 광고 ─────────────────────────────────────

  /// 배너 광고 생성 (AI 페이지, 일기 목록 하단)
  BannerAd createBanner({required void Function(Ad) onLoaded}) {
    return BannerAd(
      adUnitId: _bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('배너 광고 로드 실패: ${error.message}');
        },
      ),
    );
  }

  // ── 전면 광고 ─────────────────────────────────────

  InterstitialAd? _interstitialAd;
  int _diaryCount = 0; // 일기 저장 횟수 (5번에 1번 전면 광고)

  void preloadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('전면 광고 로드 완료');
        },
        onAdFailedToLoad: (error) {
          debugPrint('전면 광고 로드 실패: ${error.message}');
        },
      ),
    );
  }

  /// 일기 저장 시 호출 — 5회에 1번 전면 광고 표시
  void onDiarySaved() {
    _diaryCount++;
    if (_diaryCount % 5 == 0 && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      preloadInterstitial(); // 다음을 위해 미리 로드
    }
  }

  // ── 보상형 광고 ───────────────────────────────────

  RewardedAd? _rewardedAd;
  bool _isLoadingRewarded = false;

  Future<void> loadRewardedAd() async {
    if (_isLoadingRewarded || _rewardedAd != null) return;
    _isLoadingRewarded = true;

    RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingRewarded = false;
          debugPrint('보상형 광고 로드 완료');
        },
        onAdFailedToLoad: (error) {
          _isLoadingRewarded = false;
          debugPrint('보상형 광고 로드 실패: ${error.message}');
        },
      ),
    );
  }

  bool get isRewardedAdReady => _rewardedAd != null;

  /// 보상형 광고 표시
  /// [usageType] : 보상받을 사용량 유형
  /// [onRewarded] : 보상 지급 후 콜백
  Future<void> showRewardedAd({
    required UsageType usageType,
    required VoidCallback onRewarded,
    VoidCallback? onFailed,
  }) async {
    if (_rewardedAd == null) {
      debugPrint('보상형 광고 미준비');
      onFailed?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onFailed?.call();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) async {
        await UsageLimitService.instance.applyReward(usageType);
        debugPrint('보상 지급: ${usageType.name} +${reward.amount}');
        onRewarded();
      },
    );
  }
}
