import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/services/ad_service.dart';

/// 네이티브 광고 위젯 (Small 템플릿)
///
/// 일기 목록, 홈 피드 등 콘텐츠 사이에 자연스럽게 삽입.
///
/// 사용법 — ListView itemBuilder에서:
/// ```dart
/// if (index != 0 && index % 5 == 0)
///   const NativeAdWidget(),
/// ```
class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    AdService.instance.loadNativeAd(
      onLoaded: (ad) {
        if (!mounted) return;
        setState(() {
          _ad = ad;
          _loaded = true;
        });
      },
    );
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: double.infinity,
          minHeight: 100,
          maxHeight: 120,
        ),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
