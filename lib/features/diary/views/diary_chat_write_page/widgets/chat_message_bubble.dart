import 'package:emoti_flow/features/diary/domain/entities/chat_message.dart';
import 'package:emoti_flow/theme/app_colors.dart';
import 'package:emoti_flow/theme/app_typography.dart';
import 'package:emoti_flow/shared/constants/emotion_character_map.dart';
import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String? selectedEmotion;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.selectedEmotion,
  });

  @override
  Widget build(BuildContext context) {
    final isAI = message.isFromAI;
    final characterAsset =
        EmotionCharacterMap.getCharacterAsset(selectedEmotion);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment:
            isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAI) ...[
            // AI 캐릭터 아바타 (감정별 캐릭터 또는 기본 Emoti)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  characterAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // 이미지 로드 실패 시 기본 아이콘 표시
                    return Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Icons.psychology,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isAI ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isAI ? 4 : 20),
                  topRight: Radius.circular(isAI ? 20 : 4),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: isAI ? AppColors.textPrimary : Colors.white,
                  height: 1.5,
                  fontSize: 14, // 15 → 14로 감소
                ),
              ),
            ),
          ),
          if (!isAI) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: AppColors.secondary,
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
