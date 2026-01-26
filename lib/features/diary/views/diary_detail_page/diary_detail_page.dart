import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/firestore_provider.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/entities/chat_message.dart';
import '../../../../theme/app_theme.dart';
import 'widgets/detail_app_bar.dart';
import 'widgets/detail_hero_section.dart';
import 'widgets/detail_media_section.dart';
import 'widgets/detail_ai_advice_section.dart';
import 'widgets/ai_analysis_dialog.dart';
import '../../../../shared/constants/emotion_character_map.dart';

/// 일기 상세 페이지
class DiaryDetailPage extends ConsumerStatefulWidget {
  final String diaryId;

  const DiaryDetailPage({
    super.key,
    required this.diaryId,
  });

  @override
  ConsumerState<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends ConsumerState<DiaryDetailPage> {
  @override
  Widget build(BuildContext context) {
    // Riverpod Provider를 사용해서 일기 데이터 가져오기
    final diaryAsync = ref.watch(diaryDetailProvider(widget.diaryId));

    return diaryAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('일기 상세'),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: const Text('일기 상세'),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                '일기를 불러올 수 없습니다',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.red[600],
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '오류: $error',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('뒤로 가기'),
              ),
            ],
          ),
        ),
      ),
      data: (diaryEntry) {
        if (diaryEntry == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('일기 상세'),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('일기를 찾을 수 없습니다.'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: DetailAppBar(
            diaryEntry: diaryEntry,
            onAnalysisTap: () => _showAIDetailedAnalysis(diaryEntry),
            onMoreTap: () => _showMoreOptions(diaryEntry),
          ),
          body: SafeArea(
            child: Builder(
            builder: (context) {
              final primaryEmotion = diaryEntry.emotions.isNotEmpty 
                  ? diaryEntry.emotions.first 
                  : null;
              final backgroundColor = primaryEmotion != null
                  ? EmotionCharacterMap.getBackgroundColor(primaryEmotion)
                  : 0xFFFFFDF7; // 기본 크림색
              
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            Color(backgroundColor).withOpacity(0.2),
                            Color(backgroundColor).withOpacity(0.1),
                            Color(backgroundColor).withOpacity(0.05),
                            Theme.of(context).scaffoldBackgroundColor,
                            Theme.of(context).scaffoldBackgroundColor,
                          ]
                        : [
                            Color(backgroundColor).withOpacity(0.5),
                            Color(backgroundColor).withOpacity(0.3),
                            Color(backgroundColor).withOpacity(0.15),
                            Color(backgroundColor).withOpacity(0.08),
                            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                          ],
                    stops: const [0.0, 0.15, 0.35, 0.6, 1.0],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단 히어로 영역
                      DetailHeroSection(entry: diaryEntry),
                      const SizedBox(height: 24),
                      // 제목 영역 (배경색 없이)
                      if (diaryEntry.title.isNotEmpty) ...[
                        Text(
                          diaryEntry.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 22,
                              ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      // 본문 영역 (배경색 없이)
                      Text(
                        diaryEntry.content,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 이미지/그림 섹션
                      if (diaryEntry.mediaFiles.isNotEmpty) ...[
                        DetailMediaSection(entry: diaryEntry),
                        const SizedBox(height: 24),
                      ],
                      // AI 대화 내역 섹션 (AI 채팅 일기인 경우)
                      if (diaryEntry.diaryType == DiaryType.aiChat &&
                          diaryEntry.chatHistory.isNotEmpty) ...[
                        _buildChatHistorySection(diaryEntry),
                        const SizedBox(height: 24),
                      ],
                      // AI 조언 카드
                      DetailAISimpleAdvice(entry: diaryEntry),
                    ],
                  ),
                ),
              );
            },
            ),
          ),
        );
      },
    );
  }

  /// AI 상세 분석 표시
  void _showAIDetailedAnalysis(DiaryEntry entry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AIDetailedAnalysisDialog(entry: entry),
    );
  }

  /// 더 많은 옵션 표시
  void _showMoreOptions(DiaryEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('편집'),
            onTap: () {
              Navigator.pop(context);
              _editDiary(entry);
            },
          ),
          if (entry.diaryType == DiaryType.aiChat &&
              entry.chatHistory.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.chat_bubble),
              title: const Text('AI 대화 기록'),
              onTap: () {
                Navigator.pop(context);
                _showAIChatHistory(entry);
              },
            ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('공유'),
            subtitle: const Text('추후 개발 예정'),
            onTap: () {
              Navigator.pop(context);
              _showComingSoonDialog('공유 기능');
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('삭제', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmDialog(entry);
            },
          ),
        ],
      ),
    );
  }

  /// 일기 편집
  void _editDiary(DiaryEntry entry) {
    context.push('/diaries/write', extra: entry);
  }

  /// AI 대화 내역 섹션 빌드
  Widget _buildChatHistorySection(DiaryEntry entry) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryEmotion = entry.emotions.isNotEmpty 
        ? entry.emotions.first 
        : null;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI와의 대화',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAIChatHistory(entry),
                  child: Text(
                    '전체 보기',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: entry.chatHistory.take(3).map((message) {
                return _buildChatMessageItem(message, primaryEmotion);
              }).toList(),
            ),
          ),
          if (entry.chatHistory.length > 3)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Center(
                child: TextButton(
                  onPressed: () => _showAIChatHistory(entry),
                  child: Text(
                    '${entry.chatHistory.length - 3}개 더 보기',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 채팅 메시지 아이템 빌드
  Widget _buildChatMessageItem(ChatMessage message, String? emotion) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAI = message.isFromAI;
    final characterAsset = emotion != null
        ? EmotionCharacterMap.getCharacterAsset(emotion)
        : EmotionCharacterMap.getCharacterAsset(null);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAI) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  characterAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.psychology,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAI
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isAI ? 4 : 20),
                  topRight: Radius.circular(isAI ? 20 : 4),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                ),
              ),
              child: Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isAI
                      ? colorScheme.onSurface
                      : Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (!isAI) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: colorScheme.secondary,
              radius: 20,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// AI 대화 기록 전체 보기 다이얼로그
  void _showAIChatHistory(DiaryEntry entry) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryEmotion = entry.emotions.isNotEmpty 
        ? entry.emotions.first 
        : null;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.title.isNotEmpty ? entry.title : 'AI와의 대화',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // 대화 내역
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: entry.chatHistory.length,
                  itemBuilder: (context, index) {
                    return _buildChatMessageItem(
                      entry.chatHistory[index],
                      primaryEmotion,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog(DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('일기 삭제'),
          ],
        ),
        content: Text(
          '정말로 이 일기를 삭제하시겠습니까?\n\n"${entry.title.isNotEmpty ? entry.title : '제목 없음'}"\n\n삭제된 일기는 복구할 수 없습니다.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDiary(entry);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  /// 일기 삭제
  Future<void> _deleteDiary(DiaryEntry entry) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      await ref.read(firestoreProvider).deleteDiary(entry.id);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('일기가 삭제되었습니다'), backgroundColor: Colors.green));
      context.pop();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('삭제 중 오류가 발생했습니다: $e'), backgroundColor: Colors.red));
    }
  }

  /// 개발 중 안내
  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.construction, color: Colors.orange),
              const SizedBox(width: 8),
              Text(featureName),
            ],
          ),
          content: const Text(
              '이 기능은 현재 개발 중입니다.\n\n추후 업데이트를 통해 제공될 예정이니\n잠시만 기다려주세요!',
              textAlign: TextAlign.center),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'))
          ],
        );
      },
    );
  }

}
