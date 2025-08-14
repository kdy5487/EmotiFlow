import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/buttons/emoti_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// Google 로그인 전용 페이지
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return SingleChildScrollView(
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
                    _buildHeader(),
                  
                    const SizedBox(height: 60),
                    
                    // 환영 메시지
                    _buildWelcomeMessage(),
                    
                    const SizedBox(height: 40),
                    
                    // Google 로그인 버튼
                    _buildGoogleSignInButton(context, authProvider),
                    
                    const SizedBox(height: 24),
                    
                    // 이용약관 및 개인정보처리방침
                    _buildTermsAndPrivacy(),
                    
                    // 로딩 표시
                    if (authProvider.isLoading) ...[
                      const SizedBox(height: 24),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    
                    // 에러 메시지
                    if (authProvider.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          authProvider.error!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  /// 헤더 (로고 및 제목)
  Widget _buildHeader() {
    return Column(
      children: [
        // 로고
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology,
            size: 50,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 제목
        Text(
          'EmotiFlow',
          style: AppTypography.displayLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 부제목
        Text(
          'AI와 함께하는 감정 일기',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  /// 환영 메시지
  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Text(
          '환영합니다! 👋',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'Google 계정으로 간편하게 로그인하고\n감정 일기를 시작해보세요',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  /// Google 로그인 버튼
  Widget _buildGoogleSignInButton(BuildContext context, AuthProvider authProvider) {
    return EmotiButton(
      onPressed: authProvider.isLoading ? null : () => _handleGoogleSignIn(context),
      text: 'Google로 로그인',
      type: EmotiButtonType.primary,
      size: EmotiButtonSize.large,
      icon: Icons.g_mobiledata,
      isLoading: authProvider.isLoading,
    );
  }
  
  /// 이용약관 및 개인정보처리방침
  Widget _buildTermsAndPrivacy() {
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
  
  /// Google 로그인 처리
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    
    try {
      final success = await authProvider.signInWithGoogle();
      
      if (success && context.mounted) {
        _showSuccessMessage(context, 'Google 로그인이 완료되었습니다! 🎉');
      } else if (context.mounted) {
        String errorMessage = authProvider.error ?? 'Google 로그인에 실패했습니다.';
        
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