import 'package:flutter/material.dart';
import 'package:emoti_flow/theme/app_theme.dart';

class BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color primaryColor;
  final double maxValue;

  BarChartPainter({
    required this.data,
    required this.labels,
    required this.primaryColor,
    this.maxValue = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // 여백 설정 - 가로 공간 최대 활용
    const double padding = 25;
    const double bottomPadding = 70;
    final double chartWidth = size.width - (padding * 2);
    final double chartHeight = size.height - padding - bottomPadding;

    // 막대 너비 계산 - 더 넓은 막대와 적은 간격
    final double barWidth = chartWidth / data.length * 0.85; // 85% 너비 사용
    final double barSpacing = chartWidth / data.length * 0.15; // 15% 간격

    // 배경 그리드 그리기
    _drawGrid(canvas, size, padding, bottomPadding, chartHeight);

    // 막대 그래프 그리기
    for (int i = 0; i < data.length; i++) {
      final double barHeight = (data[i] / maxValue) * chartHeight;
      final double x = padding + (i * (barWidth + barSpacing)) + (barSpacing / 2);
      final double y = size.height - bottomPadding - barHeight;

      // 그라디언트 효과
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor,
          primaryColor.withOpacity(0.6),
        ],
      );

      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      paint.shader = gradient.createShader(rect);

      // 막대 그리기 (둥근 모서리)
      final roundedRect = RRect.fromRectAndRadius(
        rect,
        const Radius.circular(8),
      );
      canvas.drawRRect(roundedRect, paint);

      // 값 표시 (막대 위에)
      textPainter.text = TextSpan(
        text: data[i].toStringAsFixed(1),
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + (barWidth - textPainter.width) / 2,
          y - textPainter.height - 8,
        ),
      );

      // 라벨 표시 (막대 아래)
      if (i < labels.length) {
        textPainter.text = TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x + (barWidth - textPainter.width) / 2,
            size.height - bottomPadding + 12,
          ),
        );
      }
    }

    // Y축 값 표시
    _drawYAxisLabels(canvas, size, padding, bottomPadding, chartHeight);
  }

  void _drawGrid(Canvas canvas, Size size, double padding, double bottomPadding, double chartHeight) {
    final gridPaint = Paint()
      ..color = AppTheme.border.withOpacity(0.3)
      ..strokeWidth = 1;

    // 수평 그리드 라인 (Y축 기준선)
    for (int i = 0; i <= 5; i++) {
      final y = size.height - bottomPadding - (i / 5) * chartHeight;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }
  }

  void _drawYAxisLabels(Canvas canvas, Size size, double padding, double bottomPadding, double chartHeight) {
    final textPainter = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= 5; i++) {
      final value = (i / 5) * maxValue;
      final y = size.height - bottomPadding - (i / 5) * chartHeight;

      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(padding - textPainter.width - 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
