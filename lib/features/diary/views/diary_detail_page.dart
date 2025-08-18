import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/diary_provider.dart';
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
  DiaryEntry? _diaryEntry;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiaryEntry();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('일기 상세'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_diaryEntry == null) {
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
            onPressed: () => _editDiary(),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _showMoreOptions(),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 일기 헤더
            _buildDiaryHeader(),
            const SizedBox(height: 24),
            
            // 감정 정보
            _buildEmotionInfo(),
            const SizedBox(height: 24),
            
            // 일기 내용
            _buildDiaryContent(),
            const SizedBox(height: 24),
            
            // AI 분석 결과
            if (_diaryEntry!.hasAIAnalysis) ...[
              _buildAIAnalysisSection(),
              const SizedBox(height: 24),
            ],
            
            // AI 대화 히스토리
            if (_diaryEntry!.hasChatHistory) ...[
              _buildChatHistorySection(),
              const SizedBox(height: 24),
            ],
            
            // 미디어 섹션
            if (_diaryEntry!.mediaCount > 0) ...[
              _buildMediaSection(),
              const SizedBox(height: 24),
            ],
            
            // 태그 섹션
            if (_diaryEntry!.tags.isNotEmpty) ...[
              _buildTagSection(),
              const SizedBox(height: 24),
            ],
            
            // 메타데이터
            _buildMetadataSection(),
            const SizedBox(height: 24),
            
            // 액션 버튼들
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// 일기 헤더
  Widget _buildDiaryHeader() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 및 시간
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  _formatDate(_diaryEntry!.createdAt),
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(_diaryEntry!.createdAt),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 제목
            if (_diaryEntry!.title.isNotEmpty)
              Text(
                _diaryEntry!.title,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            
            // 공개 여부
            if (_diaryEntry!.isPublic)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.public, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      '공개',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 감정 정보
  Widget _buildEmotionInfo() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 감정',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // 감정 목록
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _diaryEntry!.emotions.map((emotionName) {
                final emotion = Emotion.findByName(emotionName);
                if (emotion == null) return const SizedBox.shrink();
                
                final intensity = _diaryEntry!.emotionIntensities[emotionName] ?? 5;
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: emotion.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: emotion.color.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        emotion.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emotion.name,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: emotion.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '강도: $intensity',
                        style: AppTypography.caption.copyWith(
                          color: emotion.color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // 감정 요약
            Row(
              children: [
                Icon(Icons.insights, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '감정 요약',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMoodTypeColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getMoodTypeLabel(),
                    style: AppTypography.caption.copyWith(
                      color: _getMoodTypeColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 일기 내용
  Widget _buildDiaryContent() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '일기 내용',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              _diaryEntry!.content,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 통계 정보
            Row(
              children: [
                Icon(Icons.text_fields, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${_diaryEntry!.contentLength}자',
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.format_list_bulleted, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${_diaryEntry!.wordCount}단어',
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
  Widget _buildAIAnalysisSection() {
    final analysis = _diaryEntry!.aiAnalysis!;
    
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'AI 감정 분석',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 요약
            if (analysis.summary.isNotEmpty) ...[
              _buildAnalysisItem('요약', analysis.summary, Icons.summarize),
              const SizedBox(height: 16),
            ],
            
            // 키워드
            if (analysis.keywords.isNotEmpty) ...[
              _buildAnalysisItem('감정 키워드', analysis.keywords.join(', '), Icons.key),
              const SizedBox(height: 16),
            ],
            
            // 조언
            if (analysis.advice.isNotEmpty) ...[
              _buildAnalysisItem('AI 조언', analysis.advice, Icons.lightbulb),
              const SizedBox(height: 16),
            ],
            
            // 액션 아이템
            if (analysis.actionItems.isNotEmpty) ...[
              _buildAnalysisItem('실행 가능한 액션', analysis.actionItems.join('\n• '), Icons.checklist),
              const SizedBox(height: 16),
            ],
            
            // 감정 트렌드
            if (analysis.moodTrend.isNotEmpty) ...[
              _buildAnalysisItem('감정 변화 트렌드', analysis.moodTrend, Icons.trending_up),
              const SizedBox(height: 16),
            ],
            
            // 분석 시간
            Text(
              '분석 시간: ${_formatDateTime(analysis.analyzedAt)}',
              style: AppTypography.caption.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// AI 대화 히스토리 섹션
  Widget _buildChatHistorySection() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.chat, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'AI와의 대화',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_diaryEntry!.chatHistory.length}개 메시지',
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 대화 내용 (최근 3개만 표시)
            ..._diaryEntry!.chatHistory
                .take(3)
                .map((message) => _buildChatMessage(message))
                .toList(),
            
            if (_diaryEntry!.chatHistory.length > 3) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '외 ${_diaryEntry!.chatHistory.length - 3}개 메시지',
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 채팅 메시지 위젯
  Widget _buildChatMessage(ChatMessage message) {
    final isAI = message.isFromAI;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAI) ...[
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: const Icon(Icons.psychology, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAI ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: isAI ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          
          if (!isAI) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.secondary,
              radius: 16,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  /// 미디어 섹션
  Widget _buildMediaSection() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.media_bluetooth_on, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '첨부된 미디어',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_diaryEntry!.mediaCount}개',
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 미디어 타입별 요약
            Row(
              children: [
                if (_diaryEntry!.imageCount > 0) ...[
                  _buildMediaTypeChip('이미지', _diaryEntry!.imageCount, Icons.image),
                  const SizedBox(width: 8),
                ],
                if (_diaryEntry!.drawingCount > 0) ...[
                  _buildMediaTypeChip('그림', _diaryEntry!.drawingCount, Icons.brush),
                  const SizedBox(width: 8),
                ],
                if (_diaryEntry!.voiceCount > 0) ...[
                  _buildMediaTypeChip('음성', _diaryEntry!.voiceCount, Icons.mic),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 미디어 미리보기 (실제 구현에서는 썸네일 표시)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Text('미디어 미리보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 미디어 타입 칩
  Widget _buildMediaTypeChip(String label, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            '$label $count',
            style: AppTypography.caption.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 태그 섹션
  Widget _buildTagSection() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.label, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '태그',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _diaryEntry!.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 메타데이터 섹션
  Widget _buildMetadataSection() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '추가 정보',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 날씨
            if (_diaryEntry!.weather != null) ...[
              _buildMetadataItem('날씨', _diaryEntry!.weather!, Icons.wb_sunny),
              const SizedBox(height: 8),
            ],
            
            // 위치
            if (_diaryEntry!.location != null) ...[
              _buildMetadataItem('위치', _diaryEntry!.location!, Icons.location_on),
              const SizedBox(height: 8),
            ],
            
            // 수정 시간
            if (_diaryEntry!.updatedAt != null) ...[
              _buildMetadataItem('수정 시간', _formatDateTime(_diaryEntry!.updatedAt!), Icons.edit),
            ],
          ],
        ),
      ),
    );
  }

  /// 메타데이터 아이템
  Widget _buildMetadataItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _editDiary,
            icon: const Icon(Icons.edit),
            label: const Text('편집'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareDiary,
            icon: const Icon(Icons.share),
            label: const Text('공유'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _deleteDiary,
            icon: const Icon(Icons.delete),
            label: const Text('삭제'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// 분석 아이템
  Widget _buildAnalysisItem(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// 일기 편집
  void _editDiary() {
    // TODO: 편집 페이지로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('편집 기능은 추후 구현 예정입니다.')),
    );
  }

  /// 일기 공유
  void _shareDiary() {
    // TODO: 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공유 기능은 추후 구현 예정입니다.')),
    );
  }

  /// 일기 삭제
  void _deleteDiary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일기 삭제'),
        content: const Text('정말로 이 일기를 삭제하시겠습니까?\n삭제된 일기는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _confirmDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  /// 삭제 확인
  Future<void> _confirmDelete() async {
    try {
      await ref.read(diaryProvider.notifier).deleteDiaryEntry(widget.diaryId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('일기가 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // 목록 페이지로 돌아가기
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 더보기 옵션
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('내보내기'),
            onTap: () {
              Navigator.of(context).pop();
              // TODO: 내보내기 기능 구현
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('복사'),
            onTap: () {
              Navigator.of(context).pop();
              // TODO: 복사 기능 구현
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('신고'),
            onTap: () {
              Navigator.of(context).pop();
              // TODO: 신고 기능 구현
            },
          ),
        ],
      ),
    );
  }

  /// 일기 데이터 로드
  Future<void> _loadDiaryEntry() async {
    try {
      final entry = await ref.read(diaryProvider.notifier).getDiaryEntry(widget.diaryId);
      setState(() {
        _diaryEntry = entry;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일기를 불러오는데 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 감정 타입 색상 반환
  Color _getMoodTypeColor() {
    switch (_diaryEntry!.moodType) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 감정 타입 라벨 반환
  String _getMoodTypeLabel() {
    switch (_diaryEntry!.moodType) {
      case 'positive':
        return '긍정적';
      case 'negative':
        return '부정적';
      default:
        return '중립적';
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
      return '${date.year}년 ${date.month}월 ${date.day}일';
    }
  }

  /// 시간 포맷팅
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 날짜 시간 포맷팅
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }
}
