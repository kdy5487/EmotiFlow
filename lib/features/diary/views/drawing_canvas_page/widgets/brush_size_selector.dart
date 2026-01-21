import 'package:flutter/material.dart';
import '../constants/drawing_constants.dart';

/// 브러시 크기 선택 위젯
class BrushSizeSelector extends StatelessWidget {
  final double currentSize;
  final Function(double) onSizeSelected;
  final VoidCallback onClose;
  final Color color;

  const BrushSizeSelector({
    super.key,
    required this.currentSize,
    required this.onSizeSelected,
    required this.onClose,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '브러시 크기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...DrawingConstants.brushSizes.map((size) {
            final isSelected = size == currentSize;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                onTap: () {
                  onSizeSelected(size);
                  onClose();
                },
                leading: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                title: Text(
                  '${size.toInt()}px',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

