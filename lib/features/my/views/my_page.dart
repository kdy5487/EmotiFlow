import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/ai/gemini/gemini_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/scroll_provider.dart';
import '../../../features/diary/domain/entities/diary_entry.dart';
import '../../../features/diary/providers/diary_provider.dart';
import '../../../shared/constants/emotion_character_map.dart';
import '../widgets/diary_heatmap.dart';

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
  String? _selectedCharacter;
  int _diaryCount = 0;
  int _emotionCount = 0;
  int _streakDays = 0;

  // AI 페르소나
  String _aiPersona = '';
  final _personaController = TextEditingController();
  bool _editingPersona = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scrollControllerProvider(3).notifier).setController(_scrollController);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _personaController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final diaryState = ref.read(diaryProvider);
    final entries = diaryState.diaryEntries;
    final persona = await GeminiService.instance.getPersona();

    if (!mounted) return;
    setState(() {
      _userId = authState.user!.uid;
      _nickname = prefs.getString('user_nickname') ?? authState.user!.displayName ?? '사용자';
      _bio = prefs.getString('user_bio') ?? '';
      _profileImageUrl = prefs.getString('user_profile_image') ?? authState.user!.photoURL;
      _selectedCharacter = prefs.getString('user_character');
      _diaryCount = entries.length;
      _emotionCount = entries.fold(0, (s, e) => s + e.emotions.length);
      _streakDays = _calculateStreak(entries);
      _aiPersona = persona;
      _personaController.text = persona;

      if (_profileImageUrl == null && _selectedCharacter == null) {
        final avail = EmotionCharacterMap.availableEmotions;
        _selectedCharacter = avail[Random().nextInt(avail.length)];
        prefs.setString('user_character', _selectedCharacter!);
      }
    });
  }

  int _calculateStreak(List entries) {
    if (entries.isEmpty) return 0;
    final sorted = List.from(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    int streak = 0;
    DateTime? last;
    for (final e in sorted) {
      final d = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      final today = DateTime.now();
      final td = DateTime(today.year, today.month, today.day);
      if (last == null) {
        if (d == td || d == td.subtract(const Duration(days: 1))) {
          last = d;
          streak = 1;
        }
      } else {
        if (d == last.subtract(const Duration(days: 1))) {
          streak++;
          last = d;
        } else if (d != last) {
          break;
        }
      }
    }
    return streak;
  }

  Future<void> _uploadImage(File imageFile) async {
    if (_userId == null) return;
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$_userId.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_image', url);
      if (!mounted) return;
      setState(() => _profileImageUrl = url);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 이미지가 업데이트됐습니다.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('이미지 업로드 실패: $e')));
    }
  }

  Future<void> _savePersona() async {
    await GeminiService.instance.savePersona(_personaController.text);
    if (!mounted) return;
    setState(() {
      _aiPersona = _personaController.text.trim();
      _editingPersona = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI 성격이 저장됐습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (authState.user == null) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('로그인이 필요합니다'),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('로그인하기')),
          ]),
        ),
      );
    }

    return Consumer(builder: (context, ref, _) {
      final entries = ref.watch(diaryProvider).diaryEntries;

      return PopScope(
        canPop: false,
        onPopInvoked: (d) { if (!d) context.go('/'); },
        child: Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            title: Text(_nickname ?? 'MY',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
                tooltip: '설정',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadUserData,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                // ── 프로필 ──────────────────────────────
                _buildProfileSection(cs, tt),
                const SizedBox(height: 16),

                // ── 통계 배지 ───────────────────────────
                _buildStatsBadges(cs, tt),
                const SizedBox(height: 24),

                // ── 활동 히트맵 ─────────────────────────
                _buildSectionLabel('활동', Icons.grid_view_rounded, cs, tt),
                const SizedBox(height: 10),
                _buildHeatmapCard(entries, cs),
                const SizedBox(height: 24),

                // ── 타임라인 ────────────────────────────
                _buildSectionLabel('최근 일기', Icons.timeline_rounded, cs, tt),
                const SizedBox(height: 10),
                _buildTimeline(entries, cs, tt),
                const SizedBox(height: 24),

                // ── AI 성격 설정 ────────────────────────
                _buildSectionLabel('AI 성격', Icons.psychology_outlined, cs, tt),
                const SizedBox(height: 10),
                _buildAiPersonaCard(cs, tt),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ── 섹션 라벨 ─────────────────────────────────────

  Widget _buildSectionLabel(
      String label, IconData icon, ColorScheme cs, TextTheme tt) {
    return Row(children: [
      Icon(icon, size: 18, color: cs.primary),
      const SizedBox(width: 6),
      Text(label,
          style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w700, color: cs.onSurface)),
    ]);
  }

  // ── 프로필 ────────────────────────────────────────

  Widget _buildProfileSection(ColorScheme cs, TextTheme tt) {
    final avatar = _profileImageUrl != null
        ? CircleAvatar(
            radius: 36,
            backgroundImage: NetworkImage(_profileImageUrl!),
          )
        : CircleAvatar(
            radius: 36,
            backgroundColor: cs.primaryContainer,
            child: _selectedCharacter != null
                ? Text(
                    _emotionEmoji[_selectedCharacter] ?? '📓',
                    style: const TextStyle(fontSize: 30),
                  )
                : Icon(Icons.person_rounded,
                    size: 32, color: cs.onPrimaryContainer),
          );

    return Row(children: [
      avatar,
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_nickname ?? '',
                style: tt.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            if (_bio != null && _bio!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(_bio!,
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurface.withOpacity(0.55))),
            ],
          ],
        ),
      ),
    ]);
  }

  // ── 통계 배지 ─────────────────────────────────────

  Widget _buildStatsBadges(ColorScheme cs, TextTheme tt) {
    return Row(children: [
      _statBadge('$_diaryCount', '일기', Icons.book_outlined, cs, tt),
      const SizedBox(width: 10),
      _statBadge('$_streakDays', '연속', Icons.local_fire_department_rounded,
          cs, tt),
      const SizedBox(width: 10),
      _statBadge('$_emotionCount', '감정', Icons.favorite_border_rounded, cs, tt),
    ]);
  }

  Widget _statBadge(String value, String label, IconData icon, ColorScheme cs,
      TextTheme tt) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(height: 4),
          Text(value,
              style: tt.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(label,
              style: tt.labelSmall
                  ?.copyWith(color: cs.onSurface.withOpacity(0.5))),
        ]),
      ),
    );
  }

  // ── 히트맵 카드 ───────────────────────────────────

  Widget _buildHeatmapCard(List<DiaryEntry> entries, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DiaryHeatmap(entries: entries),
    );
  }

  // ── 타임라인 ─────────────────────────────────────

  Widget _buildTimeline(
      List<DiaryEntry> entries, ColorScheme cs, TextTheme tt) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('아직 작성된 일기가 없습니다.',
            style: tt.bodyMedium
                ?.copyWith(color: cs.onSurface.withOpacity(0.4))),
      );
    }

    final sorted = List<DiaryEntry>.from(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recent = sorted.take(12).toList();

    return Column(
      children: List.generate(recent.length, (i) {
        final entry = recent[i];
        final isLast = i == recent.length - 1;
        final emotion = entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
            final char = _emotionChar(emotion);
        final dateStr = _formatDate(entry.createdAt);
        final snippet = entry.content.length > 50
            ? '${entry.content.substring(0, 50)}…'
            : entry.content;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타임라인 선 + 아이콘
              Column(children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(char, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: cs.outlineVariant.withOpacity(0.4),
                    ),
                  ),
              ]),
              const SizedBox(width: 12),
              // 내용
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/diary/${entry.id}'),
                  child: Container(
                    margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(dateStr,
                              style: tt.labelSmall?.copyWith(
                                  color: cs.onSurface.withOpacity(0.5))),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(emotion,
                                style: tt.labelSmall
                                    ?.copyWith(color: cs.onPrimaryContainer)),
                          ),
                        ]),
                        if (entry.title.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(entry.title,
                              style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600)),
                        ],
                        const SizedBox(height: 2),
                        Text(snippet,
                            style: tt.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.6))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  static const _emotionEmoji = {
    '기쁨': '😊', '설렘': '🥰', '감사': '🙏', '평온': '😌',
    '슬픔': '😢', '분노': '😤', '걱정': '😟', '지루함': '😑',
    '놀람': '😲', '혼란': '😵',
  };
  String _emotionChar(String emotion) => _emotionEmoji[emotion] ?? '📓';

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(DateTime(dt.year, dt.month, dt.day)).inDays;
    if (diff == 0) return '오늘';
    if (diff == 1) return '어제';
    if (diff < 7) return '$diff일 전';
    return '${dt.month}/${dt.day}';
  }

  // ── AI 성격 카드 ──────────────────────────────────

  Widget _buildAiPersonaCard(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                'AI 성격 설정',
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (!_editingPersona)
              TextButton(
                onPressed: () => setState(() => _editingPersona = true),
                child: const Text('편집'),
              ),
          ]),
          const SizedBox(height: 4),
          Text(
            'AI에게 어떤 성격을 부여할까요? 비워두면 기본 친구 같은 대화 스타일로 동작합니다.',
            style: tt.bodySmall
                ?.copyWith(color: cs.onSurface.withOpacity(0.5)),
          ),
          const SizedBox(height: 12),
          if (_editingPersona) ...[
            TextField(
              controller: _personaController,
              decoration: InputDecoration(
                hintText: '예: 따뜻하고 유머러스한 친구처럼 반말로 대화해줘',
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
              maxLines: 2,
              style: tt.bodyMedium,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _personaController.text = _aiPersona;
                    setState(() => _editingPersona = false);
                  },
                  child: const Text('취소'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _savePersona,
                  child: const Text('저장'),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _aiPersona.isEmpty ? '설정된 성격 없음 (기본값)' : _aiPersona,
                style: tt.bodyMedium?.copyWith(
                  color: _aiPersona.isEmpty
                      ? cs.onSurface.withOpacity(0.4)
                      : cs.onSurface,
                  fontStyle: _aiPersona.isEmpty ? FontStyle.italic : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
