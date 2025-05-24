import 'package:flutter/material.dart';

class WaterGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path();

    final topWidth = size.width;
    final bottomWidth = size.width * 0.7;
    final bottomPadding = (topWidth - bottomWidth) / 2;

    path.moveTo(0, 0);
    path.lineTo(topWidth, 0);
    path.lineTo(topWidth - bottomPadding, size.height);
    path.lineTo(bottomPadding, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(size.width * 0.2, 0);
    highlightPath.lineTo(size.width * 0.4, 0);
    highlightPath.lineTo(size.width * 0.3, size.height * 0.7);
    highlightPath.lineTo(size.width * 0.15, size.height * 0.7);
    highlightPath.close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}