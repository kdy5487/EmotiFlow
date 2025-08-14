import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';

/// 이용약관 및 개인정보처리방침 위젯
class LoginTermsPrivacy extends StatelessWidget {
  const LoginTermsPrivacy({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text.rich(
        TextSpan(
          text: '로그인하면 ',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
          children: [
            TextSpan(
              text: '이용약관',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' 및 '),
            TextSpan(
              text: '개인정보처리방침',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: '에 동의하게 됩니다.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
