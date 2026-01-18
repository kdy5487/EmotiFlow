import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';
import 'package:emoti_flow/features/home/views/home_page.dart';
import 'package:emoti_flow/features/auth/pages/login_page.dart';
import 'package:emoti_flow/features/diary/views/diary_list_page/diary_list_page.dart';
import 'package:emoti_flow/features/diary/views/diary_write_page/diary_write_page.dart';
import 'package:emoti_flow/features/diary/views/diary_detail_page/diary_detail_page.dart';
import 'package:emoti_flow/features/diary/views/diary_chat_write_page/diary_chat_write_page.dart';
import 'package:emoti_flow/features/diary/views/drawing_canvas_page.dart';
import 'package:emoti_flow/features/settings/views/settings_page.dart';
import 'package:emoti_flow/features/main/views/main_shell.dart';
import 'package:emoti_flow/features/ai/views/ai_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String diaryList = '/diaries';
  static const String diaryWrite = '/diaries/write';
  static const String diaryDetail = '/diaries/:id';
  static const String diaryChat = '/diaries/chat';
  static const String diaryDrawing = '/diaries/drawing-canvas';
  static const String settings = '/settings';
  static const String ai = '/ai';
  static const String community = '/community';
}

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter? _router;

  static GoRouter getRouter(WidgetRef ref) {
    _router ??= GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.home,
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final isLoggedIn = authState.user != null;
        final isLoggingIn = state.matchedLocation == AppRoutes.login;

        if (isLoggedIn && isLoggingIn) {
          return AppRoutes.home;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.diaryList,
                  builder: (context, state) => const DiaryListPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.ai,
                  builder: (context, state) => const AIPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.community,
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('커뮤니티 페이지 (준비 중)')),
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.diaryWrite,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const DiaryWritePage(),
        ),
        GoRoute(
          path: AppRoutes.diaryDetail,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DiaryDetailPage(diaryId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.diaryChat,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const DiaryChatWritePage(),
        ),
        GoRoute(
          path: AppRoutes.diaryDrawing,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const DrawingCanvasPage(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    );

    return _router!;
  }

  static GoRouter createRouter(BuildContext context) {
    return _router ??= GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.home,
      routes: [],
    );
  }
}
