import 'package:emoti_flow/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DiaryFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const DiaryFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add),
    );
  }
}


