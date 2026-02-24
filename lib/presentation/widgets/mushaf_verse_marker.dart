import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

class MushafVerseMarker extends StatelessWidget {
  final int verseNumber;
  final double size;
  final Color color;

  const MushafVerseMarker({
    super.key,
    required this.verseNumber,
    this.size = 35,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size, // Ensure square for the circle
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: MushafVerseMarkerPainter(color: color),
          ),
          Text(
            '$verseNumber',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: size * 0.45,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class MushafVerseMarkerPainter extends CustomPainter {
  final Color color;

  MushafVerseMarkerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw central circle base
    canvas.drawCircle(center, radius * 0.55, fillPaint);
    canvas.drawCircle(center, radius * 0.55, paint..strokeWidth = 1.0);

    // 2. Draw radial floral "petals" (Sunburst)
    final petalCount = 14;
    for (int i = 0; i < petalCount; i++) {
      double angle = (i * (360 / petalCount)) * math.pi / 180;

      final startRadius = radius * 0.55;
      final endRadius = radius * 0.92; // Slightly shorter petals

      final x1 = center.dx + startRadius * math.cos(angle);
      final y1 = center.dy + startRadius * math.sin(angle);
      final x2 = center.dx + endRadius * math.cos(angle);
      final y2 = center.dy + endRadius * math.sin(angle);

      final path = Path();
      path.moveTo(x1, y1);

      // Control points for a more elegant petal shape
      final cp1x = center.dx + radius * 1.05 * math.cos(angle - 0.08);
      final cp1y = center.dy + radius * 1.05 * math.sin(angle - 0.08);
      final cp2x = center.dx + radius * 1.05 * math.cos(angle + 0.08);
      final cp2y = center.dy + radius * 1.05 * math.sin(angle + 0.08);

      path.quadraticBezierTo(cp1x, cp1y, x2, y2);
      path.quadraticBezierTo(cp2x, cp2y, x1, y1);

      canvas.drawPath(path, paint..strokeWidth = 0.9);
    }

    // 3. Draw vertical ornate extensions (Top and Bottom)
    _drawVerticalExtension(canvas, center, radius, color, true); // Top
    _drawVerticalExtension(canvas, center, radius, color, false); // Bottom
  }

  void _drawVerticalExtension(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    bool isTop,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final direction = isTop ? -1 : 1;
    final startY = center.dy + (radius * 0.85 * direction);
    final extensionLength = radius * 0.65;

    // Main vertical stem
    canvas.drawLine(
      Offset(center.dx, startY),
      Offset(center.dx, startY + (extensionLength * direction)),
      paint,
    );

    // Decorative cross-piece
    final midY = startY + (extensionLength * 0.45 * direction);
    final curvePath = Path();
    curvePath.moveTo(center.dx - radius * 0.18, midY);
    curvePath.quadraticBezierTo(
      center.dx,
      midY - (radius * 0.12 * direction),
      center.dx + radius * 0.18,
      midY,
    );
    canvas.drawPath(curvePath, paint);

    // Side dots/buds - more defined
    canvas.drawCircle(Offset(center.dx - radius * 0.22, midY), 1.6, dotPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.22, midY), 1.6, dotPaint);

    // Tip decoration cluster
    final tipY = startY + (extensionLength * direction);
    canvas.drawCircle(
      Offset(center.dx, tipY + (3.0 * direction)),
      1.4,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(center.dx - 2, tipY + (1.0 * direction)),
      0.8,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + 2, tipY + (1.0 * direction)),
      0.8,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
