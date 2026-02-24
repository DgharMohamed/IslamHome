import 'package:flutter/material.dart';

class SajdahMarker extends StatelessWidget {
  final Color color;
  final double size;

  const SajdahMarker({super.key, required this.color, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: SajdahMarkerPainter(color: color)),
    );
  }
}

class SajdahMarkerPainter extends CustomPainter {
  final Color color;

  SajdahMarkerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Adjust height usage to make room for bottom extension
    final bodyHeight = h * 0.75;
    final startY = h * 0.0;

    // Draw the Mihrab shape (ogee arch)
    // Base width is slightly narrower than full width
    final baseWidthPercentage = 0.8;
    final baseXStart = w * (1 - baseWidthPercentage) / 2;
    final baseXEnd = w * (1 + baseWidthPercentage) / 2;

    path.moveTo(baseXStart, bodyHeight); // Bottom left of arch
    path.lineTo(baseXEnd, bodyHeight); // Bottom right of arch
    path.lineTo(baseXEnd, bodyHeight * 0.6); // Wall up to arch start

    // Arch curves
    path.cubicTo(
      baseXEnd,
      bodyHeight * 0.3,
      w * 0.5 + (w * 0.1),
      bodyHeight * 0.2,
      w * 0.5,
      startY, // Top tip
    );
    path.cubicTo(
      w * 0.5 - (w * 0.1),
      bodyHeight * 0.2,
      baseXStart,
      bodyHeight * 0.3,
      baseXStart,
      bodyHeight * 0.6,
    );
    path.close();

    // Draw main body (filled with opacity)
    canvas.drawPath(path, paint..color = color.withValues(alpha: 0.15));
    canvas.drawPath(path, strokePaint);

    // Horizontal lines inside
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 4; i++) {
      final y = startY + (bodyHeight * 0.3) + (i * (bodyHeight * 0.12));
      final lineWidth = w * 0.4;
      canvas.drawLine(
        Offset((w - lineWidth) / 2, y),
        Offset((w + lineWidth) / 2, y),
        linePaint,
      );
    }

    // Bottom Ornate Extension (The "Stand")
    final standPath = Path();
    final standTop = bodyHeight;
    final standBottom = h;
    final centerX = w * 0.5;

    // Central stem
    standPath.moveTo(centerX, standTop);
    standPath.lineTo(centerX, standBottom * 0.9);

    // Decorative knot/circle in middle of stand
    canvas.drawCircle(
      Offset(centerX, standTop + (standBottom - standTop) * 0.4),
      2.0,
      paint..color = color,
    );

    // Bottom base curves
    standPath.moveTo(centerX, standBottom * 0.9);
    standPath.quadraticBezierTo(
      centerX - w * 0.2,
      standBottom,
      centerX - w * 0.15,
      standBottom * 0.85,
    );
    standPath.moveTo(centerX, standBottom * 0.9);
    standPath.quadraticBezierTo(
      centerX + w * 0.2,
      standBottom,
      centerX + w * 0.15,
      standBottom * 0.85,
    );

    canvas.drawPath(standPath, strokePaint..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
