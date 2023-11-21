import 'package:flutter/material.dart';

class CurvePainter extends CustomPainter {
  final Path path;

  CurvePainter({
    required this.path,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(path, Paint()..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}