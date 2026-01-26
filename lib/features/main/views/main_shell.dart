import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';
import 'package:emoti_flow/core/providers/scroll_provider.dart';

class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.user != null;

    return PopScope(
      canPop: navigationShell.currentIndex == 0, // 홈이면 뒤로가기 허용
      onPopInvoked: (didPop) {
        if (!didPop && navigationShell.currentIndex != 0) {
          // 홈이 아니면 홈으로 이동
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: navigationShell,
        ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          // 일기, AI, MY 탭 클릭 시 로그인 여부 확인
          if (index != 0 && !isLoggedIn) {
            _showLoginRequiredDialog(context);
            return;
          }
          
          // 같은 탭을 클릭하면 맨 위로 스크롤
          if (index == navigationShell.currentIndex) {
            final scrollNotifier = ref.read(scrollControllerProvider(index).notifier);
            scrollNotifier.scrollToTop();
          }
          
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: '일기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'MY',
          ),
        ],
      ),
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인 필요'),
        content: const Text('이 기능을 사용하려면 로그인이 필요합니다.\n로그인 페이지로 이동할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/login'); // /auth/login -> /login 으로 수정
            },
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }
}
