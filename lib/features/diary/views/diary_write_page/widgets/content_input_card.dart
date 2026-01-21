import 'package:flutter/material.dart';

/// 내용 입력 카드 위젯 (다크모드 지원)
class ContentInputCard extends StatelessWidget {
  final TextEditingController controller;

  const ContentInputCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '일기 내용',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: '오늘 하루를 기록해보세요...',
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(0.1), 
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurface,
              height: 1.6,
            ),
            maxLines: 10,
            minLines: 5,
          ),
        ],
      ),
    );
  }
}
