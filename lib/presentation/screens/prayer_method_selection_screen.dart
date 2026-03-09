import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/data/models/prayer_method.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';
import 'package:islam_home/presentation/providers/prayer_notifier.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';

class PrayerMethodSelectionScreen extends ConsumerStatefulWidget {
  const PrayerMethodSelectionScreen({super.key});

  @override
  ConsumerState<PrayerMethodSelectionScreen> createState() =>
      _PrayerMethodSelectionScreenState();
}

class _PrayerMethodSelectionScreenState
    extends ConsumerState<PrayerMethodSelectionScreen> {
  int _selectedMethodId = 3; // Default to MWL

  @override
  void initState() {
    super.initState();
    final box = Hive.box('settings');
    _selectedMethodId = box.get('prayer_calculation_method', defaultValue: 3);
  }

  Future<void> _saveAndContinue() async {
    final box = Hive.box('settings');
    await box.put('prayer_calculation_method', _selectedMethodId);
    await box.put('onboarding_completed', true);

    // Refresh prayer times with the new method
    ref.read(prayerNotifierProvider.notifier).refresh();

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.calculationMethodTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.calculationMethodDescription,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: PrayerMethod.methods.length,
                    itemBuilder: (context, index) {
                      final method = PrayerMethod.methods[index];
                      final isSelected = _selectedMethodId == method.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassContainer(
                          borderRadius: 16,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMethodId = method.id;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              title: Text(
                                isArabic ? method.nameAr : method.nameEn,
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.white,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primaryColor,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.finishSetup,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
