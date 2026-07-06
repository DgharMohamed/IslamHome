import 'package:adhan/adhan.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:islam_home/data/models/prayer_times_model.dart';

class OfflinePrayerService {
  static final OfflinePrayerService _instance =
      OfflinePrayerService._internal();
  factory OfflinePrayerService() => _instance;
  OfflinePrayerService._internal();

  /// Calculates prayer times for a given location and date.
  /// [methodId] corresponds to the Aladhan API method IDs.
  /// Defaults to MWL (id 3) if not specified or unrecognized.
  PrayerTimesModel calculatePrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
    int methodId = 3,
  }) {
    final myCoordinates = Coordinates(latitude, longitude);
    final params = _getCalculationParameters(methodId);
    params.madhab = Madhab
        .shafi; // Default for most, including Morocco (Maliki is similar in timings usually)

    final dateToCalculate = date ?? DateTime.now();
    final components = DateComponents.from(dateToCalculate);
    final prayerTimes = PrayerTimes(myCoordinates, components, params);

    // Map adhan types to string format used in the existing model
    final DateFormat formatter = DateFormat('HH:mm');

    final Map<String, String> timings = {
      'Fajr': formatter.format(prayerTimes.fajr),
      'Sunrise': formatter.format(prayerTimes.sunrise),
      'Dhuhr': formatter.format(prayerTimes.dhuhr),
      'Asr': formatter.format(prayerTimes.asr),
      'Maghrib': formatter.format(prayerTimes.maghrib),
      'Isha': formatter.format(prayerTimes.isha),
    };

    // Calculate Hijri Date
    final hijriDate = HijriCalendar.fromDate(dateToCalculate);

    return PrayerTimesModel(
      timings: timings,
      date: DateInfo(
        gregorian: GregorianDate(
          date: DateFormat('dd-MM-yyyy').format(dateToCalculate),
          format: 'DD-MM-YYYY',
          day: DateFormat('EEEE').format(dateToCalculate),
        ),
        hijri: HijriDate(
          day: hijriDate.hDay.toString(),
          month: {
            'number': hijriDate.hMonth,
            'ar': _getArabicHijriMonthName(hijriDate.hMonth),
            'en': hijriDate.longMonthName,
          },
          year: hijriDate.hYear.toString(),
          date: hijriDate.toString(),
        ),
      ),
    );
  }

  String _getArabicHijriMonthName(int month) {
    const months = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  /// Maps Aladhan API method IDs to the `adhan` package CalculationMethod.
  /// Falls back to Muslim World League for unsupported IDs.
  CalculationParameters _getCalculationParameters(int methodId) {
    switch (methodId) {
      case 1:
        return CalculationMethod.karachi.getParameters();
      case 2:
        return CalculationMethod.north_america.getParameters();
      case 3:
        return CalculationMethod.muslim_world_league.getParameters();
      case 4:
        return CalculationMethod.umm_al_qura.getParameters();
      case 5:
        return CalculationMethod.egyptian.getParameters();
      case 7:
        return CalculationMethod.tehran.getParameters();
      case 8: // Gulf Region
        return CalculationMethod.dubai.getParameters();
      case 9: // Kuwait
        return CalculationMethod.kuwait.getParameters();
      case 10: // Qatar
        return CalculationMethod.qatar.getParameters();
      case 11: // Singapore
        return CalculationMethod.singapore.getParameters();
      case 13: // Turkey
        return CalculationMethod.turkey.getParameters();
      case 15: // Moonsighting
        return CalculationMethod.moon_sighting_committee.getParameters();
      case 16: // Dubai
        return CalculationMethod.dubai.getParameters();
      default:
        // Methods 0, 12, 14, 17-23 don't have direct adhan package equivalents.
        // Fall back to MWL which is the most widely used.
        return CalculationMethod.muslim_world_league.getParameters();
    }
  }
}
