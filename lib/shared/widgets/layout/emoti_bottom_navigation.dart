import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// EmotiFlow 앱의 공통 BottomNavigationBar 컴포넌트
/// UI/UX 가이드에 정의된 모든 BottomNavigationBar 스타일을 포함
class EmotiBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const EmotiBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor ?? AppColors.surface,
      selectedItemColor: selectedItemColor ?? AppColors.primary,
      unselectedItemColor: unselectedItemColor ?? AppColors.textTertiary,
      elevation: 8,
      selectedLabelStyle: AppTypography.labelSmall.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.labelSmall,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit_outlined),
          activeIcon: Icon(Icons.edit),
          label: '일기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology_outlined),
          activeIcon: Icon(Icons.psychology),
          label: 'AI',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: '분석',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.music_note_outlined),
          activeIcon: Icon(Icons.music_note),
          label: '음악',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '프로필',
        ),
      ],
    );
  }
}

/// 감정별 음악 페이지용 BottomNavigationBar
class EmotiMusicBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EmotiMusicBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      elevation: 8,
      selectedLabelStyle: AppTypography.labelSmall.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.labelSmall,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline),
          activeIcon: Icon(Icons.play_circle),
          label: '재생',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: '좋아요',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.playlist_play_outlined),
          activeIcon: Icon(Icons.playlist_play),
          label: '플레이리스트',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: '검색',
        ),
      ],
    );
  }
}

/// 커뮤니티 페이지용 BottomNavigationBar
class EmotiCommunityBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EmotiCommunityBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      elevation: 8,
      selectedLabelStyle: AppTypography.labelSmall.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.labelSmall,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.forum_outlined),
          activeIcon: Icon(Icons.forum),
          label: '게시판',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          activeIcon: Icon(Icons.group),
          label: '그룹',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up_outlined),
          activeIcon: Icon(Icons.trending_up),
          label: '트렌드',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: '알림',
        ),
      ],
    );
  }
}
