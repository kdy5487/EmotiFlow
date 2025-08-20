import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/features/home/views/home_page.dart';
import 'package:emoti_flow/features/diary/views/diary_write_page/diary_write_page.dart';
import 'package:emoti_flow/features/diary/views/diary_chat_write_page/diary_chat_write_page.dart';
import 'package:emoti_flow/features/diary/views/diary_list_page/diary_list_page.dart';
import 'package:emoti_flow/features/diary/views/diary_detail_page/diary_detail_page.dart';
import 'package:emoti_flow/features/diary/views/drawing_canvas_page.dart';
import 'package:emoti_flow/features/ai/views/ai_page.dart';
import 'package:emoti_flow/features/auth/pages/login_page.dart';
import 'package:emoti_flow/features/profile/views/profile_page.dart';
import 'package:emoti_flow/features/profile/views/profile_edit_page.dart';
import 'package:emoti_flow/features/settings/views/settings_page.dart';
import 'package:emoti_flow/features/settings/views/notification_settings_page.dart';
import 'package:emoti_flow/features/settings/views/theme_settings_page.dart';
import 'package:emoti_flow/features/settings/views/language_settings_page.dart';
import 'package:emoti_flow/features/settings/views/font_settings_page.dart';
import 'package:emoti_flow/features/settings/views/account_settings_page.dart';


// 라우트 이름 상수
class AppRoutes {
  static const String home = '/';
  static const String auth = '/auth';
  static const String login = '/auth/login';
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
        builder: (context, state) => const LoginPage(),
        routes: [
          GoRoute(
            path: 'login',
            name: 'login',
            builder: (context, state) => const LoginPage(),
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
          GoRoute(
            path: 'drawing-canvas',
            name: 'drawing-canvas',
            builder: (context, state) => const DrawingCanvasPage(),
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
      
      // 프로필 라우트
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
        routes: [
          GoRoute(
            path: 'edit',
            name: 'profile-edit',
            builder: (context, state) => const ProfileEditPage(),
          ),
        ],
      ),
      
      // 설정 라우트
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'notifications',
            name: 'notification-settings',
            builder: (context, state) => const NotificationSettingsPage(),
          ),
          GoRoute(
            path: 'theme',
            name: 'theme-settings',
            builder: (context, state) => const ThemeSettingsPage(),
          ),
          GoRoute(
            path: 'language',
            name: 'language-settings',
            builder: (context, state) => const LanguageSettingsPage(),
          ),
          GoRoute(
            path: 'font',
            name: 'font-settings',
            builder: (context, state) => const FontSettingsPage(),
          ),
          GoRoute(
            path: 'account',
            name: 'account-settings',
            builder: (context, state) => const AccountSettingsPage(),
          ),

        ],
      ),
      ],
      errorBuilder: (context, state) => const ErrorPage(),
    );
  }
}

// 임시 플레이스홀더 페이지들

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('감정 분석'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  size: 60,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '감정 분석',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '이 기능은 현재 개발 중입니다.\n\n추후 업데이트를 통해 제공될 예정이니\n잠시만 기다려주세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction,
                      size: 20,
                      color: Color(0xFF8B5CF6),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '개발 진행 중',
                      style: TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MusicPage extends StatelessWidget {
  const MusicPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('음악 추천'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.music_note_outlined,
                  size: 60,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '음악 추천',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '이 기능은 현재 개발 중입니다.\n\n추후 업데이트를 통해 제공될 예정이니\n잠시만 기다려주세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction,
                      size: 20,
                      color: Color(0xFF8B5CF6),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '개발 진행 중',
                      style: TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('커뮤니티'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.people_outline,
                  size: 60,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '커뮤니티',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '이 기능은 현재 개발 중입니다.\n\n추후 업데이트를 통해 제공될 예정이니\n잠시만 기다려주세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction,
                      size: 20,
                      color: Color(0xFF8B5CF6),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '개발 진행 중',
                      style: TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
