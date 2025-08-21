import 'package:flutter/material.dart';
import 'package:emoti_flow/theme/app_theme.dart';

/// 선 그래프 그리기
class LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color color;

  LineChartPainter({
    required this.data,
    required this.labels,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // 차트 영역 계산
    const padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final valueRange = maxValue - minValue;

    if (valueRange == 0) return;

    // 좌표 계산
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = padding + (i / (data.length - 1)) * chartWidth;
      final y = padding + chartHeight - ((data[i] - minValue) / valueRange) * chartHeight;
      points.add(Offset(x, y));
    }

    // 배경 그라디언트 그리기
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points.first.dx, size.height - padding);
      for (final point in points) {
        path.lineTo(point.dx, point.dy);
      }
      path.lineTo(points.last.dx, size.height - padding);
      path.close();
      canvas.drawPath(path, backgroundPaint);
    }

    // 선 그리기
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // 점 그리기
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 6, dotPaint);
      canvas.drawCircle(points[i], 6, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill);
      canvas.drawCircle(points[i], 4, dotPaint);

      // 값 표시
      textPainter.text = TextSpan(
        text: data[i].toStringAsFixed(1),
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          points[i].dx - textPainter.width / 2,
          points[i].dy - textPainter.height - 8,
        ),
      );
    }

    // 라벨 그리기
    for (int i = 0; i < labels.length && i < points.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          points[i].dx - textPainter.width / 2,
          size.height - padding + 8,
        ),
      );
    }

    // Y축 기준선 그리기
    final gridPaint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final y = padding + (i / 5) * chartHeight;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );

      // Y축 값 표시
      final value = maxValue - (i / 5) * valueRange;
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 9,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(5, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
