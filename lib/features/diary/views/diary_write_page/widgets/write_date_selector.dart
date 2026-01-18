import 'package:flutter/material.dart';
import 'package:emoti_flow/theme/app_theme.dart';

class WriteDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const WriteDateSelector({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
