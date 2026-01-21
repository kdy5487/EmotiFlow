import 'package:flutter/material.dart';
import '../drawing_canvas_page.dart';

/// 그림 그리기 도구 바 위젯
class DrawingToolBar extends StatelessWidget {
  final DrawingTool currentTool;
  final Color currentColor;
  final double currentPenWidth;
  final double currentEraserWidth;
  final Function(DrawingTool) onToolSelected;
  final VoidCallback onColorTap;
  final VoidCallback onBrushSizeTap;
  final VoidCallback onEraserSizeTap;
  final VoidCallback onStickerTap;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onDeleteLast;
  final bool canUndo;
  final bool canRedo;

  const DrawingToolBar({
    super.key,
    required this.currentTool,
    required this.currentColor,
    required this.currentPenWidth,
    required this.currentEraserWidth,
    required this.onToolSelected,
    required this.onColorTap,
    required this.onBrushSizeTap,
    required this.onEraserSizeTap,
    required this.onStickerTap,
    required this.onUndo,
    required this.onRedo,
    required this.onDeleteLast,
    required this.canUndo,
    required this.canRedo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 펜
            _buildToolButton(
              icon: Icons.edit,
              label: '펜',
              isSelected: currentTool == DrawingTool.pen,
              onTap: () => onToolSelected(DrawingTool.pen),
            ),
            const SizedBox(width: 4),

            // 지우개
            _buildToolButton(
              icon: Icons.cleaning_services,
              label: '지우개',
              isSelected: currentTool == DrawingTool.eraser,
              onTap: () {
                if (currentTool == DrawingTool.eraser) {
                  onEraserSizeTap();
                } else {
                  onToolSelected(DrawingTool.eraser);
                }
              },
            ),
            const SizedBox(width: 4),

            // 색상
            _buildToolButton(
              icon: Icons.palette,
              label: '색상',
              color: currentColor,
              onTap: onColorTap,
            ),
            const SizedBox(width: 4),

            // 브러시 크기
            _buildToolButton(
              icon: Icons.brush,
              label: '브러시',
              onTap: onBrushSizeTap,
            ),
            const SizedBox(width: 8),

            // 구분선
            Container(
              width: 1,
              height: 40,
              color: Colors.grey[300],
            ),
            const SizedBox(width: 8),

            // 되돌리기
            _buildToolButton(
              icon: Icons.undo,
              label: '←',
              isEnabled: canUndo,
              onTap: onUndo,
            ),
            const SizedBox(width: 4),

            // 다시 실행
            _buildToolButton(
              icon: Icons.redo,
              label: '→',
              isEnabled: canRedo,
              onTap: onRedo,
            ),
            const SizedBox(width: 4),

            // 마지막 삭제
            _buildToolButton(
              icon: Icons.backspace,
              label: '⌫',
              isEnabled: canUndo,
              onTap: onDeleteLast,
            ),
            const SizedBox(width: 8),

            // 구분선
            Container(
              width: 1,
              height: 40,
              color: Colors.grey[300],
            ),
            const SizedBox(width: 8),

            // 원
            _buildToolButton(
              icon: Icons.circle_outlined,
              label: '○',
              isSelected: currentTool == DrawingTool.circle,
              onTap: () => onToolSelected(DrawingTool.circle),
            ),
            const SizedBox(width: 4),

            // 하트
            _buildToolButton(
              icon: Icons.favorite_border,
              label: '♡',
              isSelected: currentTool == DrawingTool.heart,
              onTap: () => onToolSelected(DrawingTool.heart),
            ),
            const SizedBox(width: 4),

            // 스티커
            _buildToolButton(
              icon: Icons.emoji_emotions,
              label: '😊',
              onTap: onStickerTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    Color? color,
    bool isSelected = false,
    bool isEnabled = true,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : (isEnabled ? Colors.transparent : Colors.grey[200]),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isEnabled
                  ? (color ?? (isSelected ? Colors.blue : Colors.black87))
                  : Colors.grey,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isEnabled
                      ? (isSelected ? Colors.blue : Colors.black87)
                      : Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

