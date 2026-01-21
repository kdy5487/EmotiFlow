import 'dart:io';
import 'package:flutter/material.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';

class DetailMediaSection extends StatelessWidget {
  final DiaryEntry entry;

  const DetailMediaSection({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildThumbnail(file.url),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildMissingThumbnail();
        },
      );
    }

    final file = File(url);
    if (!file.existsSync()) {
      return _buildMissingThumbnail();
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildMissingThumbnail();
      },
    );
  }

  Widget _buildMissingThumbnail() {
    return Container(
      color: AppTheme.background,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image, color: AppTheme.textTertiary, size: 28),
          SizedBox(height: 6),
          Text(
            '이미지 없음',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    if (!imageUrl.startsWith('http://') &&
        !imageUrl.startsWith('https://') &&
        !File(imageUrl).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지를 찾을 수 없습니다.')),
      );
      return;
    }
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
            child: Icon(Icons.error, color: Colors.white, size: 64),
          );
        },
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.error, color: Colors.white, size: 64),
          );
        },
      );
    }
  }
}
