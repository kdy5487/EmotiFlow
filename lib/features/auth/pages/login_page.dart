import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../theme/app_colors.dart';
import 'widgets/login_header.dart';
import 'widgets/login_welcome_message.dart';
import 'widgets/login_google_button.dart';
import 'widgets/login_terms_privacy.dart';
import 'widgets/login_error_message.dart';
import 'widgets/login_email_form.dart';
import 'signup_page.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginHeader(),
                const SizedBox(height: 48),
                const LoginWelcomeMessage(),
                const SizedBox(height: 32),

                // 이메일 로그인 폼
                LoginEmailForm(
                  isLoading: authState.isLoading,
                  onLogin: ({required email, required password}) =>
                      _handleEmailSignIn(context, ref,
                          email: email, password: password),
                  onSignUp: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SignUpPage()),
                  ),
                  onForgotPassword: () =>
                      _showForgotPasswordDialog(context, ref),
                ),

                const SizedBox(height: 20),

                // 구분선
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '또는',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 20),

                // Google 로그인 버튼
                LoginGoogleButton(
                  onPressed: () => _handleGoogleSignIn(context, ref),
                  isLoading: authState.isLoading,
                ),

                const SizedBox(height: 24),
                const LoginTermsPrivacy(),

                if (authState.error != null) ...[
                  const SizedBox(height: 16),
                  LoginErrorMessage(errorMessage: authState.error!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 이메일 로그인 처리
  Future<void> _handleEmailSignIn(
    BuildContext context,
    WidgetRef ref, {
    required String email,
    required String password,
  }) async {
    final success = await ref
        .read(authProvider.notifier)
        .signInWithEmail(email: email, password: password);
    if (success && context.mounted) {
      _showSuccessMessage(context, '로그인이 완료됐습니다!');
    }
  }

  /// 비밀번호 찾기 다이얼로그
  void _showForgotPasswordDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('비밀번호 재설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('가입한 이메일 주소를 입력하면\n재설정 링크를 보내드립니다.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              final success = await ref
                  .read(authProvider.notifier)
                  .sendPasswordResetEmail(email);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (success && context.mounted) {
                  _showSuccessMessage(context, '재설정 이메일을 전송했습니다.');
                }
              }
            },
            child: const Text('전송'),
          ),
        ],
      ),
    );
  }

  /// Google 로그인 처리
  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    final authNotifier = ref.read(authProvider.notifier);
    
    try {
      final success = await authNotifier.signInWithGoogle();
      
      if (success && context.mounted) {
        _showSuccessMessage(context, 'Google 로그인이 완료되었습니다! 🎉');
      } else if (context.mounted) {
        final authState = ref.read(authProvider);
        String errorMessage = authState.error ?? 'Google 로그인에 실패했습니다.';
        
        // ApiException: 10 에러에 대한 친화적인 메시지
        if (errorMessage.contains('ApiException: 10') || 
            errorMessage.contains('sign_in_failed')) {
          errorMessage = '🔧 Google 로그인 설정이 필요합니다.\n'
                       '개발자에게 문의해주세요.\n'
                       '(SHA-1 인증서 설정 필요)';
        }
        
        _showErrorMessage(context, errorMessage);
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'Google 로그인 중 오류가 발생했습니다.';
        
        if (e.toString().contains('ApiException: 10')) {
          errorMessage = '🔧 Google 로그인 설정이 필요합니다.\n'
                        '잠시 후 다시 시도해주세요.';
        }
        
        _showErrorMessage(context, errorMessage);
      }
    }
  }
  
  /// 성공 메시지 표시
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// 에러 메시지 표시
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}