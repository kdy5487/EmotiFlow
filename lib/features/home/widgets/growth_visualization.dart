import 'package:flutter/material.dart';
import '../models/growth_status.dart';

/// 감정 씨앗 성장 시각화 위젯
class GrowthVisualization extends StatelessWidget {
  final GrowthStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onWriteButtonTap;

  const GrowthVisualization({
    super.key,
    required this.status,
    this.onTap,
    this.onWriteButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 성장 단계 이미지
            _buildGrowthImage(),
            const SizedBox(height: 16),

            // 단계 이름
            Text(
              '${status.stageName} 단계',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // 연속 기록 일수
            _buildStreakInfo(theme),
            const SizedBox(height: 16),

            // 안내 텍스트
            Text(
              '일기를 작성하면 씨앗이 자라요!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // 진행률 바
            if (status.currentLevel < 4) _buildProgressBar(theme),

            // 일기 작성 버튼 (진행률 바 바로 아래)
            if (onWriteButtonTap != null) ...[
              const SizedBox(height: 16),
              _buildWriteButton(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthImage() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStageColor().withOpacity(0.1),
      ),
      child: Center(
        child: Text(
          status.stageEmoji,
          style: const TextStyle(fontSize: 100),
        ),
      ),
    );
  }

  Widget _buildStreakInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            '${status.consecutiveDays}일 연속 기록 중',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF6B35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '다음 단계까지',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              '${status.daysToNextLevel}일 남음',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getStageColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: status.progressToNextLevel,
            minHeight: 8,
            backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(_getStageColor()),
          ),
        ),
      ],
    );
  }

  Widget _buildWriteButton(ThemeData theme) {
    return GestureDetector(
      onTap: onWriteButtonTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _getStageColor(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              '오늘의 일기 작성하기',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStageColor() {
    switch (status.currentLevel) {
      case 0:
        return const Color(0xFF9E9E9E); // 회색
      case 1:
        return const Color(0xFF8BC34A); // 연두
      case 2:
        return const Color(0xFF4CAF50); // 초록
      case 3:
        return const Color(0xFF2E7D32); // 짙은 초록
      case 4:
        return const Color(0xFFE91E63); // 분홍 (꽃)
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
