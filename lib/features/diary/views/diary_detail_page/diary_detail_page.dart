import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/firestore_provider.dart';
import '../../models/diary_entry.dart';


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
  double _gridItemHeight = 120;
  @override
  Widget build(BuildContext context) {
    // Riverpod Provider를 사용해서 일기 데이터 가져오기
    final diaryAsync = ref.watch(diaryDetailProvider(widget.diaryId));
    
    return diaryAsync.when(
      // 로딩 중
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('일기 상세'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      
      // 오류 발생 시
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: const Text('일기 상세'),
          backgroundColor: AppColors.primary,
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
                style: AppTypography.titleLarge.copyWith(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '오류: $error',
                style: AppTypography.bodyMedium.copyWith(
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
      
      // 데이터 표시
      data: (diaryEntry) {
        if (diaryEntry == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('일기 상세'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('일기를 찾을 수 없습니다.'),
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('일기 상세'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () => _editDiary(diaryEntry),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () => _showMoreOptions(diaryEntry),
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDiaryHeader(diaryEntry),
                const SizedBox(height: 4),
                if (diaryEntry.mediaCount > 0) ...[
                  _buildMediaGrid(diaryEntry),
                  const SizedBox(height: 4),
                ],
                // AI 생성 이미지 표시 (채팅 일기인 경우)
                if (diaryEntry.diaryType == DiaryType.aiChat && diaryEntry.metadata?['aiGeneratedImage'] != null) ...[
                  _buildAIGeneratedImage(diaryEntry),
                  const SizedBox(height: 4),
                ],
                _buildDiaryContent(diaryEntry),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 일기 편집
  void _editDiary(DiaryEntry entry) {
    // TODO: 일기 편집 페이지로 이동
    context.push('/diary/write', extra: entry);
  }

  /// 더 많은 옵션 표시
  void _showMoreOptions(DiaryEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('공유'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 공유 기능 구현
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('삭제'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 삭제 기능 구현
            },
          ),
        ],
      ),
    );
  }

  /// 일기 헤더 구성
  Widget _buildDiaryHeader(DiaryEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜와 시간
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              _formatDate(entry.createdAt),
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              _formatTime(entry.createdAt),
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 제목
        if (entry.title.isNotEmpty) ...[
          Text(
            entry.title,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // 감정 표시
        if (entry.emotions.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            children: entry.emotions.map((emotion) {
              final intensity = entry.emotionIntensities[emotion] ?? 5;
              return Chip(
                label: Text('$emotion ($intensity/10)'),
                backgroundColor: AppColors.primary.withOpacity(0.1),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  /// 미디어 그리드 구성
  Widget _buildMediaGrid(DiaryEntry entry) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: entry.mediaFiles.length,
      itemBuilder: (context, index) {
        final file = entry.mediaFiles[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(file.url),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  /// AI 생성 이미지 표시
  Widget _buildAIGeneratedImage(DiaryEntry entry) {
    final imageUrl = entry.metadata?['aiGeneratedImage'] as String?;
    if (imageUrl == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI 생성 이미지',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  /// 일기 내용 구성
  Widget _buildDiaryContent(DiaryEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '일기 내용',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.content,
          style: AppTypography.bodyLarge,
        ),
        
        // AI 대화 히스토리 표시 (채팅 일기인 경우)
        if (entry.diaryType == DiaryType.aiChat && entry.chatHistory.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'AI 대화 기록',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...entry.chatHistory.map((message) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isFromAI 
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.isFromAI ? 'AI' : '나',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: message.isFromAI 
                        ? AppColors.primary 
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(message.content, style: AppTypography.bodyMedium),
              ],
            ),
          )),
        ],
      ],
    );
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 시간 포맷팅
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
