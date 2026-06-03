import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/data/models/hadith_model.dart';
import 'package:islam_home/core/theme/app_theme.dart';

class HadithShareCard extends StatelessWidget {
  final HadithModel hadith;
  final String bookName;
  final String gradeLabel;

  const HadithShareCard({
    super.key,
    required this.hadith,
    required this.bookName,
    required this.gradeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasEnglish = hadith.english != null && hadith.english!.isNotEmpty;
    final hasArabic = hadith.arab != null && hadith.arab!.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: _ShareIslamicPatternPainter(color: AppTheme.primaryColor),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        border: Border(bottom: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.2), width: 1.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              bookName,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '#${hadith.number ?? hadith.id}',
                              style: GoogleFonts.montserrat(
                                color: AppTheme.backgroundColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Body
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (gradeLabel.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  gradeLabel,
                                  style: GoogleFonts.cairo(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          
                          if (hasArabic)
                            Text(
                              hadith.arab!,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.amiri(
                                fontSize: 28,
                                height: 1.8,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                          if (hasArabic && hasEnglish)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Divider(color: Colors.white24, thickness: 1.5),
                            ),
                            
                          if (hasEnglish)
                            Text(
                              hadith.english!,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.ltr,
                              style: GoogleFonts.tajawal(
                                fontSize: 20,
                                height: 1.6,
                                color: AppTheme.primaryColor.withValues(alpha: 0.9),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Footer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.mosque_rounded, color: AppTheme.primaryColor, size: 20),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'تطبيق بيت الإسلام - Islam Home',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareIslamicPatternPainter extends CustomPainter {
  final Color color;
  _ShareIslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const spacing = 60.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 20, paint);
        final rect = Rect.fromCenter(center: Offset(x, y), width: 30, height: 30);
        canvas.drawRect(rect, paint);
        canvas.drawLine(Offset(x - 20, y), Offset(x + 20, y), paint);
        canvas.drawLine(Offset(x, y - 20), Offset(x, y + 20), paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
