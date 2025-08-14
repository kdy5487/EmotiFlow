import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';

/// 로그인 에러 메시지 위젯
class LoginErrorMessage extends StatelessWidget {
  final String errorMessage;

  const LoginErrorMessage({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        errorMessage,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.error,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
