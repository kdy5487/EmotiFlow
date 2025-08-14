import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/buttons/emoti_button.dart';

/// Google 로그인 버튼 위젯
class LoginGoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const LoginGoogleButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return EmotiButton(
      onPressed: isLoading ? null : onPressed,
      text: 'Google로 로그인',
      type: EmotiButtonType.primary,
      size: EmotiButtonSize.large,
      icon: Icons.g_mobiledata,
      isLoading: isLoading,
    );
  }
}
