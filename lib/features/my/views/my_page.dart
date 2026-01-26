import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';
import 'package:emoti_flow/core/providers/scroll_provider.dart';
import 'package:emoti_flow/features/diary/providers/diary_provider.dart';
import 'package:emoti_flow/shared/constants/emotion_character_map.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  final ScrollController _scrollController = ScrollController();
  String? _profileImageUrl;
  String? _nickname;
  String? _userId;
  String? _bio;
  String? _selectedCharacter; // 선택된 캐릭터
  int _diaryCount = 0;
  int _emotionCount = 0;
  int _streakDays = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // ScrollController를 Provider에 등록
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scrollControllerProvider(3).notifier).setController(_scrollController);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      setState(() {
        _userId = authState.user!.uid;
        _nickname = authState.user!.displayName ?? '사용자';
        _profileImageUrl = authState.user!.photoURL;
      });
      
      // 일기 통계 로드
      final diaryState = ref.read(diaryProvider);
      final entries = diaryState.diaryEntries;
      setState(() {
        _diaryCount = entries.length;
        _emotionCount = entries.fold(0, (sum, entry) => sum + entry.emotions.length);
        _streakDays = _calculateStreak(entries);
      });

      // 프로필 정보 로드
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _nickname = prefs.getString('user_nickname') ?? authState.user!.displayName ?? '사용자';
        _bio = prefs.getString('user_bio') ?? '';
        _profileImageUrl = prefs.getString('user_profile_image') ?? authState.user!.photoURL;
        _selectedCharacter = prefs.getString('user_character');
        
        // 프로필 이미지와 캐릭터가 모두 없으면 랜덤 캐릭터 선택
        if (_profileImageUrl == null && _selectedCharacter == null) {
          final random = Random();
          final availableEmotions = EmotionCharacterMap.availableEmotions;
          _selectedCharacter = availableEmotions[random.nextInt(availableEmotions.length)];
          prefs.setString('user_character', _selectedCharacter!);
        }
      });
    }
  }

  int _calculateStreak(List entries) {
    if (entries.isEmpty) return 0;
    
    final sortedEntries = List.from(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    int streak = 0;
    DateTime? lastDate;
    
    for (var entry in sortedEntries) {
      final entryDate = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      if (lastDate == null) {
        if (entryDate == todayDate || entryDate == todayDate.subtract(const Duration(days: 1))) {
          lastDate = entryDate;
          streak = 1;
        }
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (entryDate == expectedDate) {
          streak++;
          lastDate = entryDate;
        } else if (entryDate != lastDate) {
          break;
        }
      }
    }
    
    return streak;
  }



  Future<void> _uploadImage(File imageFile) async {
    if (_userId == null) return;
    
    try {
      setState(() {
        // 로딩 표시
      });
      
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$_userId.jpg');
      
      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();
      
      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_image', downloadUrl);
      
      setState(() {
        _profileImageUrl = downloadUrl;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 이미지가 업데이트되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 업로드 실패: $e')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (authState.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (authState.user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('로그인이 필요합니다'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('로그인하기'),
              ),
          ],
        ),
      ),
    );
  }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'MY',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
              tooltip: '설정',
            ),
          ],
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 헤더
              _buildProfileHeader(isDark),
              const SizedBox(height: 20),
              
              // 대시보드 통계
              _buildDashboardStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.primary.withOpacity(0.2),
                  AppTheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.surface,
                ]
              : [
                  AppTheme.primary.withOpacity(0.1),
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // 프로필 이미지 또는 캐릭터 (중앙)
              CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null
                    ? (_selectedCharacter != null
                        ? Image.asset(
                            EmotionCharacterMap.getCharacterAsset(_selectedCharacter!),
                            width: 120,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.face,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            },
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary,
                          ))
                    : null,
              ),
              const SizedBox(height: 20),
              
              // 사용자 정보 (중앙 정렬)
              Text(
                _nickname ?? '사용자',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (_bio != null && _bio!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _bio!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 16),
              
              // 간단한 통계 요약
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickStat(
                    icon: Icons.edit_note,
                    label: '일기',
                    value: '$_diaryCount',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                  _buildQuickStat(
                    icon: Icons.favorite,
                    label: '감정',
                    value: '$_emotionCount',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                  _buildQuickStat(
                    icon: Icons.local_fire_department,
                    label: '연속',
                    value: '$_streakDays일',
                  ),
                ],
              ),
            ],
          ),
          // 편집 버튼 (우측 상단)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () async {
                final result = await context.push(
                  '/profile/edit',
                  extra: {
                    'nickname': _nickname ?? '사용자',
                    'bio': _bio ?? '',
                    'profileImageUrl': _profileImageUrl,
                    'selectedCharacter': _selectedCharacter,
                  },
                );
                if (result == true) {
                  await _loadUserData();
                }
              },
              tooltip: '프로필 편집',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '활동 내역',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: '작성한 일기',
                  value: '$_diaryCount',
                  icon: Icons.edit_note,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: '기록한 감정',
                  value: '$_emotionCount',
                  icon: Icons.favorite,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: '연속 기록',
                  value: '$_streakDays일',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                  isText: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isText = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isText ? 14 : 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }


}

