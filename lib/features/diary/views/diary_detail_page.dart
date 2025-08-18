import 'package:flutter/material.dart';
import 'dart:io';
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
                _buildDiaryContent(diaryEntry),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 헤더(날짜는 오른쪽, 제목은 크게)
  Widget _buildDiaryHeader(DiaryEntry entry) {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.title,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(entry.createdAt),
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      _formatTime(entry.createdAt),
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            if (entry.emotions.isNotEmpty) ...[
              const SizedBox(height: 4),
              _buildInlineEmotions(entry),
            ],
          ],
        ),
      ),
    );
  }

  /// 단순 미디어 그리드 (사진/그림 구분 없이)
  Widget _buildMediaGrid(DiaryEntry entry) {
    final files = entry.mediaFiles;
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 4 / 3,
              ),
              itemCount: files.length,
              itemBuilder: (context, i) {
                final url = files[i].url;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildAnyImage(url, height: _gridItemHeight),
                );
              },
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      _gridItemHeight = (_gridItemHeight - 10).clamp(90, 180);
                    });
                  },
                  tooltip: '작게',
                ),
                Text('${_gridItemHeight.toInt()}px', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _gridItemHeight = (_gridItemHeight + 10).clamp(90, 180);
                    });
                  },
                  tooltip: '크게',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineEmotions(DiaryEntry entry) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: entry.emotions.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            e,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnyImage(String url, {double? width, double? height}) {
    final isNetwork = url.startsWith('http');
    final isFile = url.startsWith('/') || url.startsWith('file:');
    if (isNetwork) {
      return Image.network(url, width: width, height: height, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image)),
      );
    }
    if (isFile) {
      return Image.file(File(url), width: width, height: height, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image)),
      );
    }
    return Image.asset(url, width: width, height: height, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image)),
    );
  }

  /// 간결한 감정 칩
  Widget _buildCompactEmotions(DiaryEntry entry) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entry.emotions.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(
            e,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 내용
  Widget _buildDiaryContent(DiaryEntry entry) {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          entry.content,
          style: AppTypography.bodyLarge.copyWith(height: 1.5, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  // 아래 함수들은 기존 파일에 이미 존재 (삭제하지 않음)
  void _editDiary(DiaryEntry entry) {
    // TODO: 일기 수정 페이지로 이동
    print('일기 수정: ${entry.id}');
  }

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

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
