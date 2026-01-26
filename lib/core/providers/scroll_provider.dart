import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// 각 탭의 ScrollController를 관리하는 Provider
final scrollControllerProvider = StateNotifierProvider.family<ScrollControllerNotifier, ScrollController?, int>((ref, index) {
  return ScrollControllerNotifier();
});

class ScrollControllerNotifier extends StateNotifier<ScrollController?> {
  ScrollControllerNotifier() : super(null);

  void setController(ScrollController controller) {
    state?.dispose();
    state = controller;
  }

  void scrollToTop() {
    if (state != null && state!.hasClients) {
      state!.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

