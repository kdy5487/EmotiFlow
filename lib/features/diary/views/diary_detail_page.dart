import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/diary_provider.dart';
import '../providers/firestore_provider.dart';
import '../models/diary_entry.dart';
import '../models/emotion.dart';

import '../../../shared/widgets/cards/emoti_card.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 일기 헤더
                _buildDiaryHeader(diaryEntry),
                const SizedBox(height: 12),
                
                // 감정 정보
                _buildEmotionInfo(diaryEntry),
                const SizedBox(height: 12),
                
                // 일기 내용
                _buildDiaryContent(diaryEntry),
                const SizedBox(height: 12),
                
                // AI 분석 결과
                if (diaryEntry.hasAIAnalysis) ...[
                  _buildAIAnalysisSection(diaryEntry),
                  const SizedBox(height: 12),
                ],
                
                // AI 대화 히스토리
                if (diaryEntry.hasChatHistory) ...[
                  _buildChatHistorySection(diaryEntry),
                  const SizedBox(height: 12),
                ],
                
                // 미디어 섹션
                if (diaryEntry.mediaCount > 0) ...[
                  _buildMediaSection(diaryEntry),
                  const SizedBox(height: 12),
                ],
                
                // 태그 섹션
                if (diaryEntry.tags.isNotEmpty) ...[
                  _buildTagSection(diaryEntry),
                  const SizedBox(height: 12),
                ],
                
                // 메타데이터
                _buildMetadataSection(diaryEntry),
                const SizedBox(height: 12),
                
                // 액션 버튼들
                _buildActionButtons(diaryEntry),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 일기 헤더
  Widget _buildDiaryHeader(DiaryEntry entry) {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 및 시간
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  _formatDate(entry.createdAt),
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(entry.createdAt),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // 제목
            Text(
              entry.title,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            // 일기 타입
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                entry.diaryType == DiaryType.aiChat ? 'AI 대화형' : '자유형',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 감정 정보
  Widget _buildEmotionInfo(DiaryEntry entry) {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 감정',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            
            if (entry.emotions.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.emotions.map((emotion) {
                  final intensity = entry.emotionIntensities[emotion] ?? 5;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          emotion,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$intensity',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              Text(
                '감정이 선택되지 않았습니다.',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 일기 내용
  Widget _buildDiaryContent(DiaryEntry entry) {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '일기 내용',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              entry.content,
              style: AppTypography.bodyLarge.copyWith(
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.text_fields, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${entry.contentLength}자',
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.format_list_bulleted, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${entry.wordCount}단어',
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// AI 분석 결과 섹션
  Widget _buildAIAnalysisSection(DiaryEntry entry) {
    if (entry.aiAnalysis == null) return const SizedBox.shrink();
    
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'AI 분석 결과',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 요약
            if (entry.aiAnalysis!.summary.isNotEmpty) ...[
              Text(
                '요약',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.aiAnalysis!.summary,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 조언
            if (entry.aiAnalysis!.advice.isNotEmpty) ...[
              Text(
                'AI 조언',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.aiAnalysis!.advice,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// AI 대화 히스토리 섹션
  Widget _buildChatHistorySection(DiaryEntry entry) {
    if (entry.chatHistory.isEmpty) return const SizedBox.shrink();
    
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.chat_bubble, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'AI 대화 히스토리',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              '${entry.chatHistory.length}개의 메시지',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 미디어 섹션
  Widget _buildMediaSection(DiaryEntry entry) {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_file, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '첨부 파일',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            Text(
              '이미지: ${entry.imageCount}개, 음성: ${entry.voiceCount}개, 그림: ${entry.drawingCount}개',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 태그 섹션
  Widget _buildTagSection(DiaryEntry entry) {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '태그',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tag,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 메타데이터 섹션
  Widget _buildMetadataSection(DiaryEntry entry) {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '추가 정보',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            if (entry.weather != null) ...[
              Row(
                children: [
                  Icon(Icons.wb_sunny, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '날씨: ${entry.weather}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            if (entry.location != null) ...[
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '위치: ${entry.location}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            Row(
              children: [
                Icon(Icons.public, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '공개 여부: ${entry.isPublic ? "공개" : "비공개"}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons(DiaryEntry entry) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _editDiary(entry),
            icon: const Icon(Icons.edit),
            label: const Text('수정'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _shareDiary(entry),
            icon: const Icon(Icons.share),
            label: const Text('공유'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  /// 일기 수정
  void _editDiary(DiaryEntry entry) {
    // TODO: 일기 수정 페이지로 이동
    print('일기 수정: ${entry.id}');
  }

  /// 일기 공유
  void _shareDiary(DiaryEntry entry) {
    // TODO: 일기 공유 기능
    print('일기 공유: ${entry.id}');
  }

  /// 더보기 옵션
  void _showMoreOptions(DiaryEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('삭제', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(entry);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('복사'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 일기 내용 복사
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('취소'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// 삭제 확인
  Future<void> _confirmDelete(DiaryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일기 삭제'),
        content: const Text('정말로 이 일기를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(firestoreProvider).deleteDiary(entry.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('일기가 삭제되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 실패: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate == today) {
      return '오늘';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return '어제';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }

  /// 시간 포맷팅
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
