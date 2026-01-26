import 'package:flutter/material.dart';
import 'package:emoti_flow/theme/app_theme.dart';

class DotChartPainter extends CustomPainter {
  final Map<String, double> emotionData; // 감정별 상대적 수치 (0-10)
  final Color primaryColor;
  final bool isDark;

  DotChartPainter({
    required this.emotionData,
    required this.primaryColor,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (emotionData.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    const double padding = 40;
    const double bottomPadding = 80;
    final double chartWidth = size.width - (padding * 2);
    final double chartHeight = size.height - padding - bottomPadding;
    final double maxValue = 10.0;

    // 배경 그리드 그리기
    _drawGrid(canvas, size, padding, bottomPadding, chartHeight);

    // 감정별 점 그리기
    final sortedEmotions = emotionData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final dotSize = 12.0;
    final spacing = chartWidth / (sortedEmotions.length + 1);

    for (int i = 0; i < sortedEmotions.length; i++) {
      final entry = sortedEmotions[i];
      final emotion = entry.key;
      final value = entry.value;

      // Y 위치 계산 (10점이 최상단)
      final y = size.height - bottomPadding - (value / maxValue) * chartHeight;
      final x = padding + spacing * (i + 1);

      // 점 그리기
      paint.color = primaryColor;
      canvas.drawCircle(Offset(x, y), dotSize, paint);

      // 외곽선
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      paint.color = isDark ? Colors.white : Colors.black;
      canvas.drawCircle(Offset(x, y), dotSize, paint);
      paint.style = PaintingStyle.fill;

      // 값 표시 (점 위에)
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: TextStyle(
          color: isDark ? Colors.white : AppTheme.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - dotSize - textPainter.height - 4),
      );

      // 감정 라벨 표시 (점 아래)
      textPainter.text = TextSpan(
        text: emotion,
        style: TextStyle(
          color: isDark ? Colors.white70 : AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - bottomPadding + 8),
      );
    }

    // Y축 값 표시
    _drawYAxisLabels(canvas, size, padding, bottomPadding, chartHeight);
  }

  void _drawGrid(Canvas canvas, Size size, double padding, double bottomPadding,
      double chartHeight) {
    final gridPaint = Paint()
      ..color = isDark 
          ? Colors.white.withOpacity(0.1)
          : AppTheme.border.withOpacity(0.3)
      ..strokeWidth = 1;

    // 수평 그리드 라인 (0-10점)
    for (int i = 0; i <= 10; i++) {
      final y = size.height - bottomPadding - (i / 10) * chartHeight;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }
  }

  void _drawYAxisLabels(Canvas canvas, Size size, double padding,
      double bottomPadding, double chartHeight) {
    final textPainter = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= 10; i += 2) {
      final y = size.height - bottomPadding - (i / 10) * chartHeight;

      textPainter.text = TextSpan(
        text: '$i',
        style: TextStyle(
          color: isDark ? Colors.white70 : AppTheme.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(padding - textPainter.width - 4, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

