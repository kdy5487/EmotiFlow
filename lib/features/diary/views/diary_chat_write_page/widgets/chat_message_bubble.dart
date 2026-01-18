import 'package:emoti_flow/features/diary/domain/entities/chat_message.dart';
import 'package:emoti_flow/theme/app_colors.dart';
import 'package:emoti_flow/theme/app_typography.dart';
import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isAI = message.isFromAI;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAI) ...[
            const CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: Icon(Icons.psychology, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAI
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: isAI ? AppColors.textPrimary : Colors.white,
                  height: 1.3,
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
