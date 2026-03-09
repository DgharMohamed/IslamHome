import 'package:flutter/material.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/data/models/khatma_v2_models.dart';
import 'package:intl/intl.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

class KhatmaHeatmap extends StatelessWidget {
  final Map<String, int> progress; // Date (yyyy-MM-dd) -> Units read
  final int daysToShow;
  final int? maxUnitsPerDay;
  final KhatmaUnit unit;

  const KhatmaHeatmap({
    super.key,
    required this.progress,
    this.unit = KhatmaUnit.page,
    this.daysToShow = 84, // 12 weeks
    this.maxUnitsPerDay,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: daysToShow - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(daysToShow, (index) {
            final date = startDate.add(Duration(days: index));
            final dateKey = DateFormat('yyyy-MM-dd').format(date);
            final unitsRead = progress[dateKey] ?? 0;

            return _buildSquare(context, unitsRead, date);
          }),
        ),
        const SizedBox(height: 8),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildSquare(BuildContext context, int units, DateTime date) {
    final maxDailyUnits = (maxUnitsPerDay ?? _defaultMaxForUnit(unit)).clamp(
      1,
      100000,
    );
    final intensity = (units / maxDailyUnits).clamp(0.0, 1.0);

    // Color levels: empty, low, medium, high, very-high
    Color color;
    if (units == 0) {
      color = AppTheme.surfaceColor.withValues(alpha: 0.3);
    } else if (intensity < 0.25) {
      color = AppTheme.primaryColor.withValues(alpha: 0.2);
    } else if (intensity < 0.5) {
      color = AppTheme.primaryColor.withValues(alpha: 0.5);
    } else if (intensity < 0.75) {
      color = AppTheme.primaryColor.withValues(alpha: 0.8);
    } else {
      color = AppTheme.primaryColor;
    }

    return Tooltip(
      message:
          '${DateFormat('MMM d').format(date)}: $units ${_unitLabel(context)}',
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.khatmaHeatmapLess,
          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 4),
        _buildSquareLegend(AppTheme.surfaceColor.withValues(alpha: 0.3)),
        const SizedBox(width: 2),
        _buildSquareLegend(AppTheme.primaryColor.withValues(alpha: 0.3)),
        const SizedBox(width: 2),
        _buildSquareLegend(AppTheme.primaryColor.withValues(alpha: 0.6)),
        const SizedBox(width: 2),
        _buildSquareLegend(AppTheme.primaryColor),
        const SizedBox(width: 4),
        Text(
          AppLocalizations.of(context)!.khatmaHeatmapMore,
          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSquareLegend(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  int _defaultMaxForUnit(KhatmaUnit unit) {
    switch (unit) {
      case KhatmaUnit.page:
        return 20;
      case KhatmaUnit.juz:
        return 2;
      case KhatmaUnit.surah:
        return 4;
    }
  }

  String _unitLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (unit) {
      case KhatmaUnit.page:
        return l10n.khatmaV2UnitPageSingle;
      case KhatmaUnit.juz:
        return l10n.khatmaV2UnitJuzSingle;
      case KhatmaUnit.surah:
        return l10n.khatmaV2UnitSurahSingle;
    }
  }
}
