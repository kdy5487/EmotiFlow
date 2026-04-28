import 'package:flutter/material.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/usage_limit_service.dart';

/// 보상형 광고 시청 → 사용량 추가 버튼
///
/// [usageType] : 어떤 사용량을 보상받을지
/// [onRewarded] : 보상 지급 완료 후 UI 갱신 콜백
class RewardAdButton extends StatefulWidget {
  const RewardAdButton({
    super.key,
    required this.usageType,
    required this.onRewarded,
    this.label,
  });

  final UsageType usageType;
  final VoidCallback onRewarded;
  final String? label;

  @override
  State<RewardAdButton> createState() => _RewardAdButtonState();
}

class _RewardAdButtonState extends State<RewardAdButton> {
  bool _loading = false;

  String get _defaultLabel {
    switch (widget.usageType) {
      case UsageType.sonioxSession:
        return '광고 보고 음성 AI 3회 추가';
      case UsageType.geminiCall:
        return '광고 보고 AI 분석 5회 추가';
    }
  }

  Future<void> _onTap() async {
    if (_loading) return;
    setState(() => _loading = true);

    if (!AdService.instance.isRewardedAdReady) {
      await AdService.instance.loadRewardedAd();
      // 광고 준비 대기 (최대 3초)
      for (var i = 0; i < 6; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (AdService.instance.isRewardedAdReady) break;
      }
    }

    if (!AdService.instance.isRewardedAdReady) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('광고를 불러오는 중입니다. 잠시 후 다시 시도해주세요.')),
        );
      }
      return;
    }

    await AdService.instance.showRewardedAd(
      usageType: widget.usageType,
      onRewarded: () {
        if (mounted) {
          widget.onRewarded();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.usageType == UsageType.sonioxSession
                    ? '음성 AI 3회가 추가됐습니다!'
                    : 'AI 분석 5회가 추가됐습니다!',
              ),
            ),
          );
        }
      },
      onFailed: () {
        if (mounted) {
          setState(() => _loading = false);
        }
      },
    );

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: _loading ? null : _onTap,
      icon: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.play_circle_outline_rounded),
      label: Text(widget.label ?? _defaultLabel),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.secondary,
        side: BorderSide(color: theme.colorScheme.secondary),
      ),
    );
  }
}
