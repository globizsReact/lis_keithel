import 'package:flutter/material.dart';
import 'package:lis_keithel/utils/theme.dart';

class VerticalDottedLine extends StatelessWidget {
  const VerticalDottedLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10, // Width of the container
      height: 100, // Height of the container
      color: Colors.transparent, // Transparent background
      child: CustomPaint(
        painter: DottedLinePainter(),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.grey // Color of the dots
      ..strokeWidth = 1; // Thickness of the dots

    const double dashHeight = 5; // Height of each dot
    const double gapHeight = 5; // Space between dots
    const double totalDashHeight = dashHeight + gapHeight;

    for (double i = 0; i < size.height; i += totalDashHeight) {
      canvas.drawLine(
        Offset(size.width / 2, i), // Start point of the dot
        Offset(size.width / 2, i + dashHeight), // End point of the dot
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
