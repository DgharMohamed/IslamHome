import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/core/utils/quran_utils.dart';
import 'package:islam_home/data/models/khatma_v2_models.dart';
import 'package:islam_home/presentation/providers/khatma_v2_provider.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

class KhatmaV2SetupSheet extends ConsumerStatefulWidget {
  const KhatmaV2SetupSheet({super.key});

  @override
  ConsumerState<KhatmaV2SetupSheet> createState() => _KhatmaV2SetupSheetState();
}

class _KhatmaV2SetupSheetState extends ConsumerState<KhatmaV2SetupSheet> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // New track data
  KhatmaType _selectedType = KhatmaType.reading;
  String _title = '';
  int _days = 30;
  SchedulingMode _selectedMode = SchedulingMode.smartRemediation;
  KhatmaUnit _selectedUnit = KhatmaUnit.page;
  int _startPage = 1;
  int _endPage = 604;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildTypeStep(),
                _buildDetailsStep(),
                _buildSchedulingStep(),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.khatmaV2Title,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentStep--);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  foregroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  AppLocalizations.of(context)!.khatmaV2Back,
                  style: GoogleFonts.cairo(),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == 2 ? _finishSetup : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == 2
                    ? AppLocalizations.of(context)!.khatmaV2StartJourney
                    : AppLocalizations.of(context)!.khatmaV2Continue,
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && _title.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      final typeStr = _selectedType == KhatmaType.reading
          ? l10n.khatmaV2Reading
          : _selectedType == KhatmaType.memorization
          ? l10n.khatmaV2Memorization
          : _selectedType == KhatmaType.revision
          ? l10n.khatmaV2Revision
          : l10n.khatmaV2Listening;
      _title = l10n.khatmaV2MyKhatma(typeStr);
    }
    if (_currentStep == 1 && !_validateDetailsStep()) {
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep++);
  }

  Future<void> _finishSetup() async {
    if (!_validateDetailsStep()) return;

    final safeDays = _days.clamp(1, 3650);
    final newTrack = KhatmaTrack(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title.trim(),
      type: _selectedType,
      schedulingMode: _selectedMode,
      startDate: DateTime.now(),
      targetDate: DateTime.now().add(Duration(days: safeDays)),
      startPage: _startPage,
      endPage: _endPage,
      // Stores last completed unit; start at 0% progress.
      currentPage: _startPage - 1,
      unit: _selectedUnit,
    );

    try {
      await ref.read(khatmaV2Provider.notifier).addTrack(newTrack);
    } on FormatException catch (e) {
      if (!mounted) return;
      _showValidationError(_mapValidationError(e.message));
      return;
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  // --- Steps ---

  Widget _buildTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.khatmaV2TypeStepTitle,
            style: GoogleFonts.tajawal(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          _buildTypeOption(
            KhatmaType.reading,
            AppLocalizations.of(context)!.khatmaV2Reading,
            AppLocalizations.of(context)!.khatmaV2ReadingDesc,
            Icons.chrome_reader_mode_outlined,
          ),
          const SizedBox(height: 12),
          _buildTypeOption(
            KhatmaType.memorization,
            AppLocalizations.of(context)!.khatmaV2Memorization,
            AppLocalizations.of(context)!.khatmaV2MemorizationDesc,
            Icons.psychology_outlined,
          ),
          const SizedBox(height: 12),
          _buildTypeOption(
            KhatmaType.revision,
            AppLocalizations.of(context)!.khatmaV2Revision,
            AppLocalizations.of(context)!.khatmaV2RevisionDesc,
            Icons.history_edu_outlined,
          ),
          const SizedBox(height: 12),
          _buildTypeOption(
            KhatmaType.listening,
            AppLocalizations.of(context)!.khatmaV2Listening,
            AppLocalizations.of(context)!.khatmaV2ListeningDesc,
            Icons.headphones_outlined,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.khatmaV2DetailsStepTitle,
            style: GoogleFonts.tajawal(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (v) => _title = v,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.khatmaV2TitleLabel,
              labelStyle: TextStyle(color: AppTheme.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppTheme.primaryColor),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.khatmaV2UnitLabel,
            style: GoogleFonts.tajawal(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          // 3-option row
          Row(
            children: [
              Expanded(
                child: _buildUnitOption(
                  KhatmaUnit.page,
                  AppLocalizations.of(context)!.khatmaV2UnitPage,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildUnitOption(
                  KhatmaUnit.juz,
                  AppLocalizations.of(context)!.khatmaV2UnitJuz,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildUnitOption(
                  KhatmaUnit.surah,
                  AppLocalizations.of(context)!.khatmaV2UnitSurah,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _selectedUnit == KhatmaUnit.page
                ? AppLocalizations.of(context)!.khatmaV2Range
                : _selectedUnit == KhatmaUnit.juz
                ? AppLocalizations.of(context)!.khatmaV2JuzCount
                : AppLocalizations.of(context)!.khatmaV2Range,
            style: GoogleFonts.tajawal(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedUnit == KhatmaUnit.surah)
            _buildSurahRangePicker()
          else
            Row(
              children: [
                Expanded(
                  child: _buildNumericField(
                    _selectedUnit == KhatmaUnit.page
                        ? AppLocalizations.of(context)!.khatmaV2StartPage
                        : AppLocalizations.of(context)!.khatmaV2StartJuz,
                    _startPage,
                    (v) => setState(() => _startPage = v),
                    min: 1,
                    max: _endPage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumericField(
                    _selectedUnit == KhatmaUnit.page
                        ? AppLocalizations.of(context)!.khatmaV2EndPage
                        : AppLocalizations.of(context)!.khatmaV2EndJuz,
                    _endPage,
                    (v) => setState(() => _endPage = v),
                    min: _startPage,
                    max: _maxUnitFor(_selectedUnit),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSchedulingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.khatmaV2SchedulingStepTitle,
            style: GoogleFonts.tajawal(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.khatmaV2QuickDurations,
            style: GoogleFonts.tajawal(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildDurationPreset(7)),
              const SizedBox(width: 8),
              Expanded(child: _buildDurationPreset(30)),
              const SizedBox(width: 8),
              Expanded(child: _buildDurationPreset(60)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.khatmaV2DurationDays,
                style: GoogleFonts.cairo(color: Colors.white),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        setState(() => _days = (_days - 5).clamp(1, 365)),
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    '$_days',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => _days = (_days + 5).clamp(1, 365)),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.khatmaV2EnginePrefs,
            style: GoogleFonts.tajawal(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          RadioGroup<SchedulingMode>(
            groupValue: _selectedMode,
            onChanged: (v) => setState(() => _selectedMode = v!),
            child: Column(
              children: [
                _buildToggleOption(
                  SchedulingMode.smartRemediation,
                  AppLocalizations.of(context)!.khatmaV2SmartRemediation,
                  AppLocalizations.of(context)!.khatmaV2SmartRemediationDesc,
                  Icons.auto_awesome,
                ),
                const SizedBox(height: 12),
                _buildToggleOption(
                  SchedulingMode.fixedDaily,
                  AppLocalizations.of(context)!.khatmaV2FixedDaily,
                  AppLocalizations.of(context)!.khatmaV2FixedDailyDesc,
                  Icons.lock_clock_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildTypeOption(
    KhatmaType type,
    String title,
    String subtitle,
    IconData icon,
  ) {
    bool isSelected = _selectedType == type;
    return InkWell(
      onTap: () => _onTypeSelected(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.tajawal(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _onTypeSelected(KhatmaType type) {
    setState(() {
      _selectedType = type;

      // Listening flows are usually surah-based, so default to Surah unit.
      if (type == KhatmaType.listening && _selectedUnit == KhatmaUnit.page) {
        _selectedUnit = KhatmaUnit.surah;
        _startPage = 1;
        _endPage = 114;
      }
      _normalizeRangeForUnit();
    });
  }

  Widget _buildDurationPreset(int days) {
    final isSelected = _days == days;
    return InkWell(
      onTap: () => setState(() => _days = days),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Center(
          child: Text(
            '$days ${AppLocalizations.of(context)!.days}',
            style: GoogleFonts.cairo(
              color: isSelected ? AppTheme.primaryColor : Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitOption(KhatmaUnit unit, String label) {
    bool isSelected = _selectedUnit == unit;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedUnit = unit;
          if (unit == KhatmaUnit.page) {
            _startPage = 1;
            _endPage = 604;
          } else if (unit == KhatmaUnit.juz) {
            _startPage = 1;
            _endPage = 30;
          } else {
            // surah
            _startPage = 1;
            _endPage = 114;
          }
          _normalizeRangeForUnit();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              color: isSelected ? AppTheme.primaryColor : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahRangePicker() {
    return Row(
      children: [
        Expanded(
          child: _buildSurahDropdown(
            label: AppLocalizations.of(context)!.khatmaV2StartSurah,
            value: _startPage,
            max: _endPage,
            onChanged: (v) => setState(() => _startPage = v!),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSurahDropdown(
            label: AppLocalizations.of(context)!.khatmaV2EndSurah,
            value: _endPage,
            min: _startPage,
            onChanged: (v) => setState(() => _endPage = v!),
          ),
        ),
      ],
    );
  }

  Widget _buildSurahDropdown({
    required String label,
    required int value,
    int min = 1,
    int max = 114,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value.clamp(min, max),
      isExpanded: true,
      dropdownColor: AppTheme.surfaceColor,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: List.generate(max - min + 1, (i) {
        final surahNum = min + i;
        final surahName = QuranUtils.getSurahName(surahNum, isEnglish: false);
        return DropdownMenuItem(
          value: surahNum,
          child: Text(
            '$surahNum. $surahName',
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(fontSize: 12, color: Colors.white),
          ),
        );
      }),
      onChanged: onChanged,
    );
  }

  Widget _buildToggleOption(
    SchedulingMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    bool isSelected = _selectedMode == mode;
    return InkWell(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.tajawal(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<SchedulingMode>(
              value: mode,
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericField(
    String label,
    int value,
    Function(int) onChanged, {
    required int min,
    required int max,
  }) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (v) {
        final parsed = int.tryParse(v);
        if (parsed == null) return;
        onChanged(parsed.clamp(min, max));
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  int _maxUnitFor(KhatmaUnit unit) {
    switch (unit) {
      case KhatmaUnit.page:
        return 604;
      case KhatmaUnit.juz:
        return 30;
      case KhatmaUnit.surah:
        return 114;
    }
  }

  void _normalizeRangeForUnit() {
    final max = _maxUnitFor(_selectedUnit);
    _startPage = _startPage.clamp(1, max);
    _endPage = _endPage.clamp(1, max);
    if (_startPage > _endPage) {
      _endPage = _startPage;
    }
  }

  bool _validateDetailsStep() {
    final max = _maxUnitFor(_selectedUnit);
    final l10n = AppLocalizations.of(context)!;
    _startPage = _startPage.clamp(1, max);
    _endPage = _endPage.clamp(1, max);

    if (_startPage > _endPage) {
      _showValidationError(l10n.khatmaV2ValidationRangeOrder);
      return false;
    }
    if (_startPage < 1 || _startPage > max) {
      _showValidationError(l10n.khatmaV2ValidationStartOutOfRange(max));
      return false;
    }
    if (_endPage < 1 || _endPage > max) {
      _showValidationError(l10n.khatmaV2ValidationEndOutOfRange(max));
      return false;
    }
    if (_title.trim().isEmpty) {
      final fallback = l10n.khatmaV2MyKhatma(l10n.khatmaV2Reading);
      setState(() => _title = fallback);
    }
    if (_days < 1) {
      _showValidationError(l10n.khatmaV2ValidationDurationDays);
      return false;
    }
    return true;
  }

  String _mapValidationError(String code) {
    final l10n = AppLocalizations.of(context)!;
    if (code.startsWith('start_out_of_range:')) {
      final max = int.tryParse(code.split(':').last) ?? _maxUnitFor(_selectedUnit);
      return l10n.khatmaV2ValidationStartOutOfRange(max);
    }
    if (code.startsWith('end_out_of_range:')) {
      final max = int.tryParse(code.split(':').last) ?? _maxUnitFor(_selectedUnit);
      return l10n.khatmaV2ValidationEndOutOfRange(max);
    }
    if (code == 'range_order_invalid') {
      return l10n.khatmaV2ValidationRangeOrder;
    }
    return l10n.errorOccurred;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
