import 'dart:io';
import 'package:flutter/material.dart';
import 'package:emoti_flow/shared/widgets/cards/emoti_card.dart';
import 'package:emoti_flow/shared/widgets/buttons/emoti_button.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/theme/app_typography.dart';

class WriteMediaAttachment extends StatelessWidget {
  final List<File> selectedImages;
  final List<File> selectedDrawings;
  final VoidCallback onPickImage;
  final VoidCallback onOpenCanvas;
  final Function(File, String) onRemove;

  const WriteMediaAttachment({
    super.key,
    required this.selectedImages,
    required this.selectedDrawings,
    required this.onPickImage,
    required this.onOpenCanvas,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '미디어 첨부',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: EmotiButton(
                    text: '사진 추가',
                    onPressed: onPickImage,
                    type: EmotiButtonType.outline,
                    size: EmotiButtonSize.medium,
                    icon: Icons.photo_library,
                    textColor: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: EmotiButton(
                    text: '그림 그리기',
                    onPressed: onOpenCanvas,
                    type: EmotiButtonType.outline,
                    size: EmotiButtonSize.medium,
                    icon: Icons.brush,
                    textColor: AppTheme.primary,
                  ),
                ),
              ],
            ),
            if (selectedImages.isNotEmpty || selectedDrawings.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '선택된 미디어',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...selectedImages.map((file) => _buildPreview(file, 'image')),
                  ...selectedDrawings.map((file) => _buildPreview(file, 'drawing')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(File file, String type) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(file, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => onRemove(file, type),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
