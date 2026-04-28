import 'package:flutter/material.dart';

class LoginEmailForm extends StatefulWidget {
  final bool isLoading;
  final Future<void> Function({
    required String email,
    required String password,
  }) onLogin;
  final VoidCallback onSignUp;
  final VoidCallback onForgotPassword;

  const LoginEmailForm({
    super.key,
    required this.isLoading,
    required this.onLogin,
    required this.onSignUp,
    required this.onForgotPassword,
  });

  @override
  State<LoginEmailForm> createState() => _LoginEmailFormState();
}

class _LoginEmailFormState extends State<LoginEmailForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    await widget.onLogin(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 이메일 필드
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '이메일',
              hintText: 'example@email.com',
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return '이메일을 입력해주세요.';
              if (!v.contains('@')) return '유효한 이메일을 입력해주세요.';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // 비밀번호 필드
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: '비밀번호',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return '비밀번호를 입력해주세요.';
              if (v.length < 6) return '비밀번호는 6자 이상이어야 합니다.';
              return null;
            },
          ),

          // 비밀번호 찾기
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 4),
              ),
              child: const Text('비밀번호를 잊으셨나요?',
                  style: TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(height: 8),

          // 로그인 버튼
          FilledButton(
            onPressed: widget.isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('로그인', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 16),

          // 회원가입 링크
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '아직 계정이 없으신가요?',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              TextButton(
                onPressed: widget.onSignUp,
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                child: const Text('회원가입',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
