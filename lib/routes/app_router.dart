import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/features/home/views/home_page.dart';
// TODO: 각 뷰 생성 전까지는 라우트를 최소화 유지
import 'package:emoti_flow/features/auth/pages/login_page.dart' as login;

// 라우트 이름 상수
class AppRoutes {
  static const String home = '/';
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';
  static const String diary = '/diary';
  static const String diaryCreate = '/diary/create';
  static const String diaryDetail = '/diary/detail';
  static const String ai = '/ai';
  static const String analytics = '/analytics';
  static const String music = '/music';
  static const String community = '/community';
  static const String settings = '/settings';
  static const String profile = '/profile';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      // 홈 페이지
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      
      // 인증 관련 라우트
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
         builder: (context, state) => const login.LoginPage(),
        routes: [
          GoRoute(
            path: 'login',
            name: 'login',
             builder: (context, state) => const login.LoginPage(),
          ),
          GoRoute(
            path: 'signup',
            name: 'signup',
            builder: (context, state) => const SignupPage(),
          ),
          GoRoute(
            path: 'forgot-password',
            name: 'forgot-password',
            builder: (context, state) => const ForgotPasswordPage(),
          ),
        ],
      ),
      
      // 일기 관련 라우트
      GoRoute(
        path: AppRoutes.diary,
        name: 'diary',
        builder: (context, state) => const DiaryPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'diary-create',
            builder: (context, state) => const DiaryCreatePage(),
          ),
          GoRoute(
            path: 'detail',
            name: 'diary-detail',
            builder: (context, state) => const DiaryDetailPage(),
          ),
        ],
      ),
      
      // AI 서비스 라우트
      GoRoute(
        path: AppRoutes.ai,
        name: 'ai',
        builder: (context, state) => const AIPage(),
      ),
      
      // 분석 라우트
      GoRoute(
        path: AppRoutes.analytics,
        name: 'analytics',
        builder: (context, state) => const AnalyticsPage(),
      ),
      
      // 음악 라우트
      GoRoute(
        path: AppRoutes.music,
        name: 'music',
        builder: (context, state) => const MusicPage(),
      ),
      
      // 커뮤니티 라우트
      GoRoute(
        path: AppRoutes.community,
        name: 'community',
        builder: (context, state) => const CommunityPage(),
      ),
      
      // 설정 라우트
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      
      // 프로필 라우트
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
    errorBuilder: (context, state) => const ErrorPage(),
  );
}



class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('인증')),
      body: const Center(child: Text('인증 페이지')),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: const Center(child: Text('로그인 페이지')),
    );
  }
}

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: const Center(child: Text('회원가입 페이지')),
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 찾기')),
      body: const Center(child: Text('비밀번호 찾기 페이지')),
    );
  }
}

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일기')),
      body: const Center(child: Text('일기 페이지')),
    );
  }
}

class DiaryCreatePage extends StatelessWidget {
  const DiaryCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일기 작성')),
      body: const Center(child: Text('일기 작성 페이지')),
    );
  }
}

class DiaryDetailPage extends StatelessWidget {
  const DiaryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일기 상세')),
      body: const Center(child: Text('일기 상세 페이지')),
    );
  }
}

class AIPage extends StatelessWidget {
  const AIPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 서비스')),
      body: const Center(child: Text('AI 서비스 페이지')),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('분석')),
      body: const Center(child: Text('분석 페이지')),
    );
  }
}

class MusicPage extends StatelessWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('음악')),
      body: const Center(child: Text('음악 페이지')),
    );
  }
}

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('커뮤니티')),
      body: const Center(child: Text('커뮤니티 페이지')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: const Center(child: Text('설정 페이지')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: const Center(child: Text('프로필 페이지')),
    );
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오류')),
      body: const Center(child: Text('페이지를 찾을 수 없습니다')),
    );
  }
}
