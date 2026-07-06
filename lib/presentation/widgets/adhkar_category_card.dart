import 'package:flutter/material.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

class AdhkarCategoryCard extends StatefulWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const AdhkarCategoryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    this.accentColor = AppTheme.primaryColor,
    required this.onTap,
  });

  @override
  State<AdhkarCategoryCard> createState() => _AdhkarCategoryCardState();
}

class _AdhkarCategoryCardState extends State<AdhkarCategoryCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final accent = widget.accentColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.12),
                AppTheme.surfaceColor.withValues(alpha: 0.85),
              ],
            ),
            border: Border.all(color: accent.withValues(alpha: 0.18), width: 1),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: accent.withValues(alpha: 0.15),
              highlightColor: accent.withValues(alpha: 0.08),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon container with gradient
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent.withValues(alpha: 0.25),
                            accent.withValues(alpha: 0.08),
                          ],
                        ),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.20),
                          width: 1,
                        ),
                      ),
                      child: Icon(widget.icon, color: accent, size: 22),
                    ),
                    const Spacer(),
                    // Category title
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: isEnglish ? 'Montserrat' : 'Cairo',
                        fontSize: isEnglish ? 15 : 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: accent.withValues(alpha: 0.12),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        l10n.adhkarCount(widget.count),
                        style: TextStyle(
                          fontFamily: isEnglish ? 'Montserrat' : 'Cairo',
                          fontSize: isEnglish ? 10 : 11,
                          fontWeight: FontWeight.w600,
                          color: accent.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
