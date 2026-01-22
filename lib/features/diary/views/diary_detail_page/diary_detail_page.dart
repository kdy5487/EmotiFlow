import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/firestore_provider.dart';
import '../../domain/entities/diary_entry.dart';
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
          body: Builder(
            builder: (context) {
              final primaryEmotion = diaryEntry.emotions.isNotEmpty 
                  ? diaryEntry.emotions.first 
                  : null;
              final backgroundColor = primaryEmotion != null
                  ? EmotionCharacterMap.getBackgroundColor(primaryEmotion)
                  : 0xFFFFFDF7; // 기본 크림색
              
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(backgroundColor).withOpacity(0.3),
                      Color(backgroundColor).withOpacity(0.1),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    stops: const [0.0, 0.3, 1.0],
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
                                color: const Color(0xFF111827),
                                fontSize: 22,
                              ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      // 본문 영역 (배경색 없이)
                      Text(
                        diaryEntry.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 이미지/그림 섹션
                      if (diaryEntry.mediaFiles.isNotEmpty) ...[
                        DetailMediaSection(entry: diaryEntry),
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

  /// AI 대화 기록 표시
  void _showAIChatHistory(DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.title.isNotEmpty ? entry.title : 'AI 대화 기록'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: entry.chatHistory.length,
            itemBuilder: (context, index) {
              final message = entry.chatHistory[index];
              final isAI = message.isFromAI;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isAI
                      ? AppTheme.primary.withOpacity(0.1)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAI
                        ? AppTheme.primary.withOpacity(0.3)
                        : AppTheme.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color:
                                isAI ? AppTheme.primary : AppTheme.textTertiary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isAI ? Icons.smart_toy : Icons.person,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isAI ? 'AI' : '나',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isAI
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTime(message.timestamp),
                          style: const TextStyle(
                              fontSize: 10, color: AppTheme.textTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.content,
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기')),
        ],
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
