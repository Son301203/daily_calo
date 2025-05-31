import 'package:flutter/material.dart';

class WaterGlassPainter extends CustomPainter {
  final bool filled;

  WaterGlassPainter({required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = filled ? const Color.fromARGB(255, 123, 168, 246) : Colors.transparent;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 1;

    final path = Path()
      ..moveTo(size.width * 0.25, size.height) 
      ..lineTo(0, 0) 
      ..lineTo(size.width, 0) 
      ..lineTo(size.width * 0.75, size.height) 
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}