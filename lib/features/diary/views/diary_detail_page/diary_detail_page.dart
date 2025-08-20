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
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(entry.createdAt),
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.access_time,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(entry.createdAt),
              style: TextStyle(
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
          Row(
            children: [
              Icon(
                Icons.emoji_emotions,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
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
              Icon(
                Icons.photo_library,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
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
                  style: TextStyle(
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
          Row(
            children: [
              Icon(
                Icons.edit_note,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
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
            style: TextStyle(
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
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.content,
                      style: TextStyle(
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

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 시간 포맷팅
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
