import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../theme/app_colors.dart';
import 'widgets/login_header.dart';
import 'widgets/login_welcome_message.dart';
import 'widgets/login_google_button.dart';
import 'widgets/login_terms_privacy.dart';
import 'widgets/login_error_message.dart';

/// Google 로그인 전용 페이지
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
                         MediaQuery.of(context).padding.bottom - 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 로고 및 앱 제목
                const LoginHeader(),
              
                const SizedBox(height: 60),
                
                // 환영 메시지
                const LoginWelcomeMessage(),
                
                const SizedBox(height: 40),
                
                // Google 로그인 버튼
                LoginGoogleButton(
                  onPressed: () => _handleGoogleSignIn(context, ref),
                  isLoading: authState.isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // 이용약관 및 개인정보처리방침
                const LoginTermsPrivacy(),
                
                // 로딩 표시
                if (authState.isLoading) ...[
                  const SizedBox(height: 24),
                  const Center(child: CircularProgressIndicator()),
                ],
                
                // 에러 메시지
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