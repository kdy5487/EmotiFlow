import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/firestore_provider.dart';
import '../../models/diary_entry.dart';
import '../../../../theme/app_theme.dart';
import 'dart:io';

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
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      
      // 오류 발생 시
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
      
      // 데이터 표시
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
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('일기 상세'),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => _showAIDetailedAnalysis(diaryEntry),
                icon: const Icon(Icons.psychology),
                tooltip: 'AI 상세 분석',
              ),
              IconButton(
                onPressed: () => _showMoreOptions(diaryEntry),
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                        // 헤더 섹션
        _buildHeaderSection(diaryEntry),
        const SizedBox(height: 16),
        
        // 감정 섹션
        if (diaryEntry.emotions.isNotEmpty) ...[
          _buildEmotionsSection(diaryEntry),
          const SizedBox(height: 24),
        ],
                
                // 미디어 섹션
                if (diaryEntry.mediaFiles.isNotEmpty) ...[
                  _buildMediaSection(diaryEntry),
                  const SizedBox(height: 24),
                ],
                
                // 일기 내용
                _buildContentSection(diaryEntry),
                const SizedBox(height: 24),
                
                // AI 간단 조언
                _buildAISimpleAdvice(diaryEntry),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 헤더 섹션 (날짜, 제목)
  Widget _buildHeaderSection(DiaryEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜와 시간
        Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(entry.createdAt),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 16),
            const Icon(
              Icons.access_time,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(entry.createdAt),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 제목
        if (entry.title.isNotEmpty) ...[
          Text(
            entry.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  /// 감정 섹션
  Widget _buildEmotionsSection(DiaryEntry entry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.emoji_emotions,
                color: AppTheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '오늘의 감정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: entry.emotions.map((emotion) {
              final intensity = entry.emotionIntensities[emotion] ?? 5;
              return _buildEmotionChip(emotion, intensity);
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 감정 칩 위젯
  Widget _buildEmotionChip(String emotion, int intensity) {
    // 감정별 색상 매핑
    final emotionColors = {
      '기쁨': AppTheme.success,
      '감사': AppTheme.success,
      '평온': AppTheme.info,
      '설렘': AppTheme.warning,
      '슬픔': AppTheme.error,
      '분노': AppTheme.error,
      '걱정': AppTheme.warning,
      '지루함': AppTheme.textTertiary,
    };
    
    final color = emotionColors[emotion] ?? AppTheme.primary;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emotion,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$intensity',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 미디어 섹션
  Widget _buildMediaSection(DiaryEntry entry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.photo_library,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '첨부된 미디어',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${entry.mediaFiles.length}개',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: entry.mediaFiles.length,
            itemBuilder: (context, index) {
              final file = entry.mediaFiles[index];
              return GestureDetector(
                onTap: () => _showFullScreenImage(context, file.url),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: _getImageProvider(file.url),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// AI 간단 조언 섹션
  Widget _buildAISimpleAdvice(DiaryEntry entry) {
    final emotion = entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
    final advice = _generateSimpleAIAdvice(emotion);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: AppTheme.info),
              SizedBox(width: 8),
              Text(
                'AI 간단 조언',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.info,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advice,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primary,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '앱바의 🧠 아이콘을 눌러 더 자세한 AI 분석을 확인할 수 있습니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 간단한 AI 조언 생성
  String _generateSimpleAIAdvice(String emotion) {
    switch (emotion) {
      case '기쁨':
        return '정말 기쁜 하루였네요! 이런 긍정적인 감정을 오래 유지하기 위해 감사한 일들을 더 기록해보세요.';
      case '사랑':
        return '사랑이 가득한 하루였군요. 주변 사람들에게 더 많은 관심과 사랑을 나누어보세요.';
      case '평온':
        return '차분하고 평온한 마음으로 하루를 마무리했네요. 이 평온함을 기록하고 감사해보세요.';
      case '슬픔':
        return '힘든 시간을 보내고 계시는군요. 자신에게 친절하게 대하고 충분한 휴식을 취하세요.';
      case '분노':
        return '화가 나는 일이 있었나요? 깊은 호흡을 통해 감정을 진정시키고, 산책이나 운동으로 스트레스를 해소해보세요.';
      case '두려움':
        return '불안하고 걱정되는 마음이 드시나요? 현재에 집중하는 명상이나 요가를 시도해보세요.';
      case '놀람':
        return '예상치 못한 일이 있었나요? 새로운 경험을 긍정적으로 받아들이고 성장의 기회로 삼아보세요.';
      case '중립':
        return '차분하게 하루를 마무리했네요. 내일은 더 특별한 순간들을 만들어보세요.';
      default:
        return '오늘 하루도 수고하셨습니다. 내일은 더 좋은 하루가 될 거예요!';
    }
  }

  /// 일기 내용 섹션
  Widget _buildContentSection(DiaryEntry entry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.edit_note,
                color: AppTheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '일기 내용',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            entry.content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: AppTheme.textPrimary,
            ),
          ),
          

        ],
      ),
    );
  }

  /// 일기 편집
  void _editDiary(DiaryEntry entry) {
    // TODO: 일기 편집 페이지로 이동
    context.push('/diary/write', extra: entry);
  }

  /// 이미지 프로바이더 생성 (로컬 파일 또는 네트워크)
  ImageProvider _getImageProvider(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    } else {
      return FileImage(File(url));
    }
  }

  /// 전체화면 이미지 표시
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              boundaryMargin: EdgeInsets.zero,
              minScale: 0.5,
              maxScale: 4.0,
              child: _buildFullScreenImage(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  /// 전체화면 이미지 위젯
  Widget _buildFullScreenImage(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.error,
              color: Colors.white,
              size: 64,
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.error,
              color: Colors.white,
              size: 64,
            ),
          );
        },
      );
    }
  }

  /// AI 대화 기록 표시
  void _showAIChatHistory(DiaryEntry entry) {
    // 디버깅을 위한 로그 추가
    print('AI 대화 기록 표시: ${entry.chatHistory.length}개 메시지');
    for (int i = 0; i < entry.chatHistory.length; i++) {
      final message = entry.chatHistory[i];
      print('메시지 $i: isFromAI=${message.isFromAI}, content=${message.content.substring(0, message.content.length > 50 ? 50 : message.content.length)}...');
    }
    
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
                            color: isAI 
                                ? AppTheme.primary
                                : AppTheme.textTertiary,
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
                            fontSize: 10,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
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
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  /// 추후 개발 예정 기능 안내 다이얼로그
  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.construction, color: Colors.orange),
              const SizedBox(width: 8),
              Text('$featureName'),
            ],
          ),
          content: const Text(
            '이 기능은 현재 개발 중입니다.\n\n추후 업데이트를 통해 제공될 예정이니\n잠시만 기다려주세요!',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  /// AI 상세 분석 표시
  void _showAIDetailedAnalysis(DiaryEntry entry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.psychology, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text('AI 상세 분석'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 일기 요약
                _buildDiarySummary(entry),
                const SizedBox(height: 20),
                
                // 주간 조언
                _buildWeeklyAdvice(entry),
                const SizedBox(height: 20),
                
                // 월간 조언
                _buildMonthlyAdvice(entry),
                const SizedBox(height: 20),
                
                // 오늘의 조언 카드
                _buildTodayAdviceCard(entry),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  /// 일기 요약 섹션
  Widget _buildDiarySummary(DiaryEntry entry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.summarize, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                '일기 요약',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${entry.title.isNotEmpty ? entry.title : '제목 없음'}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.content.length > 100 
                ? '${entry.content.substring(0, 100)}...'
                : entry.content,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                '주요 감정: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (entry.emotions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.emotions.first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 주간 조언 섹션
  Widget _buildWeeklyAdvice(DiaryEntry entry) {
    final emotion = entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today, color: AppTheme.secondary),
              SizedBox(width: 8),
              Text(
                '주간 조언',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _generateWeeklyAdvice(emotion),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 월간 조언 섹션
  Widget _buildMonthlyAdvice(DiaryEntry entry) {
    final emotion = entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, color: AppTheme.warning),
              SizedBox(width: 8),
              Text(
                '월간 조언',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warning,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _generateMonthlyAdvice(emotion),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 오늘의 조언 카드 섹션
  Widget _buildTodayAdviceCard(DiaryEntry entry) {
    final emotion = entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
    final adviceCards = _generateAdviceCards(emotion);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.card_giftcard, color: AppTheme.info),
              SizedBox(width: 8),
              Text(
                '오늘의 조언 카드',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.info,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '3개의 카드 중 하나를 선택해서 오늘의 조언을 받아보세요! ✨',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: adviceCards.map((card) {
              final index = adviceCards.indexOf(card);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < adviceCards.length - 1 ? 12 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => _showAdviceCardDetail(card),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 120,
                      decoration: BoxDecoration(
                        color: card['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: card['color'].withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            card['icon'],
                            size: 24,
                            color: card['color'],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            card['title'],
                            style: TextStyle(
                              color: card['color'],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '터치하기',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 주간 조언 생성
  String _generateWeeklyAdvice(String emotion) {
    switch (emotion) {
      case '기쁨':
        return '이번 주는 매우 긍정적인 감정을 유지하고 있습니다. 이런 좋은 기운을 주변 사람들과 나누어보세요. 주말에는 새로운 취미나 활동을 시도해보는 것도 좋겠습니다.';
      case '사랑':
        return '사랑이 가득한 한 주를 보내고 계시는군요. 주변 사람들에게 더 많은 관심과 사랑을 표현해보세요. 작은 선물이나 따뜻한 말 한마디가 큰 기쁨을 줄 수 있습니다.';
      case '평온':
        return '차분하고 평온한 마음으로 한 주를 마무리하고 있습니다. 이 평온함을 유지하기 위해 규칙적인 생활 리듬을 지켜보세요. 명상이나 요가도 도움이 될 것입니다.';
      case '슬픔':
        return '힘든 시간을 보내고 계시는군요. 자신에게 친절하게 대하고 충분한 휴식을 취하세요. 신뢰할 수 있는 사람과 대화하는 것도 좋은 방법입니다.';
      case '분노':
        return '화가 나는 일이 있었나요? 깊은 호흡을 통해 감정을 진정시키고, 산책이나 운동으로 스트레스를 해소해보세요. 감정을 글로 적어보는 것도 도움이 됩니다.';
      case '두려움':
        return '불안하고 걱정되는 마음이 드시나요? 현재에 집중하는 명상이나 요가를 시도해보세요. 걱정을 글로 적어보고 해결 가능한 것과 불가능한 것을 구분해보세요.';
      default:
        return '이번 주는 다양한 감정을 경험하고 있습니다. 감정의 변화를 자연스럽게 받아들이고, 각각의 감정에서 배울 점이 있는지 생각해보세요.';
    }
  }

  /// 월간 조언 생성
  String _generateMonthlyAdvice(String emotion) {
    switch (emotion) {
      case '기쁨':
        return '이번 달은 전반적으로 긍정적인 감정을 유지하고 있습니다. 이런 좋은 기운을 더 오래 유지하기 위해 감사 일기를 써보세요. 매일 감사한 일 3가지를 적어보는 습관을 만들어보세요.';
      case '사랑':
        return '사랑이 가득한 한 달을 보내고 계시는군요. 주변 사람들과의 관계를 더욱 깊게 만들어보세요. 정기적인 만남이나 대화 시간을 가지는 것도 좋겠습니다.';
      case '평온':
        return '차분하고 평온한 마음으로 한 달을 마무리하고 있습니다. 이 평온함을 유지하기 위해 규칙적인 생활 리듬과 명상 습관을 만들어보세요.';
      case '슬픔':
        return '힘든 시간을 보내고 계시는군요. 전문가와의 상담을 고려해보세요. 자신에게 친절하게 대하고 충분한 휴식을 취하는 것이 중요합니다.';
      case '분노':
        return '화가 나는 일들이 있었나요? 감정 관리 방법을 배우고 실천해보세요. 깊은 호흡, 운동, 명상 등이 도움이 될 것입니다.';
      case '두려움':
        return '불안하고 걱정되는 마음이 드시나요? 현재에 집중하는 명상이나 요가를 정기적으로 해보세요. 걱정을 글로 적어보는 습관도 만들어보세요.';
      default:
        return '이번 달은 다양한 감정을 경험하고 있습니다. 감정의 변화를 자연스럽게 받아들이고, 각각의 감정에서 배울 점이 있는지 생각해보세요.';
    }
  }

  /// 조언 카드 생성
  List<Map<String, dynamic>> _generateAdviceCards(String emotion) {
    final List<Map<String, dynamic>> allCards = [
      {
        'title': '자연과 함께',
        'advice': '오늘은 자연 속에서 시간을 보내보세요. 나무, 꽃, 하늘을 바라보며 마음을 정리해보세요.',
        'icon': Icons.park,
        'color': AppTheme.success,
      },
      {
        'title': '감사의 마음',
        'advice': '오늘 하루 감사한 일들을 3가지 적어보세요. 감사는 행복의 시작입니다.',
        'icon': Icons.favorite,
        'color': AppTheme.error,
      },
      {
        'title': '새로운 시작',
        'advice': '오늘은 새로운 취미를 시작해보세요. 작은 변화가 큰 기쁨을 가져올 수 있어요.',
        'icon': Icons.auto_awesome,
        'color': AppTheme.warning,
      },
      {
        'title': '마음 정리',
        'advice': '창문을 열고 신선한 공기를 마시며 깊은 호흡을 해보세요. 마음이 차분해질 거예요.',
        'icon': Icons.air,
        'color': AppTheme.info,
      },
      {
        'title': '관계 개선',
        'advice': '주변 사람들에게 따뜻한 말 한마디를 건네보세요. 당신의 작은 관심이 누군가에게는 큰 힘이 됩니다.',
        'icon': Icons.people,
        'color': AppTheme.primary,
      },
      {
        'title': '자기 돌봄',
        'advice': '자신에게 작은 선물을 해보세요. 좋아하는 음식을 먹거나 원하는 물건을 사보세요.',
        'icon': Icons.spa,
        'color': AppTheme.secondary,
      },
    ];
    
    // 감정에 따라 3개 카드 선택
    final selectedCards = <Map<String, dynamic>>[];
    final random = DateTime.now().millisecond;
    
    for (int i = 0; i < 3; i++) {
      final index = (random + i) % allCards.length;
      selectedCards.add(allCards[index]);
    }
    
    return selectedCards;
  }

  /// 조언 카드 상세 보기
  void _showAdviceCardDetail(Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(card['icon'], color: card['color']),
            const SizedBox(width: 8),
            Text(card['title']),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: card['color'].withOpacity(0.3)),
              ),
              child: Text(
                card['advice'],
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 삭제 확인 다이얼로그 표시
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
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDiary(entry);
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

  /// 일기 삭제 실행
  Future<void> _deleteDiary(DiaryEntry entry) async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Firestore에서 일기 삭제
      await ref.read(firestoreProvider).deleteDiary(entry.id);
      
      // 로딩 다이얼로그 닫기
      Navigator.pop(context);
      
      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('일기가 삭제되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 일기 목록으로 돌아가기
      context.pop();
      
    } catch (e) {
      // 로딩 다이얼로그 닫기
      Navigator.pop(context);
      
      // 오류 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('삭제 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          if (entry.diaryType == DiaryType.aiChat && entry.chatHistory.isNotEmpty)
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

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 시간 포맷팅
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
