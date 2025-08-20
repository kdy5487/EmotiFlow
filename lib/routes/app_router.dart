import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoti_flow/features/home/views/home_page.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';
import 'package:emoti_flow/features/diary/views/diary_write_page/diary_write_page.dart';
import 'package:emoti_flow/features/diary/views/diary_chat_write_page/diary_chat_write_page.dart';
import 'package:emoti_flow/features/diary/views/diary_list_page/diary_list_page.dart';
import 'package:emoti_flow/features/diary/views/diary_detail_page/diary_detail_page.dart';
import 'package:emoti_flow/features/ai/views/ai_page.dart';
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
  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: AppRoutes.home,
      redirect: (context, state) {
        // Riverpod을 사용하지 않으므로 기본 리다이렉트 로직만 구현
        final String loc = state.uri.toString();
        
        // 로그인 상태는 각 페이지에서 개별적으로 처리
        return null;
      },
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
        builder: (context, state) => const DiaryListPage(),
        routes: [
          GoRoute(
            path: 'write',
            name: 'diary-write',
            builder: (context, state) => const DiaryWritePage(),
          ),
          GoRoute(
            path: 'chat-write',
            name: 'diary-chat-write',
            builder: (context, state) => const DiaryChatWritePage(),
          ),
          GoRoute(
            path: 'detail/:id',
            name: 'diary-detail',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return DiaryDetailPage(diaryId: id);
            },
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



// 임시 플레이스홀더 페이지들

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('분석')),
      body: const Center(child: Text('분석 페이지 - 개발 중')),
    );
  }
}

class MusicPage extends StatelessWidget {
  const MusicPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('음악')),
      body: const Center(child: Text('음악 페이지 - 개발 중')),
    );
  }
}

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('커뮤니티')),
      body: const Center(child: Text('커뮤니티 페이지 - 개발 중')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: const Center(child: Text('설정 페이지 - 개발 중')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: const Center(child: Text('프로필 페이지 - 개발 중')),
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
