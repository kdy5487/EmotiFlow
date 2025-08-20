import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'music_provider.dart';

class PendingMusicPrompt {
  final String emotion;
  final int intensity; // 1-10
  final EmotionSource source;
  const PendingMusicPrompt({required this.emotion, required this.intensity, required this.source});
}

final pendingMusicPromptProvider = StateProvider<PendingMusicPrompt?>((ref) => null);


