import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'بيت الإسلام'**
  String get appTitle;

  /// No description provided for @goodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get goodAfternoon;

  /// No description provided for @goodNight.
  ///
  /// In ar, this message translates to:
  /// **'ليلة سعيدة'**
  String get goodNight;

  /// No description provided for @prayerTimes.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت الصلاة'**
  String get prayerTimes;

  /// No description provided for @dailyVerse.
  ///
  /// In ar, this message translates to:
  /// **'آية اليوم'**
  String get dailyVerse;

  /// No description provided for @khatmaProgress.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الختمة'**
  String get khatmaProgress;

  /// No description provided for @generalReadingProgress.
  ///
  /// In ar, this message translates to:
  /// **'تقدم القراءة العام'**
  String get generalReadingProgress;

  /// No description provided for @reachedSurah.
  ///
  /// In ar, this message translates to:
  /// **'وصلت إلى سورة {surah}'**
  String reachedSurah(String surah);

  /// No description provided for @exploreSections.
  ///
  /// In ar, this message translates to:
  /// **'استكشف الأقسام'**
  String get exploreSections;

  /// No description provided for @homeSectionQuranAndSeerah.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم والسيرة النبوية'**
  String get homeSectionQuranAndSeerah;

  /// No description provided for @homeSectionWorshipAndPrayer.
  ///
  /// In ar, this message translates to:
  /// **'العبادة والصلاة'**
  String get homeSectionWorshipAndPrayer;

  /// No description provided for @homeSectionMediaAndBroadcast.
  ///
  /// In ar, this message translates to:
  /// **'البث والإعلام'**
  String get homeSectionMediaAndBroadcast;

  /// No description provided for @homeSectionMyLibrary.
  ///
  /// In ar, this message translates to:
  /// **'مكتبتي'**
  String get homeSectionMyLibrary;

  /// No description provided for @quranMushaf.
  ///
  /// In ar, this message translates to:
  /// **'المصحف الشريف'**
  String get quranMushaf;

  /// No description provided for @quranTitle.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم'**
  String get quranTitle;

  /// No description provided for @quranSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تفسير، قراءة وترجمة'**
  String get quranSubtitle;

  /// No description provided for @quranSyncTitle.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الصوتي المقروء'**
  String get quranSyncTitle;

  /// No description provided for @quranSyncSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة التلاوة مع النص'**
  String get quranSyncSubtitle;

  /// No description provided for @audioTafsir.
  ///
  /// In ar, this message translates to:
  /// **'تفسير القرآن المسموع'**
  String get audioTafsir;

  /// No description provided for @propheticHadith.
  ///
  /// In ar, this message translates to:
  /// **'الأحاديث النبوية'**
  String get propheticHadith;

  /// No description provided for @hadithOfTheDay.
  ///
  /// In ar, this message translates to:
  /// **'حديث اليوم'**
  String get hadithOfTheDay;

  /// No description provided for @azkarDuas.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار والأدعية'**
  String get azkarDuas;

  /// No description provided for @adhkarOfTheDay.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المسلم'**
  String get adhkarOfTheDay;

  /// No description provided for @radioLive.
  ///
  /// In ar, this message translates to:
  /// **'الإذاعات والمباشر'**
  String get radioLive;

  /// No description provided for @favoriteReciters.
  ///
  /// In ar, this message translates to:
  /// **'قراؤك المفضلون'**
  String get favoriteReciters;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @notificationsAthan.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات والآذان'**
  String get notificationsAthan;

  /// No description provided for @athanNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الآذان'**
  String get athanNotifications;

  /// No description provided for @enabledForAll.
  ///
  /// In ar, this message translates to:
  /// **'مفعلة لكافة الصلوات'**
  String get enabledForAll;

  /// No description provided for @disabled.
  ///
  /// In ar, this message translates to:
  /// **'معطلة'**
  String get disabled;

  /// No description provided for @appearanceLanguage.
  ///
  /// In ar, this message translates to:
  /// **'المظهر واللغة'**
  String get appearanceLanguage;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'المظهر الداكن'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مفعل دائماً للراحة البصرية'**
  String get darkModeSubtitle;

  /// No description provided for @appLanguage.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get appLanguage;

  /// No description provided for @juzMarkers.
  ///
  /// In ar, this message translates to:
  /// **'إظهار فواصل الأجزاء'**
  String get juzMarkers;

  /// No description provided for @juzMarkersSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض شارات الانتقال بين أجزاء القرآن'**
  String get juzMarkersSubtitle;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @appVersion.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get appVersion;

  /// No description provided for @shareApp.
  ///
  /// In ar, this message translates to:
  /// **'شارك التطبيق'**
  String get shareApp;

  /// No description provided for @rateApp.
  ///
  /// In ar, this message translates to:
  /// **'قيم التطبيق'**
  String get rateApp;

  /// No description provided for @selectLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get english;

  /// No description provided for @globalSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث شامل'**
  String get globalSearch;

  /// No description provided for @searchSurah.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن سورة...'**
  String get searchSurah;

  /// No description provided for @downloadAll.
  ///
  /// In ar, this message translates to:
  /// **'تحميل الكل'**
  String get downloadAll;

  /// No description provided for @favorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorites;

  /// No description provided for @downloads.
  ///
  /// In ar, this message translates to:
  /// **'التنزيلات'**
  String get downloads;

  /// No description provided for @quranText.
  ///
  /// In ar, this message translates to:
  /// **'نص القرآن'**
  String get quranText;

  /// No description provided for @tasbeeh.
  ///
  /// In ar, this message translates to:
  /// **'التسبيح'**
  String get tasbeeh;

  /// No description provided for @liveTv.
  ///
  /// In ar, this message translates to:
  /// **'البث المباشر'**
  String get liveTv;

  /// No description provided for @books.
  ///
  /// In ar, this message translates to:
  /// **'المكتبة المقروءة'**
  String get books;

  /// No description provided for @nextPrayer.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة القادمة'**
  String get nextPrayer;

  /// No description provided for @currentLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع الحالي'**
  String get currentLocation;

  /// No description provided for @qibla.
  ///
  /// In ar, this message translates to:
  /// **'القبلة'**
  String get qibla;

  /// No description provided for @fajr.
  ///
  /// In ar, this message translates to:
  /// **'الفجر'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In ar, this message translates to:
  /// **'الظهر'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In ar, this message translates to:
  /// **'العصر'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In ar, this message translates to:
  /// **'المغرب'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In ar, this message translates to:
  /// **'العشاء'**
  String get isha;

  /// No description provided for @noBookmarkSaved.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد علامة مرجعية محفوظة'**
  String get noBookmarkSaved;

  /// No description provided for @hadithBooks.
  ///
  /// In ar, this message translates to:
  /// **'كتب الحديث'**
  String get hadithBooks;

  /// No description provided for @nineBooksOfSunnah.
  ///
  /// In ar, this message translates to:
  /// **'تسع كتب من أصول السنة'**
  String get nineBooksOfSunnah;

  /// No description provided for @hadithCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} حديث'**
  String hadithCount(int count);

  /// No description provided for @page.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {number}'**
  String page(int number);

  /// No description provided for @noHadithsAvailableOffline.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أحاديث متاحة أوفلاين لهذا الكتاب.\nيرجى الاتصال بالإنترنت للتحميل.'**
  String get noHadithsAvailableOffline;

  /// No description provided for @azkar.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get azkar;

  /// No description provided for @duas.
  ///
  /// In ar, this message translates to:
  /// **'الأدعية'**
  String get duas;

  /// No description provided for @selectedDuas.
  ///
  /// In ar, this message translates to:
  /// **'أدعية مختارة'**
  String get selectedDuas;

  /// No description provided for @dailyMuslimAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المسلم اليومية'**
  String get dailyMuslimAzkar;

  /// No description provided for @morningAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get morningAzkar;

  /// No description provided for @eveningAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get eveningAzkar;

  /// No description provided for @sleepAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار النوم'**
  String get sleepAzkar;

  /// No description provided for @wakeUpAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الاستيقاظ'**
  String get wakeUpAzkar;

  /// No description provided for @mosqueAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المسجد'**
  String get mosqueAzkar;

  /// No description provided for @adhanAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الآذان'**
  String get adhanAzkar;

  /// No description provided for @wuduAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الوضوء'**
  String get wuduAzkar;

  /// No description provided for @propheticDuas.
  ///
  /// In ar, this message translates to:
  /// **'أدعية نبوية'**
  String get propheticDuas;

  /// No description provided for @quranDuas.
  ///
  /// In ar, this message translates to:
  /// **'أدعية قرآنية'**
  String get quranDuas;

  /// No description provided for @prophetsDuas.
  ///
  /// In ar, this message translates to:
  /// **'أدعية الأنبياء'**
  String get prophetsDuas;

  /// No description provided for @miscellaneousAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار متنوعة'**
  String get miscellaneousAzkar;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @startingDownloadAll.
  ///
  /// In ar, this message translates to:
  /// **'بدأ تحميل جميع السور...'**
  String get startingDownloadAll;

  /// No description provided for @downloadCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم اكتمال تحميل {count} سورة'**
  String downloadCompleted(int count);

  /// No description provided for @surahNumber.
  ///
  /// In ar, this message translates to:
  /// **'سورة رقم {number}'**
  String surahNumber(String number);

  /// No description provided for @recitationOf.
  ///
  /// In ar, this message translates to:
  /// **'تلاوة {name}'**
  String recitationOf(String name);

  /// No description provided for @downloadSuccessful.
  ///
  /// In ar, this message translates to:
  /// **'تم التحميل بنجاح'**
  String get downloadSuccessful;

  /// No description provided for @downloadFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل التحميل: {error}'**
  String downloadFailed(String error);

  /// No description provided for @electronicTasbeeh.
  ///
  /// In ar, this message translates to:
  /// **'مسبحة إلكترونية'**
  String get electronicTasbeeh;

  /// No description provided for @totalTasbeehs.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي التسبيحات: {count}'**
  String totalTasbeehs(int count);

  /// No description provided for @tapToCount.
  ///
  /// In ar, this message translates to:
  /// **'اضغط في أي مكان في الدائرة للتسبيح'**
  String get tapToCount;

  /// No description provided for @reset.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين'**
  String get reset;

  /// No description provided for @history.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get history;

  /// No description provided for @mushaf.
  ///
  /// In ar, this message translates to:
  /// **'المصحف الشريف'**
  String get mushaf;

  /// No description provided for @pageSavedAsBookmark.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الصفحة {page} كعلامة مرجعية'**
  String pageSavedAsBookmark(int page);

  /// No description provided for @readingModeText.
  ///
  /// In ar, this message translates to:
  /// **'وضع القراءة النصي'**
  String get readingModeText;

  /// No description provided for @lastReadMushaf.
  ///
  /// In ar, this message translates to:
  /// **'آخر قرائة (صفحة {page})'**
  String lastReadMushaf(int page);

  /// No description provided for @lastReadAyah.
  ///
  /// In ar, this message translates to:
  /// **'آخر قراءة ({surah} : {ayah})'**
  String lastReadAyah(String surah, String ayah);

  /// No description provided for @mushafWithPage.
  ///
  /// In ar, this message translates to:
  /// **'المصحف الشريف (صفحة {page})'**
  String mushafWithPage(int page);

  /// No description provided for @pageXOf604.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {page} من 604'**
  String pageXOf604(int page);

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابقة'**
  String get previous;

  /// No description provided for @index.
  ///
  /// In ar, this message translates to:
  /// **'الفهرس'**
  String get index;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالية'**
  String get next;

  /// No description provided for @errorLoadingPage.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل الصفحة'**
  String get errorLoadingPage;

  /// No description provided for @surahIndex.
  ///
  /// In ar, this message translates to:
  /// **'فهرس السور'**
  String get surahIndex;

  /// No description provided for @errorLoadingSurahs.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل السور'**
  String get errorLoadingSurahs;

  /// No description provided for @meccan.
  ///
  /// In ar, this message translates to:
  /// **'مكية'**
  String get meccan;

  /// No description provided for @medinan.
  ///
  /// In ar, this message translates to:
  /// **'مدنية'**
  String get medinan;

  /// No description provided for @ayahsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} آية'**
  String ayahsCount(int count);

  /// No description provided for @pageN.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {page}'**
  String pageN(int page);

  /// No description provided for @showMushaf.
  ///
  /// In ar, this message translates to:
  /// **'عرض المصحف'**
  String get showMushaf;

  /// No description provided for @selectTranslation.
  ///
  /// In ar, this message translates to:
  /// **'اختر الترجمة'**
  String get selectTranslation;

  /// No description provided for @selectTafsir.
  ///
  /// In ar, this message translates to:
  /// **'اختر التفسير'**
  String get selectTafsir;

  /// No description provided for @chooseTranslation.
  ///
  /// In ar, this message translates to:
  /// **'اختر الترجمة'**
  String get chooseTranslation;

  /// No description provided for @chooseTafsir.
  ///
  /// In ar, this message translates to:
  /// **'اختر التفسير'**
  String get chooseTafsir;

  /// No description provided for @chooseSurah.
  ///
  /// In ar, this message translates to:
  /// **'اختر السورة'**
  String get chooseSurah;

  /// No description provided for @verseN.
  ///
  /// In ar, this message translates to:
  /// **'الآية {number}'**
  String verseN(Object number);

  /// No description provided for @noTafsirAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تفسير متاح حالياً'**
  String get noTafsirAvailable;

  /// No description provided for @radio.
  ///
  /// In ar, this message translates to:
  /// **'الإذاعات'**
  String get radio;

  /// No description provided for @videos.
  ///
  /// In ar, this message translates to:
  /// **'السيرة النبوية'**
  String get videos;

  /// No description provided for @myAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get myAccount;

  /// No description provided for @moodAnxious.
  ///
  /// In ar, this message translates to:
  /// **'قلق'**
  String get moodAnxious;

  /// No description provided for @moodSad.
  ///
  /// In ar, this message translates to:
  /// **'حزين'**
  String get moodSad;

  /// No description provided for @moodHappy.
  ///
  /// In ar, this message translates to:
  /// **'سعيد'**
  String get moodHappy;

  /// No description provided for @moodLost.
  ///
  /// In ar, this message translates to:
  /// **'تائه'**
  String get moodLost;

  /// No description provided for @moodTired.
  ///
  /// In ar, this message translates to:
  /// **'متعب'**
  String get moodTired;

  /// No description provided for @surahSharh.
  ///
  /// In ar, this message translates to:
  /// **'سورة الشرح'**
  String get surahSharh;

  /// No description provided for @descAnxious.
  ///
  /// In ar, this message translates to:
  /// **'تذكر دائماً أن مع العسر يسراً، هذه السورة تبعث الطمأنينة في القلوب القلقة.'**
  String get descAnxious;

  /// No description provided for @actionReadSurah.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ السورة'**
  String get actionReadSurah;

  /// No description provided for @surahYusuf.
  ///
  /// In ar, this message translates to:
  /// **'سورة يوسف'**
  String get surahYusuf;

  /// No description provided for @descSad.
  ///
  /// In ar, this message translates to:
  /// **'قصة الصبر والفرج بعد الضيق. إنها بلسم للقلوب الحزينة.'**
  String get descSad;

  /// No description provided for @surahRahman.
  ///
  /// In ar, this message translates to:
  /// **'سورة الرحمن'**
  String get surahRahman;

  /// No description provided for @descHappy.
  ///
  /// In ar, this message translates to:
  /// **'خير ما يشكر به الله على نعمه وفضله. فبأي آلاء ربكما تكذبان.'**
  String get descHappy;

  /// No description provided for @surahFatiha.
  ///
  /// In ar, this message translates to:
  /// **'سورة الفاتحة'**
  String get surahFatiha;

  /// No description provided for @descLost.
  ///
  /// In ar, this message translates to:
  /// **'أم الكتاب والدعاء بالهداية للصراط المستقيم في كل حين.'**
  String get descLost;

  /// No description provided for @descTired.
  ///
  /// In ar, this message translates to:
  /// **'لتستريح نفسك ويهدأ بالك بذكر الله قبل المنام.'**
  String get descTired;

  /// No description provided for @actionGoToAzkar.
  ///
  /// In ar, this message translates to:
  /// **'اذهب للأذكار'**
  String get actionGoToAzkar;

  /// No description provided for @becauseYouFeel.
  ///
  /// In ar, this message translates to:
  /// **'لأنك تشعر بـ {mood}'**
  String becauseYouFeel(String mood);

  /// No description provided for @howDoYouFeel.
  ///
  /// In ar, this message translates to:
  /// **'بماذا تشعر الآن؟'**
  String get howDoYouFeel;

  /// No description provided for @unknownName.
  ///
  /// In ar, this message translates to:
  /// **'اسم غير معروف'**
  String get unknownName;

  /// No description provided for @mushafCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مصحف'**
  String mushafCount(int count);

  /// No description provided for @nowPlaying.
  ///
  /// In ar, this message translates to:
  /// **'جاري التشغيل...'**
  String get nowPlaying;

  /// No description provided for @playbackPaused.
  ///
  /// In ar, this message translates to:
  /// **'التشغيل متوقف'**
  String get playbackPaused;

  /// No description provided for @reciterLabel.
  ///
  /// In ar, this message translates to:
  /// **'القارئ'**
  String get reciterLabel;

  /// No description provided for @verseOfTheDay.
  ///
  /// In ar, this message translates to:
  /// **'آية اليوم'**
  String get verseOfTheDay;

  /// No description provided for @dailyVerseText.
  ///
  /// In ar, this message translates to:
  /// **'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا * إِنَّ مَعَ الْعُسْرِ يُسْرًا'**
  String get dailyVerseText;

  /// No description provided for @prayerTimesTitle.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت الصلاة'**
  String get prayerTimesTitle;

  /// No description provided for @noPrayerTimesFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على مواقيت لهذه المدخلات'**
  String get noPrayerTimesFound;

  /// No description provided for @cityLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get cityLabel;

  /// No description provided for @countryLabel.
  ///
  /// In ar, this message translates to:
  /// **'الدولة'**
  String get countryLabel;

  /// No description provided for @updateTimesButton.
  ///
  /// In ar, this message translates to:
  /// **'تحديث المواقيت'**
  String get updateTimesButton;

  /// No description provided for @prayerTimeError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {error}'**
  String prayerTimeError(String error);

  /// No description provided for @sunrise.
  ///
  /// In ar, this message translates to:
  /// **'الشروق'**
  String get sunrise;

  /// No description provided for @nowListening.
  ///
  /// In ar, this message translates to:
  /// **'جاري الاستماع'**
  String get nowListening;

  /// No description provided for @sleepTimer.
  ///
  /// In ar, this message translates to:
  /// **'مؤقت النوم'**
  String get sleepTimer;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تفعيل {feature} قريباً'**
  String comingSoon(Object feature);

  /// No description provided for @startingDownload.
  ///
  /// In ar, this message translates to:
  /// **'جاري بدء التحميل...'**
  String get startingDownload;

  /// No description provided for @download.
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get download;

  /// No description provided for @playlist.
  ///
  /// In ar, this message translates to:
  /// **'القائمة'**
  String get playlist;

  /// No description provided for @currentPlaylist.
  ///
  /// In ar, this message translates to:
  /// **'قائمة التشغيل الحالية'**
  String get currentPlaylist;

  /// No description provided for @audioCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} صوتيات'**
  String audioCount(Object count);

  /// No description provided for @nowPlayingLabel.
  ///
  /// In ar, this message translates to:
  /// **'يعمل الآن'**
  String get nowPlayingLabel;

  /// No description provided for @timeRemaining.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المتبقي: {time}'**
  String timeRemaining(Object time);

  /// No description provided for @stopTimer.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف المؤقت'**
  String get stopTimer;

  /// No description provided for @sleepTimerStopped.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف مؤقت النوم'**
  String get sleepTimerStopped;

  /// No description provided for @timerSetFor.
  ///
  /// In ar, this message translates to:
  /// **'تم ضبط المؤقت لـ {time}'**
  String timerSetFor(Object time);

  /// No description provided for @surahIdNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على معرف السورة'**
  String get surahIdNotFound;

  /// No description provided for @errorLoadingText.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل النص'**
  String get errorLoadingText;

  /// No description provided for @shareRecitationText.
  ///
  /// In ar, this message translates to:
  /// **'استمع إلى {title} بصوت القارئ {reciter} عبر تطبيق المكتبة الإسلامية.\n\n{link}'**
  String shareRecitationText(Object link, Object reciter, Object title);

  /// No description provided for @minutes.
  ///
  /// In ar, this message translates to:
  /// **'{count} دقيقة'**
  String minutes(Object count);

  /// No description provided for @timerOption.
  ///
  /// In ar, this message translates to:
  /// **'{count} دقيقة'**
  String timerOption(String count);

  /// No description provided for @readingModeOnlyForQuran.
  ///
  /// In ar, this message translates to:
  /// **'وضع القراءة متاح للقرآن الكريم فقط'**
  String get readingModeOnlyForQuran;

  /// No description provided for @liveTvTitle.
  ///
  /// In ar, this message translates to:
  /// **'البث المباشر'**
  String get liveTvTitle;

  /// No description provided for @religiousChannelsDescription.
  ///
  /// In ar, this message translates to:
  /// **'قنوات دينية على مدار الساعة'**
  String get religiousChannelsDescription;

  /// No description provided for @videoPlayerError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تشغيل الفيديو'**
  String get videoPlayerError;

  /// No description provided for @checkInternetConnection.
  ///
  /// In ar, this message translates to:
  /// **'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى'**
  String get checkInternetConnection;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @islamicRadioTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإذاعات الإسلامية'**
  String get islamicRadioTitle;

  /// No description provided for @liveRadioDescription.
  ///
  /// In ar, this message translates to:
  /// **'بث مباشر على مدار الساعة'**
  String get liveRadioDescription;

  /// No description provided for @searchRadioHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن إذاعة...'**
  String get searchRadioHint;

  /// No description provided for @videoLibraryTitle.
  ///
  /// In ar, this message translates to:
  /// **'السيرة النبوية'**
  String get videoLibraryTitle;

  /// No description provided for @searchVideoHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في السيرة النبوية...'**
  String get searchVideoHint;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @favoritesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favoritesTitle;

  /// No description provided for @reciters.
  ///
  /// In ar, this message translates to:
  /// **'القراء'**
  String get reciters;

  /// No description provided for @surahs.
  ///
  /// In ar, this message translates to:
  /// **'السور'**
  String get surahs;

  /// No description provided for @noFavoriteReciters.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد قراء في المفضلة'**
  String get noFavoriteReciters;

  /// No description provided for @noFavoriteSurahs.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سور في المفضلة'**
  String get noFavoriteSurahs;

  /// No description provided for @noFavoriteHadiths.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أحاديث في المفضلة'**
  String get noFavoriteHadiths;

  /// No description provided for @unknownReciter.
  ///
  /// In ar, this message translates to:
  /// **'غير معروف'**
  String get unknownReciter;

  /// No description provided for @downloadingSurah.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل سورة {surah}...'**
  String downloadingSurah(String surah);

  /// No description provided for @downloaded.
  ///
  /// In ar, this message translates to:
  /// **'تم التحميل'**
  String get downloaded;

  /// No description provided for @downloadsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التنزيلات'**
  String get downloadsTitle;

  /// No description provided for @downloadedSurahs.
  ///
  /// In ar, this message translates to:
  /// **'السور المحملة'**
  String get downloadedSurahs;

  /// No description provided for @downloadedLibraryDescription.
  ///
  /// In ar, this message translates to:
  /// **'مكتبتك الصوتية المحملة'**
  String get downloadedLibraryDescription;

  /// No description provided for @libraryEmpty.
  ///
  /// In ar, this message translates to:
  /// **'المكتبة فارغة'**
  String get libraryEmpty;

  /// No description provided for @downloadedFilesWillAppearHere.
  ///
  /// In ar, this message translates to:
  /// **'الملفات المحملة ستظهر هنا'**
  String get downloadedFilesWillAppearHere;

  /// No description provided for @downloadedSurahCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} سورة محملة'**
  String downloadedSurahCount(Object count);

  /// No description provided for @audioFile.
  ///
  /// In ar, this message translates to:
  /// **'ملف صوتي'**
  String get audioFile;

  /// No description provided for @deleteFileQuestion.
  ///
  /// In ar, this message translates to:
  /// **'حذف الملف؟'**
  String get deleteFileQuestion;

  /// No description provided for @deleteFileConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا الملف نهائياً؟'**
  String get deleteFileConfirmation;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @booksLibraryTitle.
  ///
  /// In ar, this message translates to:
  /// **'مكتبة الكتب'**
  String get booksLibraryTitle;

  /// No description provided for @articlesAndBooksTitle.
  ///
  /// In ar, this message translates to:
  /// **'المقالات والكتب'**
  String get articlesAndBooksTitle;

  /// No description provided for @searchLibraryHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في المكتبة...'**
  String get searchLibraryHint;

  /// No description provided for @booksLabel.
  ///
  /// In ar, this message translates to:
  /// **'كتب'**
  String get booksLabel;

  /// No description provided for @articlesLabel.
  ///
  /// In ar, this message translates to:
  /// **'مقالات'**
  String get articlesLabel;

  /// No description provided for @audiosLabel.
  ///
  /// In ar, this message translates to:
  /// **'صوتيات'**
  String get audiosLabel;

  /// No description provided for @noSearchResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج بحث'**
  String get noSearchResults;

  /// No description provided for @downloadButton.
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get downloadButton;

  /// No description provided for @pageCount.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {page}'**
  String pageCount(int page);

  /// No description provided for @allRecitersTitle.
  ///
  /// In ar, this message translates to:
  /// **'جميع القراء'**
  String get allRecitersTitle;

  /// No description provided for @chooseYourFavoriteReciter.
  ///
  /// In ar, this message translates to:
  /// **'اختر القارئ المفضل لديك'**
  String get chooseYourFavoriteReciter;

  /// No description provided for @searchForReciter.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن قارئ...'**
  String get searchForReciter;

  /// No description provided for @noResultsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResultsFound;

  /// No description provided for @trySearchingWithOtherWords.
  ///
  /// In ar, this message translates to:
  /// **'جرب البحث بكلمات أخرى'**
  String get trySearchingWithOtherWords;

  /// No description provided for @errorOccurred.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get errorOccurred;

  /// No description provided for @mainMenu.
  ///
  /// In ar, this message translates to:
  /// **'القائمة الرئيسية'**
  String get mainMenu;

  /// No description provided for @readingMedia.
  ///
  /// In ar, this message translates to:
  /// **'محتوى القراءة'**
  String get readingMedia;

  /// No description provided for @utilitiesTools.
  ///
  /// In ar, this message translates to:
  /// **'الأدوات المساعدة'**
  String get utilitiesTools;

  /// No description provided for @appNameEnglish.
  ///
  /// In ar, this message translates to:
  /// **'Islam Home'**
  String get appNameEnglish;

  /// No description provided for @appNameArabic.
  ///
  /// In ar, this message translates to:
  /// **'بيت الإسلام'**
  String get appNameArabic;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @hadith.
  ///
  /// In ar, this message translates to:
  /// **'الحديث'**
  String get hadith;

  /// No description provided for @surahName.
  ///
  /// In ar, this message translates to:
  /// **'{name}'**
  String surahName(String name);

  /// No description provided for @reciterName.
  ///
  /// In ar, this message translates to:
  /// **'{name}'**
  String reciterName(String name);

  /// No description provided for @useLocation.
  ///
  /// In ar, this message translates to:
  /// **'استخدام الموقع الحالي'**
  String get useLocation;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In ar, this message translates to:
  /// **'خدمات الموقع معطلة.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionsDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الوصول للموقع.'**
  String get locationPermissionsDenied;

  /// No description provided for @locationPermissionsPermanentlyDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الموقع بشكل دائم.'**
  String get locationPermissionsPermanentlyDenied;

  /// No description provided for @failedToGetLocation.
  ///
  /// In ar, this message translates to:
  /// **'فشل في الحصول على الموقع: {error}'**
  String failedToGetLocation(String error);

  /// No description provided for @updateLocation.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الموقع'**
  String get updateLocation;

  /// No description provided for @surahDuha.
  ///
  /// In ar, this message translates to:
  /// **'سورة الضحى'**
  String get surahDuha;

  /// No description provided for @descDuha.
  ///
  /// In ar, this message translates to:
  /// **'ما ودعك ربك وما قلى. رسالة ربانية لكل قلب يشعر بالضيق والحزن.'**
  String get descDuha;

  /// No description provided for @actionGoToDua.
  ///
  /// In ar, this message translates to:
  /// **'اذهب للأدعية'**
  String get actionGoToDua;

  /// No description provided for @startTasbeeh.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التسبيح'**
  String get startTasbeeh;

  /// No description provided for @rememberAllah.
  ///
  /// In ar, this message translates to:
  /// **'ذكر الله'**
  String get rememberAllah;

  /// No description provided for @descHappyDhikr.
  ///
  /// In ar, this message translates to:
  /// **'الحمد لله تزيد النعمة وتبارك في الرزق وتديم السعادة.'**
  String get descHappyDhikr;

  /// No description provided for @allahIsNear.
  ///
  /// In ar, this message translates to:
  /// **'الله قريب منك'**
  String get allahIsNear;

  /// No description provided for @descLostDhikr.
  ///
  /// In ar, this message translates to:
  /// **'الله قريب منك دائماً، يوجهك ويسمع دعاءك إذا ضللت الطريق.'**
  String get descLostDhikr;

  /// No description provided for @descAnxiousDhikr.
  ///
  /// In ar, this message translates to:
  /// **'ذكر الله يُطمئن القلوب القلقة. ردِّد: ﴿إن مع العسر يسراً﴾ وتوكل على رحمته.'**
  String get descAnxiousDhikr;

  /// No description provided for @rewardForTired.
  ///
  /// In ar, this message translates to:
  /// **'أجر التعب'**
  String get rewardForTired;

  /// No description provided for @descTiredDhikr.
  ///
  /// In ar, this message translates to:
  /// **'تذكر أن تعبك مأجور، وأن الله لا يحملك فوق طاقتك. استرح بذكر الله.'**
  String get descTiredDhikr;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في القرآن، الحديث، الأذكار...'**
  String get searchHint;

  /// No description provided for @searchQuranSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'القرآن: {surah} ({ayah})'**
  String searchQuranSubtitle(String surah, int ayah);

  /// No description provided for @searchHadithSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الحديث: {book} - {chapter}'**
  String searchHadithSubtitle(String book, String chapter);

  /// No description provided for @searchAdhkarSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار: {category}'**
  String searchAdhkarSubtitle(String category);

  /// No description provided for @exploreLibrary.
  ///
  /// In ar, this message translates to:
  /// **'استكشف المكتبة'**
  String get exploreLibrary;

  /// No description provided for @searchDescription.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن الآيات والأحاديث والأدعية'**
  String get searchDescription;

  /// No description provided for @khatmaPlannerTitle.
  ///
  /// In ar, this message translates to:
  /// **'مخطط الختمة الذكي'**
  String get khatmaPlannerTitle;

  /// No description provided for @khatmaPlannerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حدد المدة التي ترغب بختم القرآن فيها'**
  String get khatmaPlannerSubtitle;

  /// No description provided for @startKhatma.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الختمة'**
  String get startKhatma;

  /// No description provided for @days.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get days;

  /// No description provided for @pagesDaily.
  ///
  /// In ar, this message translates to:
  /// **'صفحات يومياً'**
  String get pagesDaily;

  /// No description provided for @pagesPerPrayer.
  ///
  /// In ar, this message translates to:
  /// **'صفحات لكل صلاة'**
  String get pagesPerPrayer;

  /// No description provided for @remainingToday.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي لك اليوم: {count} صفحات'**
  String remainingToday(int count);

  /// No description provided for @onTrack.
  ///
  /// In ar, this message translates to:
  /// **'أنت على الجدول'**
  String get onTrack;

  /// No description provided for @setupPlan.
  ///
  /// In ar, this message translates to:
  /// **'ضبط الخطة'**
  String get setupPlan;

  /// No description provided for @cancelPlan.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الخطة'**
  String get cancelPlan;

  /// No description provided for @manageNotificationSettings.
  ///
  /// In ar, this message translates to:
  /// **'إدارة إعدادات الإشعارات'**
  String get manageNotificationSettings;

  /// No description provided for @manageNotificationSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'فتح إعدادات النظام للإشعارات'**
  String get manageNotificationSettingsSubtitle;

  /// No description provided for @notificationDiagnosticsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تشخيص الإشعارات'**
  String get notificationDiagnosticsTitle;

  /// No description provided for @notificationDiagnosticsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من حالة الصلاحيات الفعلية لضمان عمل تنبيهات الآذان'**
  String get notificationDiagnosticsSubtitle;

  /// No description provided for @notificationDiagnosticsHealthy.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإشعارات سليمة'**
  String get notificationDiagnosticsHealthy;

  /// No description provided for @notificationDiagnosticsNeedsFix.
  ///
  /// In ar, this message translates to:
  /// **'بعض الإعدادات تحتاج إصلاح'**
  String get notificationDiagnosticsNeedsFix;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية الإشعارات'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يجب تفعيلها لاستلام تنبيهات الآذان والتذكير'**
  String get notificationPermissionSubtitle;

  /// No description provided for @exactAlarmPermissionTitle.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية المنبّهات الدقيقة'**
  String get exactAlarmPermissionTitle;

  /// No description provided for @exactAlarmPermissionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مطلوبة في أندرويد 12+ لتشغيل تنبيه الآذان في وقته الدقيق'**
  String get exactAlarmPermissionSubtitle;

  /// No description provided for @batteryOptimizationTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحسين البطارية'**
  String get batteryOptimizationTitle;

  /// No description provided for @batteryOptimizationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عطّل تحسين البطارية لهذا التطبيق لمنع تأخير أو حظر تنبيهات الآذان'**
  String get batteryOptimizationSubtitle;

  /// No description provided for @notRequiredOnThisDevice.
  ///
  /// In ar, this message translates to:
  /// **'غير مطلوب على هذا الجهاز'**
  String get notRequiredOnThisDevice;

  /// No description provided for @fixNow.
  ///
  /// In ar, this message translates to:
  /// **'إصلاح الآن'**
  String get fixNow;

  /// No description provided for @enabled.
  ///
  /// In ar, this message translates to:
  /// **'مفعّل'**
  String get enabled;

  /// No description provided for @requiresFix.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج إصلاح'**
  String get requiresFix;

  /// No description provided for @refreshStatus.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الحالة'**
  String get refreshStatus;

  /// No description provided for @openSystemSettings.
  ///
  /// In ar, this message translates to:
  /// **'فتح إعدادات النظام'**
  String get openSystemSettings;

  /// No description provided for @continueYourKhatma.
  ///
  /// In ar, this message translates to:
  /// **'واصل ختمـتك'**
  String get continueYourKhatma;

  /// No description provided for @juzAndSurah.
  ///
  /// In ar, this message translates to:
  /// **'الجزء {juz} - {surah}'**
  String juzAndSurah(Object juz, Object surah);

  /// No description provided for @smartSuggestionsForNewPlan.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات ذكية لنظامك الجديد:'**
  String get smartSuggestionsForNewPlan;

  /// No description provided for @khatmaInMonth.
  ///
  /// In ar, this message translates to:
  /// **'ختمة في شهر'**
  String get khatmaInMonth;

  /// No description provided for @oneJuzDaily.
  ///
  /// In ar, this message translates to:
  /// **'1 جزء يومياً'**
  String get oneJuzDaily;

  /// No description provided for @khatmaInTwoMonths.
  ///
  /// In ar, this message translates to:
  /// **'ختمة في شهرين'**
  String get khatmaInTwoMonths;

  /// No description provided for @fifteenPagesDaily.
  ///
  /// In ar, this message translates to:
  /// **'15 صفحة يومياً'**
  String get fifteenPagesDaily;

  /// No description provided for @pagesRemainingToday.
  ///
  /// In ar, this message translates to:
  /// **'بقي لك {count} صفحات لليوم'**
  String pagesRemainingToday(Object count);

  /// No description provided for @khatmaHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الختمات'**
  String get khatmaHistory;

  /// No description provided for @khatmaSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الختمة'**
  String get khatmaSettings;

  /// No description provided for @duaKhatm.
  ///
  /// In ar, this message translates to:
  /// **'دعاء ختم القرآن'**
  String get duaKhatm;

  /// No description provided for @mayAllahAccept.
  ///
  /// In ar, this message translates to:
  /// **'تقبل الله منك'**
  String get mayAllahAccept;

  /// No description provided for @shareDua.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الدعاء'**
  String get shareDua;

  /// No description provided for @mayAllahAcceptAll.
  ///
  /// In ar, this message translates to:
  /// **'تقبل الله منا ومنكم'**
  String get mayAllahAcceptAll;

  /// No description provided for @continueReading.
  ///
  /// In ar, this message translates to:
  /// **'إكمال القراءة'**
  String get continueReading;

  /// No description provided for @continueListening.
  ///
  /// In ar, this message translates to:
  /// **'إكمال الاستماع'**
  String get continueListening;

  /// No description provided for @activePlans.
  ///
  /// In ar, this message translates to:
  /// **'الخطط النشطة'**
  String get activePlans;

  /// No description provided for @totalAchievement.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإنجاز'**
  String get totalAchievement;

  /// No description provided for @khatmaCount.
  ///
  /// In ar, this message translates to:
  /// **'لقد ختمت القرآن {count} مرات'**
  String khatmaCount(int count);

  /// No description provided for @currentPageLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة الحالية'**
  String get currentPageLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get remainingLabel;

  /// No description provided for @dailyTargetLabel.
  ///
  /// In ar, this message translates to:
  /// **'ورد اليوم'**
  String get dailyTargetLabel;

  /// No description provided for @duration.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get duration;

  /// No description provided for @dailyGoal.
  ///
  /// In ar, this message translates to:
  /// **'الهدف اليومي'**
  String get dailyGoal;

  /// No description provided for @khatmaSuccessful.
  ///
  /// In ar, this message translates to:
  /// **'تم الختم بنجاح'**
  String get khatmaSuccessful;

  /// No description provided for @noActivePlans.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد خطط نشطة حالياً'**
  String get noActivePlans;

  /// No description provided for @noHistoryYet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تاريخ مسجل بعد'**
  String get noHistoryYet;

  /// No description provided for @previousAchievements.
  ///
  /// In ar, this message translates to:
  /// **'إنجازات سابقة:'**
  String get previousAchievements;

  /// No description provided for @previousKhatmaHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الختمات السابقة'**
  String get previousKhatmaHistory;

  /// No description provided for @blessedKhatma.
  ///
  /// In ar, this message translates to:
  /// **'ختمة مباركة'**
  String get blessedKhatma;

  /// No description provided for @noKhatmasRecorded.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد ختمات مسجلة بعد'**
  String get noKhatmasRecorded;

  /// No description provided for @khatmCompletedPraise.
  ///
  /// In ar, this message translates to:
  /// **'تم الختم بحمد الله'**
  String get khatmCompletedPraise;

  /// No description provided for @daysCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم'**
  String daysCount(int count);

  /// No description provided for @newKhatma.
  ///
  /// In ar, this message translates to:
  /// **'ختمة جديدة'**
  String get newKhatma;

  /// No description provided for @prayerAdjustment.
  ///
  /// In ar, this message translates to:
  /// **'تعديل مواقيت الصلاة'**
  String get prayerAdjustment;

  /// No description provided for @prayerAdjustmentSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة أو إنقاص دقائق للمواقيت (DST)'**
  String get prayerAdjustmentSubtitle;

  /// No description provided for @adjustMinutes.
  ///
  /// In ar, this message translates to:
  /// **'تعديل {minutes} دقيقة'**
  String adjustMinutes(Object minutes);

  /// No description provided for @manualOffset.
  ///
  /// In ar, this message translates to:
  /// **'فرق التوقيت اليدوي'**
  String get manualOffset;

  /// No description provided for @hours.
  ///
  /// In ar, this message translates to:
  /// **'{count} ساعة'**
  String hours(Object count);

  /// No description provided for @hour.
  ///
  /// In ar, this message translates to:
  /// **'ساعة'**
  String get hour;

  /// No description provided for @adjustHours.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الساعات'**
  String get adjustHours;

  /// No description provided for @useAutoLocation.
  ///
  /// In ar, this message translates to:
  /// **'استخدام الموقع التلقائي (GPS)'**
  String get useAutoLocation;

  /// No description provided for @moreSettings.
  ///
  /// In ar, this message translates to:
  /// **'المزيد من الإعدادات...'**
  String get moreSettings;

  /// No description provided for @audioServiceNotReady.
  ///
  /// In ar, this message translates to:
  /// **'خدمة الصوت لم تكتمل بعد، يرجى المحاولة مرة أخرى'**
  String get audioServiceNotReady;

  /// No description provided for @playingInBackground.
  ///
  /// In ar, this message translates to:
  /// **'تم تشغيل المقطع كصوت في الخلفية'**
  String get playingInBackground;

  /// No description provided for @failedToPlay.
  ///
  /// In ar, this message translates to:
  /// **'فشل تشغيل المقطع: {error}'**
  String failedToPlay(String error);

  /// No description provided for @later.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get later;

  /// No description provided for @activateNow.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الآن'**
  String get activateNow;

  /// No description provided for @downloadAllStarted.
  ///
  /// In ar, this message translates to:
  /// **'تم بدء تحميل الكل إلى القائمة'**
  String get downloadAllStarted;

  /// No description provided for @noServerLinkError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: لا يوجد رابط خادم للقارئ'**
  String get noServerLinkError;

  /// No description provided for @playlistPlayError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تشغيل القائمة: {error}'**
  String playlistPlayError(String error);

  /// No description provided for @grantPermission.
  ///
  /// In ar, this message translates to:
  /// **'منح الإذن'**
  String get grantPermission;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {message}'**
  String error(String message);

  /// No description provided for @noSensors.
  ///
  /// In ar, this message translates to:
  /// **'الجهاز لا يحتوي على مستشعرات'**
  String get noSensors;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @playlistNotFound.
  ///
  /// In ar, this message translates to:
  /// **'القائمة غير موجودة'**
  String get playlistNotFound;

  /// No description provided for @createNewPlaylist.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء قائمة جديدة'**
  String get createNewPlaylist;

  /// No description provided for @playlistImportedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم استيراد قائمة التشغيل بنجاح'**
  String get playlistImportedSuccessfully;

  /// No description provided for @readingSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات القراءة'**
  String get readingSettings;

  /// No description provided for @translation.
  ///
  /// In ar, this message translates to:
  /// **'الترجمة'**
  String get translation;

  /// No description provided for @tafsir.
  ///
  /// In ar, this message translates to:
  /// **'التفسير'**
  String get tafsir;

  /// No description provided for @switchToListView.
  ///
  /// In ar, this message translates to:
  /// **'تبديل إلى عرض القائمة'**
  String get switchToListView;

  /// No description provided for @switchToFlowView.
  ///
  /// In ar, this message translates to:
  /// **'تبديل إلى عرض الترتيل'**
  String get switchToFlowView;

  /// No description provided for @surah.
  ///
  /// In ar, this message translates to:
  /// **'سورة'**
  String get surah;

  /// No description provided for @pageLabel.
  ///
  /// In ar, this message translates to:
  /// **'صفحة'**
  String get pageLabel;

  /// No description provided for @juz.
  ///
  /// In ar, this message translates to:
  /// **'الجزء'**
  String get juz;

  /// No description provided for @hizb.
  ///
  /// In ar, this message translates to:
  /// **'الحزب'**
  String get hizb;

  /// No description provided for @nightMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get nightMode;

  /// No description provided for @dayMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع النهاري'**
  String get dayMode;

  /// No description provided for @lastReadSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الآية كآخر قراءة'**
  String get lastReadSaved;

  /// No description provided for @lastReadUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث وقت آخر قراءة'**
  String get lastReadUpdated;

  /// No description provided for @lastReadReplaced.
  ///
  /// In ar, this message translates to:
  /// **'تم استبدال {prevSurah}:{prevAyah} بـ {newSurah}:{newAyah}'**
  String lastReadReplaced(
    String prevSurah,
    int prevAyah,
    String newSurah,
    int newAyah,
  );

  /// No description provided for @lastReadSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل الحفظ. يرجى المحاولة مرة أخرى.'**
  String get lastReadSaveFailed;

  /// No description provided for @narrator.
  ///
  /// In ar, this message translates to:
  /// **'الراوي'**
  String get narrator;

  /// No description provided for @book.
  ///
  /// In ar, this message translates to:
  /// **'الكتاب'**
  String get book;

  /// No description provided for @chapter.
  ///
  /// In ar, this message translates to:
  /// **'الباب'**
  String get chapter;

  /// No description provided for @copy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copy;

  /// No description provided for @copiedToClipboard.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ إلى الحافظة'**
  String get copiedToClipboard;

  /// No description provided for @jumpToHadith.
  ///
  /// In ar, this message translates to:
  /// **'انتقال لحديث'**
  String get jumpToHadith;

  /// No description provided for @searchHadith.
  ///
  /// In ar, this message translates to:
  /// **'بحث في الأحاديث...'**
  String get searchHadith;

  /// No description provided for @bookmark.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get bookmark;

  /// No description provided for @hijriAdjustment.
  ///
  /// In ar, this message translates to:
  /// **'تعديل التاريخ الهجري'**
  String get hijriAdjustment;

  /// No description provided for @hijriAdjustmentSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'زيادة أو نقصان الأيام لتوافق رؤية الهلال في بلدك'**
  String get hijriAdjustmentSubtitle;

  /// No description provided for @adjustDays.
  ///
  /// In ar, this message translates to:
  /// **'تعديل {days} يوم'**
  String adjustDays(Object days);

  /// No description provided for @fontSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الخط'**
  String get fontSettings;

  /// No description provided for @mushafFontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم المصحف'**
  String get mushafFontSize;

  /// No description provided for @translationFontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الترجمة'**
  String get translationFontSize;

  /// No description provided for @playlists.
  ///
  /// In ar, this message translates to:
  /// **'قوائم التشغيل'**
  String get playlists;

  /// No description provided for @addToPlaylist.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إلى قائمة تشغيل'**
  String get addToPlaylist;

  /// No description provided for @noPlaylistsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد قوائم تشغيل بعد'**
  String get noPlaylistsYet;

  /// No description provided for @playlistCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء قائمة التشغيل بنجاح'**
  String get playlistCreated;

  /// No description provided for @deletePlaylist.
  ///
  /// In ar, this message translates to:
  /// **'حذف القائمة'**
  String get deletePlaylist;

  /// No description provided for @renamePlaylist.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الاسم'**
  String get renamePlaylist;

  /// No description provided for @playlistNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم القائمة...'**
  String get playlistNameHint;

  /// No description provided for @create.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get create;

  /// No description provided for @surahsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} سور'**
  String surahsCount(int count);

  /// No description provided for @noPlaylistsMessage.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد قوائم تشغيل. أنشئ واحدة من قسم المفضلات.'**
  String get noPlaylistsMessage;

  /// No description provided for @addedToPlaylist.
  ///
  /// In ar, this message translates to:
  /// **'تمت الإضافة إلى {playlistName}'**
  String addedToPlaylist(Object playlistName);

  /// No description provided for @duaKhatmQuran.
  ///
  /// In ar, this message translates to:
  /// **'دعاء ختم القرآن'**
  String get duaKhatmQuran;

  /// No description provided for @lastRead.
  ///
  /// In ar, this message translates to:
  /// **'آخر قراءة'**
  String get lastRead;

  /// No description provided for @chooseReciter.
  ///
  /// In ar, this message translates to:
  /// **'اختر المقرئ'**
  String get chooseReciter;

  /// No description provided for @fontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get fontSize;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @errorPlayingAudio.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تشغيل الصوت: {message}'**
  String errorPlayingAudio(String message);

  /// No description provided for @navigatedToAyah.
  ///
  /// In ar, this message translates to:
  /// **'تم الانتقال إلى {surah} - آية {ayah}'**
  String navigatedToAyah(String surah, int ayah);

  /// No description provided for @setTarget.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الهدف'**
  String get setTarget;

  /// No description provided for @tasbeehHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل التسبيح'**
  String get tasbeehHistory;

  /// No description provided for @noTasbeehToday.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تسبيح لهذا اليوم'**
  String get noTasbeehToday;

  /// No description provided for @dailySummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص اليوم'**
  String get dailySummary;

  /// No description provided for @hourlyBreakdown.
  ///
  /// In ar, this message translates to:
  /// **'توزيع الساعات'**
  String get hourlyBreakdown;

  /// No description provided for @detailedLog.
  ///
  /// In ar, this message translates to:
  /// **'السجل التفصيلي'**
  String get detailedLog;

  /// No description provided for @weeklyActivity.
  ///
  /// In ar, this message translates to:
  /// **'نشاط الأسبوع'**
  String get weeklyActivity;

  /// No description provided for @streakDays.
  ///
  /// In ar, this message translates to:
  /// **'سلسلة {count} يوم'**
  String streakDays(int count);

  /// No description provided for @todayTotal.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get todayTotal;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @allTimeTasbeehs.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي كل الأوقات'**
  String get allTimeTasbeehs;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @streak.
  ///
  /// In ar, this message translates to:
  /// **'السلسلة'**
  String get streak;

  /// No description provided for @setCompleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتملت الجولة!'**
  String get setCompleteTitle;

  /// No description provided for @setCompleteSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تقبل الله ذكرك'**
  String get setCompleteSubtitle;

  /// No description provided for @totalLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get totalLabel;

  /// No description provided for @calculationMethodTitle.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الحساب'**
  String get calculationMethodTitle;

  /// No description provided for @sidebarMainQuran.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية والقرآن'**
  String get sidebarMainQuran;

  /// No description provided for @sidebarTools.
  ///
  /// In ar, this message translates to:
  /// **'أدوات المسلم'**
  String get sidebarTools;

  /// No description provided for @sidebarContent.
  ///
  /// In ar, this message translates to:
  /// **'المحتوى الإسلامي'**
  String get sidebarContent;

  /// No description provided for @sidebarOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get sidebarOther;

  /// No description provided for @sidebarTagline.
  ///
  /// In ar, this message translates to:
  /// **'رحلة روحية ومكتبة'**
  String get sidebarTagline;

  /// No description provided for @sidebarAppDescription.
  ///
  /// In ar, this message translates to:
  /// **'رفيقك الإسلامي اليومي'**
  String get sidebarAppDescription;

  /// No description provided for @sira.
  ///
  /// In ar, this message translates to:
  /// **'حياة الرسول'**
  String get sira;

  /// No description provided for @prophetLife.
  ///
  /// In ar, this message translates to:
  /// **'حياة الرسول ﷺ'**
  String get prophetLife;

  /// No description provided for @allSections.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allSections;

  /// No description provided for @activeDownloads.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get activeDownloads;

  /// No description provided for @completedDownloads.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get completedDownloads;

  /// No description provided for @downloadingTab.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل'**
  String get downloadingTab;

  /// No description provided for @downloadedTab.
  ///
  /// In ar, this message translates to:
  /// **'المحملة'**
  String get downloadedTab;

  /// No description provided for @noActiveDownloads.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تحميلات نشطة'**
  String get noActiveDownloads;

  /// No description provided for @noActiveDownloadsDesc.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تحميل السور للاستماع إليها لاحقاً بدون إنترنت'**
  String get noActiveDownloadsDesc;

  /// No description provided for @quranSection.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم'**
  String get quranSection;

  /// No description provided for @seerahSection.
  ///
  /// In ar, this message translates to:
  /// **'السيرة النبوية'**
  String get seerahSection;

  /// No description provided for @emptyDownloadsHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل التنزيلات فارغ'**
  String get emptyDownloadsHistory;

  /// No description provided for @emptyDownloadsHistoryDesc.
  ///
  /// In ar, this message translates to:
  /// **'لم تقم بتنزيل أي سور بعد'**
  String get emptyDownloadsHistoryDesc;

  /// No description provided for @khatmaV2Title.
  ///
  /// In ar, this message translates to:
  /// **'ختمة جديدة'**
  String get khatmaV2Title;

  /// No description provided for @khatmaV2TypeStepTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما هو هدفك؟'**
  String get khatmaV2TypeStepTitle;

  /// No description provided for @khatmaV2Reading.
  ///
  /// In ar, this message translates to:
  /// **'قراءة عامة'**
  String get khatmaV2Reading;

  /// No description provided for @khatmaV2ReadingDesc.
  ///
  /// In ar, this message translates to:
  /// **'قراءة كاملة للقرآن الكريم'**
  String get khatmaV2ReadingDesc;

  /// No description provided for @khatmaV2Memorization.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get khatmaV2Memorization;

  /// No description provided for @khatmaV2MemorizationDesc.
  ///
  /// In ar, this message translates to:
  /// **'التركيز على الحفظ مع متابعة ذكية'**
  String get khatmaV2MemorizationDesc;

  /// No description provided for @khatmaV2Revision.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة'**
  String get khatmaV2Revision;

  /// No description provided for @khatmaV2RevisionDesc.
  ///
  /// In ar, this message translates to:
  /// **'تثبيت حفظك السابق'**
  String get khatmaV2RevisionDesc;

  /// No description provided for @khatmaV2Listening.
  ///
  /// In ar, this message translates to:
  /// **'استماع'**
  String get khatmaV2Listening;

  /// No description provided for @khatmaV2ListeningDesc.
  ///
  /// In ar, this message translates to:
  /// **'الاستماع المتدرج للقرآن مع تتبع يومي'**
  String get khatmaV2ListeningDesc;

  /// No description provided for @khatmaV2DetailsStepTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الختمة'**
  String get khatmaV2DetailsStepTitle;

  /// No description provided for @khatmaV2TitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'العنوان (مثلاً: ختمة رمضان)'**
  String get khatmaV2TitleLabel;

  /// No description provided for @khatmaV2Range.
  ///
  /// In ar, this message translates to:
  /// **'النطاق'**
  String get khatmaV2Range;

  /// No description provided for @khatmaV2StartPage.
  ///
  /// In ar, this message translates to:
  /// **'صفحة البداية'**
  String get khatmaV2StartPage;

  /// No description provided for @khatmaV2EndPage.
  ///
  /// In ar, this message translates to:
  /// **'صفحة النهاية'**
  String get khatmaV2EndPage;

  /// No description provided for @khatmaV2SchedulingStepTitle.
  ///
  /// In ar, this message translates to:
  /// **'الجدولة والمحرك'**
  String get khatmaV2SchedulingStepTitle;

  /// No description provided for @khatmaV2DurationDays.
  ///
  /// In ar, this message translates to:
  /// **'المدة (بالأيام)'**
  String get khatmaV2DurationDays;

  /// No description provided for @khatmaV2QuickDurations.
  ///
  /// In ar, this message translates to:
  /// **'مدد سريعة'**
  String get khatmaV2QuickDurations;

  /// No description provided for @khatmaV2EnginePrefs.
  ///
  /// In ar, this message translates to:
  /// **'تفضيلات المحرك'**
  String get khatmaV2EnginePrefs;

  /// No description provided for @khatmaV2SmartRemediation.
  ///
  /// In ar, this message translates to:
  /// **'المعالجة الذكية'**
  String get khatmaV2SmartRemediation;

  /// No description provided for @khatmaV2SmartRemediationDesc.
  ///
  /// In ar, this message translates to:
  /// **'يعدل هدفك تلقائياً إذا فاتك يوم'**
  String get khatmaV2SmartRemediationDesc;

  /// No description provided for @khatmaV2FixedDaily.
  ///
  /// In ar, this message translates to:
  /// **'هدف يومي ثابت'**
  String get khatmaV2FixedDaily;

  /// No description provided for @khatmaV2FixedDailyDesc.
  ///
  /// In ar, this message translates to:
  /// **'لا يتغير أبداً، حتى لو تأخر التقدم'**
  String get khatmaV2FixedDailyDesc;

  /// No description provided for @khatmaV2StartJourney.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الرحلة'**
  String get khatmaV2StartJourney;

  /// No description provided for @khatmaV2Continue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get khatmaV2Continue;

  /// No description provided for @khatmaV2Back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get khatmaV2Back;

  /// No description provided for @khatmaV2MyKhatma.
  ///
  /// In ar, this message translates to:
  /// **'ختمتي لـ {type}'**
  String khatmaV2MyKhatma(Object type);

  /// No description provided for @khatmaV2NoActive.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ختمة نشطة'**
  String get khatmaV2NoActive;

  /// No description provided for @khatmaV2StartJourneyDesc.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ رحلة جديدة مع نظام الختمة الذكي.'**
  String get khatmaV2StartJourneyDesc;

  /// No description provided for @khatmaV2SetupNew.
  ///
  /// In ar, this message translates to:
  /// **'إعداد ختمة جديدة'**
  String get khatmaV2SetupNew;

  /// No description provided for @khatmaV2DeleteTrack.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا المسار'**
  String get khatmaV2DeleteTrack;

  /// No description provided for @khatmaV2DeleteTrackTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المسار؟'**
  String get khatmaV2DeleteTrackTitle;

  /// No description provided for @khatmaV2DeleteTrackBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف \"{title}\" وكل تقدمه بشكل نهائي.'**
  String khatmaV2DeleteTrackBody(Object title);

  /// No description provided for @khatmaV2RecordPage.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل صفحة {page}'**
  String khatmaV2RecordPage(Object page);

  /// No description provided for @khatmaV2SelectTrack.
  ///
  /// In ar, this message translates to:
  /// **'اختر الختمة'**
  String get khatmaV2SelectTrack;

  /// No description provided for @khatmaV2ProgressSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التقدم في {track}'**
  String khatmaV2ProgressSaved(Object track);

  /// No description provided for @khatmaV2TrackTypeSuffix.
  ///
  /// In ar, this message translates to:
  /// **'مسار {type}'**
  String khatmaV2TrackTypeSuffix(Object type);

  /// No description provided for @khatmaV2UnitLabel.
  ///
  /// In ar, this message translates to:
  /// **'وحدة التتبع'**
  String get khatmaV2UnitLabel;

  /// No description provided for @khatmaV2UnitPage.
  ///
  /// In ar, this message translates to:
  /// **'صفحات'**
  String get khatmaV2UnitPage;

  /// No description provided for @khatmaV2UnitJuz.
  ///
  /// In ar, this message translates to:
  /// **'أجزاء'**
  String get khatmaV2UnitJuz;

  /// No description provided for @khatmaV2StartJuz.
  ///
  /// In ar, this message translates to:
  /// **'جزء البداية'**
  String get khatmaV2StartJuz;

  /// No description provided for @khatmaV2EndJuz.
  ///
  /// In ar, this message translates to:
  /// **'جزء النهاية'**
  String get khatmaV2EndJuz;

  /// No description provided for @khatmaV2JuzCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأجزاء'**
  String get khatmaV2JuzCount;

  /// No description provided for @khatmaV2RecordJuz.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الجزء {juz}'**
  String khatmaV2RecordJuz(Object juz);

  /// No description provided for @khatmaV2UnitPageSingle.
  ///
  /// In ar, this message translates to:
  /// **'صفحة'**
  String get khatmaV2UnitPageSingle;

  /// No description provided for @khatmaV2UnitJuzSingle.
  ///
  /// In ar, this message translates to:
  /// **'جزء'**
  String get khatmaV2UnitJuzSingle;

  /// No description provided for @khatmaHeatmapLess.
  ///
  /// In ar, this message translates to:
  /// **'أقل'**
  String get khatmaHeatmapLess;

  /// No description provided for @khatmaHeatmapMore.
  ///
  /// In ar, this message translates to:
  /// **'أكثر'**
  String get khatmaHeatmapMore;

  /// No description provided for @khatmaV2UnitSurah.
  ///
  /// In ar, this message translates to:
  /// **'سور'**
  String get khatmaV2UnitSurah;

  /// No description provided for @khatmaV2UnitSurahSingle.
  ///
  /// In ar, this message translates to:
  /// **'سورة'**
  String get khatmaV2UnitSurahSingle;

  /// No description provided for @khatmaV2StartSurah.
  ///
  /// In ar, this message translates to:
  /// **'سورة البداية'**
  String get khatmaV2StartSurah;

  /// No description provided for @khatmaV2EndSurah.
  ///
  /// In ar, this message translates to:
  /// **'سورة النهاية'**
  String get khatmaV2EndSurah;

  /// No description provided for @khatmaV2RecordSurah.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل سورة {surah}'**
  String khatmaV2RecordSurah(Object surah);

  /// No description provided for @khatmaV2ValidationRangeOrder.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تكون البداية أصغر من أو تساوي النهاية.'**
  String get khatmaV2ValidationRangeOrder;

  /// No description provided for @khatmaV2ValidationStartOutOfRange.
  ///
  /// In ar, this message translates to:
  /// **'قيمة البداية يجب أن تكون بين 1 و {max}.'**
  String khatmaV2ValidationStartOutOfRange(int max);

  /// No description provided for @khatmaV2ValidationEndOutOfRange.
  ///
  /// In ar, this message translates to:
  /// **'قيمة النهاية يجب أن تكون بين 1 و {max}.'**
  String khatmaV2ValidationEndOutOfRange(int max);

  /// No description provided for @khatmaV2ValidationDurationDays.
  ///
  /// In ar, this message translates to:
  /// **'مدة الخطة يجب أن تكون يومًا واحدًا على الأقل.'**
  String get khatmaV2ValidationDurationDays;

  /// No description provided for @playAyah.
  ///
  /// In ar, this message translates to:
  /// **'استماع للآية'**
  String get playAyah;

  /// No description provided for @testNotification.
  ///
  /// In ar, this message translates to:
  /// **'اختبار الإشعار'**
  String get testNotification;

  /// No description provided for @testNotificationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للتأكد من أن التنبيهات تعمل'**
  String get testNotificationSubtitle;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In ar, this message translates to:
  /// **'إذن الموقع مطلوب'**
  String get locationPermissionRequired;

  /// No description provided for @unableToStartAudioTryAgain.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تشغيل الصوت الآن. يرجى المحاولة مرة أخرى.'**
  String get unableToStartAudioTryAgain;

  /// No description provided for @guestUser.
  ///
  /// In ar, this message translates to:
  /// **'زائر'**
  String get guestUser;

  /// No description provided for @appVersionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String appVersionLabel(Object version);

  /// No description provided for @reciterNoSurahsAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سور متاحة لهذا القارئ'**
  String get reciterNoSurahsAvailable;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @adhkarTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get adhkarTitle;

  /// No description provided for @adhkarSearchTooltip.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get adhkarSearchTooltip;

  /// No description provided for @adhkarFavoritesTooltip.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get adhkarFavoritesTooltip;

  /// No description provided for @noAdhkarDataFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات أذكار'**
  String get noAdhkarDataFound;

  /// No description provided for @noAdhkarInCategory.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أذكار في هذا القسم'**
  String get noAdhkarInCategory;

  /// No description provided for @searchAdhkarHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في النص العربي أو الإنجليزي أو القسم'**
  String get searchAdhkarHint;

  /// No description provided for @typeToSearchAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'اكتب للبحث في الأذكار'**
  String get typeToSearchAdhkar;

  /// No description provided for @noAdhkarMatches.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noAdhkarMatches;

  /// No description provided for @favoriteAdhkarTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار المفضلة'**
  String get favoriteAdhkarTitle;

  /// No description provided for @noFavoriteAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناصر في المفضلة'**
  String get noFavoriteAdhkar;

  /// No description provided for @dhikrDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الذكر'**
  String get dhikrDetailsTitle;

  /// No description provided for @toggleFavorite.
  ///
  /// In ar, this message translates to:
  /// **'تبديل المفضلة'**
  String get toggleFavorite;

  /// No description provided for @dhikrNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الذكر غير موجود'**
  String get dhikrNotFound;

  /// No description provided for @referenceLabel.
  ///
  /// In ar, this message translates to:
  /// **'المصدر'**
  String get referenceLabel;

  /// No description provided for @repeatCounter.
  ///
  /// In ar, this message translates to:
  /// **'عداد التكرار'**
  String get repeatCounter;

  /// No description provided for @completedThisDhikr.
  ///
  /// In ar, this message translates to:
  /// **'تم إكمال هذا الذكر'**
  String get completedThisDhikr;

  /// No description provided for @countLabel.
  ///
  /// In ar, this message translates to:
  /// **'تسبيح'**
  String get countLabel;

  /// No description provided for @adhkarCategoryMorning.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get adhkarCategoryMorning;

  /// No description provided for @adhkarCategoryEvening.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get adhkarCategoryEvening;

  /// No description provided for @adhkarCategorySleep.
  ///
  /// In ar, this message translates to:
  /// **'أذكار النوم'**
  String get adhkarCategorySleep;

  /// No description provided for @adhkarCategoryPrayer.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصلاة'**
  String get adhkarCategoryPrayer;

  /// No description provided for @adhkarCategoryAfterPrayer.
  ///
  /// In ar, this message translates to:
  /// **'بعد الصلاة'**
  String get adhkarCategoryAfterPrayer;

  /// No description provided for @adhkarCategoryMosque.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المسجد'**
  String get adhkarCategoryMosque;

  /// No description provided for @adhkarCategoryFood.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الطعام'**
  String get adhkarCategoryFood;

  /// No description provided for @adhkarCategoryTravel.
  ///
  /// In ar, this message translates to:
  /// **'أذكار السفر'**
  String get adhkarCategoryTravel;

  /// No description provided for @adhkarCategoryHome.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المنزل'**
  String get adhkarCategoryHome;

  /// No description provided for @adhkarCategoryGeneral.
  ///
  /// In ar, this message translates to:
  /// **'أذكار عامة'**
  String get adhkarCategoryGeneral;

  /// No description provided for @adhkarCategoryTasbeeh.
  ///
  /// In ar, this message translates to:
  /// **'التسبيح'**
  String get adhkarCategoryTasbeeh;

  /// No description provided for @adhkarCategoryQuranDua.
  ///
  /// In ar, this message translates to:
  /// **'أدعية قرآنية'**
  String get adhkarCategoryQuranDua;

  /// No description provided for @athanOnboardingPrompt.
  ///
  /// In ar, this message translates to:
  /// **'هل ترغب في تفعيل تنبيهات الآذان لكل صلاة؟ يمكنك دائماً تغيير هذا من إعدادات مواقيت الصلاة.'**
  String get athanOnboardingPrompt;

  /// No description provided for @adhanAlertsMayNotWork.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الآذان قد لا تعمل'**
  String get adhanAlertsMayNotWork;

  /// No description provided for @enableExactAlarmsFromSettings.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء تفعيل إذن \"التنبيهات الدقيقة\" من الإعدادات.'**
  String get enableExactAlarmsFromSettings;

  /// No description provided for @enable.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get enable;

  /// No description provided for @prePrayerReminders.
  ///
  /// In ar, this message translates to:
  /// **'تذكير ما قبل الصلاة'**
  String get prePrayerReminders;

  /// No description provided for @prePrayerReminderSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه للاستعداد والأذكار قبل الصلاة بـ {minutes} دقيقة'**
  String prePrayerReminderSubtitle(int minutes);

  /// No description provided for @remindBefore.
  ///
  /// In ar, this message translates to:
  /// **'وقت التذكير'**
  String get remindBefore;

  /// No description provided for @previewAdhanSound.
  ///
  /// In ar, this message translates to:
  /// **'سماع صوت الآذان'**
  String get previewAdhanSound;

  /// No description provided for @tapToListen.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للاستماع'**
  String get tapToListen;

  /// No description provided for @playlistPlayAll.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل الكل'**
  String get playlistPlayAll;

  /// No description provided for @noSurahsInPlaylist.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سور في هذه القائمة'**
  String get noSurahsInPlaylist;

  /// No description provided for @playlistShareText.
  ///
  /// In ar, this message translates to:
  /// **'قائمة تشغيل: {name}\nاستمع إليها عبر تطبيق المكتبة الإسلامية:\nislamiclibrary://playlist?data={data}'**
  String playlistShareText(Object name, Object data);

  /// No description provided for @favoritesEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف أول عنصر من قسم {section} وسيظهر هنا مباشرة.'**
  String favoritesEmptyHint(Object section);

  /// No description provided for @openSectionLabel.
  ///
  /// In ar, this message translates to:
  /// **'فتح {section}'**
  String openSectionLabel(Object section);

  /// No description provided for @noFavoriteTafsirClips.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تفاسير في المفضلة'**
  String get noFavoriteTafsirClips;

  /// No description provided for @noFavoriteSeerahClips.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مقاطع سيرة في المفضلة'**
  String get noFavoriteSeerahClips;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر لغتك'**
  String get chooseYourLanguage;

  /// No description provided for @languageArabicSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabicSubtitle;

  /// No description provided for @languageEnglishSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get languageEnglishSubtitle;

  /// No description provided for @permissionsCannotBeRevokedInApp.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن إلغاء الصلاحيات من داخل التطبيق. يرجى تعديلها من إعدادات الجهاز.'**
  String get permissionsCannotBeRevokedInApp;

  /// No description provided for @permissionDeniedEnableFromSettings.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الصلاحية. يرجى تفعيلها من الإعدادات.'**
  String get permissionDeniedEnableFromSettings;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك'**
  String get welcome;

  /// No description provided for @permissionsSetupSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لنقم بإعداد تجربتك'**
  String get permissionsSetupSubtitle;

  /// No description provided for @permissionsNotificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات والتشغيل في الخلفية'**
  String get permissionsNotificationsTitle;

  /// No description provided for @permissionsNotificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ابق على اطلاع وواصل تشغيل الصوت'**
  String get permissionsNotificationsSubtitle;

  /// No description provided for @permissionsLocationTitle.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت الصلاة و القبلة'**
  String get permissionsLocationTitle;

  /// No description provided for @permissionsLocationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت صلاة دقيقة بناءً على الموقع'**
  String get permissionsLocationSubtitle;

  /// No description provided for @permissionsUpdatesTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحديثات التلقائية'**
  String get permissionsUpdatesTitle;

  /// No description provided for @permissionsUpdatesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'السماح للتطبيق بالتحديث من الداخل'**
  String get permissionsUpdatesSubtitle;

  /// No description provided for @startNow.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get startNow;

  /// No description provided for @calculationMethodDescription.
  ///
  /// In ar, this message translates to:
  /// **'اختر طريقة حساب مواقيت الصلاة المناسبة لمنطقتك'**
  String get calculationMethodDescription;

  /// No description provided for @finishSetup.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الإعداد'**
  String get finishSetup;

  /// No description provided for @storySectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'القصة'**
  String get storySectionTitle;

  /// No description provided for @keyEventsTitle.
  ///
  /// In ar, this message translates to:
  /// **'أبرز الأحداث'**
  String get keyEventsTitle;

  /// No description provided for @keyLessonTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدرس المستفاد'**
  String get keyLessonTitle;

  /// No description provided for @tasbeehSessionCount.
  ///
  /// In ar, this message translates to:
  /// **'الجلسة {count}'**
  String tasbeehSessionCount(int count);

  /// No description provided for @setActiveListeningTrack.
  ///
  /// In ar, this message translates to:
  /// **'تحديد مسار الاستماع النشط'**
  String get setActiveListeningTrack;

  /// No description provided for @currentActiveTrack.
  ///
  /// In ar, this message translates to:
  /// **'النشط حاليًا'**
  String get currentActiveTrack;

  /// No description provided for @chooseActiveListeningTrack.
  ///
  /// In ar, this message translates to:
  /// **'اختر مسار الاستماع النشط'**
  String get chooseActiveListeningTrack;

  /// No description provided for @activeListeningTrackSetMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تعيين \"{title}\" كمسار الاستماع النشط'**
  String activeListeningTrackSetMessage(Object title);

  /// No description provided for @clearActiveTrack.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء المسار النشط'**
  String get clearActiveTrack;

  /// No description provided for @muslimWorldLeague.
  ///
  /// In ar, this message translates to:
  /// **'رابطة العالم الإسلامي'**
  String get muslimWorldLeague;

  /// No description provided for @mushafSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات المصحف'**
  String get mushafSettings;

  /// No description provided for @themeLabel.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get themeLabel;

  /// No description provided for @riwayaSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الرواية'**
  String get riwayaSettings;

  /// No description provided for @chooseQuranRecitationStyle.
  ///
  /// In ar, this message translates to:
  /// **'اختر رواية القرآن الكريم'**
  String get chooseQuranRecitationStyle;

  /// No description provided for @downloadMoreRiwayat.
  ///
  /// In ar, this message translates to:
  /// **'تحميل روايات أخرى'**
  String get downloadMoreRiwayat;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get available;

  /// No description provided for @tafsirLabel.
  ///
  /// In ar, this message translates to:
  /// **'التفسير'**
  String get tafsirLabel;

  /// No description provided for @playVerseAudio.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل الآية'**
  String get playVerseAudio;

  /// No description provided for @noTranslationAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ترجمة متاحة.'**
  String get noTranslationAvailable;

  /// No description provided for @failedToLoadTranslation.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الترجمة.'**
  String get failedToLoadTranslation;

  /// No description provided for @hadithShareText.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ هذا الحديث من تطبيق المكتبة الإسلامية: {text}'**
  String hadithShareText(Object text);

  /// No description provided for @hadithBookBukhari.
  ///
  /// In ar, this message translates to:
  /// **'صحيح البخاري'**
  String get hadithBookBukhari;

  /// No description provided for @hadithBookMuslim.
  ///
  /// In ar, this message translates to:
  /// **'صحيح مسلم'**
  String get hadithBookMuslim;

  /// No description provided for @hadithBookAbuDawud.
  ///
  /// In ar, this message translates to:
  /// **'سنن أبي داود'**
  String get hadithBookAbuDawud;

  /// No description provided for @hadithBookTirmidhi.
  ///
  /// In ar, this message translates to:
  /// **'جامع الترمذي'**
  String get hadithBookTirmidhi;

  /// No description provided for @hadithBookNasai.
  ///
  /// In ar, this message translates to:
  /// **'سنن النسائي'**
  String get hadithBookNasai;

  /// No description provided for @hadithBookIbnMajah.
  ///
  /// In ar, this message translates to:
  /// **'سنن ابن ماجه'**
  String get hadithBookIbnMajah;

  /// No description provided for @hadithBookMalik.
  ///
  /// In ar, this message translates to:
  /// **'موطأ مالك'**
  String get hadithBookMalik;

  /// No description provided for @hadithBookNawawi.
  ///
  /// In ar, this message translates to:
  /// **'الأربعون النووية'**
  String get hadithBookNawawi;

  /// No description provided for @hadithBookQudsi.
  ///
  /// In ar, this message translates to:
  /// **'الأحاديث القدسية'**
  String get hadithBookQudsi;

  /// No description provided for @reciterUnavailableNow.
  ///
  /// In ar, this message translates to:
  /// **'عذراً، لا تتوفر تلاوة لهذا القارئ حالياً'**
  String get reciterUnavailableNow;

  /// No description provided for @unableToLoadPlayableAyahAudio.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل مقطع الآية لهذا الاختيار.'**
  String get unableToLoadPlayableAyahAudio;

  /// No description provided for @noDataAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات متاحة.'**
  String get noDataAvailable;

  /// No description provided for @chooseTafsirSource.
  ///
  /// In ar, this message translates to:
  /// **'اختر مصدر التفسير'**
  String get chooseTafsirSource;

  /// No description provided for @noTafsirSourcesAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مصادر تفسير متاحة حالياً.'**
  String get noTafsirSourcesAvailable;

  /// No description provided for @fullIndex.
  ///
  /// In ar, this message translates to:
  /// **'الفهرس الكامل'**
  String get fullIndex;

  /// No description provided for @theme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get theme;

  /// No description provided for @riwaya.
  ///
  /// In ar, this message translates to:
  /// **'الرواية'**
  String get riwaya;

  /// No description provided for @manualLocationInput.
  ///
  /// In ar, this message translates to:
  /// **'إدخال يدوي'**
  String get manualLocationInput;

  /// No description provided for @khatmaRemediationNeeded.
  ///
  /// In ar, this message translates to:
  /// **'أنت متأخر بمقدار {amount} {unit}. دعنا نساعدك للعودة للمسار الصحيح!'**
  String khatmaRemediationNeeded(int amount, String unit);

  /// No description provided for @khatmaRemediationUpdatePlan.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الخطة'**
  String get khatmaRemediationUpdatePlan;

  /// No description provided for @khatmaRemediationSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل خطة الختمة'**
  String get khatmaRemediationSheetTitle;

  /// No description provided for @khatmaRemediationSheetSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لقد تأخرت بمقدار {units} {unitType}. كيف تفضل التعويض؟'**
  String khatmaRemediationSheetSubtitle(int units, String unitType);

  /// No description provided for @khatmaRemediationCatchUp.
  ///
  /// In ar, this message translates to:
  /// **'تعويض سريع'**
  String get khatmaRemediationCatchUp;

  /// No description provided for @khatmaRemediationCatchUpDesc.
  ///
  /// In ar, this message translates to:
  /// **'قراءة ورد إضافي اليوم وغداً للعودة للجدول فوراً.'**
  String get khatmaRemediationCatchUpDesc;

  /// No description provided for @khatmaRemediationDistribute.
  ///
  /// In ar, this message translates to:
  /// **'توزيع الجهد'**
  String get khatmaRemediationDistribute;

  /// No description provided for @khatmaRemediationDistributeDesc.
  ///
  /// In ar, this message translates to:
  /// **'توزيع الورد الفائت على الأيام المتبقية.'**
  String get khatmaRemediationDistributeDesc;

  /// No description provided for @khatmaRemediationExtend.
  ///
  /// In ar, this message translates to:
  /// **'تمديد المدة'**
  String get khatmaRemediationExtend;

  /// No description provided for @khatmaRemediationExtendDesc.
  ///
  /// In ar, this message translates to:
  /// **'استمرار الورد الحالي وتأخير موعد الختم.'**
  String get khatmaRemediationExtendDesc;

  /// No description provided for @khatmaRemediationCurrentGoal.
  ///
  /// In ar, this message translates to:
  /// **'الحالي: {amount} / يوم'**
  String khatmaRemediationCurrentGoal(String amount);

  /// No description provided for @khatmaRemediationNewGoal.
  ///
  /// In ar, this message translates to:
  /// **'الجديد: {amount} / يوم'**
  String khatmaRemediationNewGoal(String amount);

  /// No description provided for @khatmaRemediationCurrentDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الختم الحالي: {date}'**
  String khatmaRemediationCurrentDate(String date);

  /// No description provided for @khatmaRemediationNewDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الختم الجديد: {date}'**
  String khatmaRemediationNewDate(String date);

  /// No description provided for @khatmaDailyReminderTitle.
  ///
  /// In ar, this message translates to:
  /// **'تذكير الختمة اليومي'**
  String get khatmaDailyReminderTitle;

  /// No description provided for @khatmaDailyReminderBody.
  ///
  /// In ar, this message translates to:
  /// **'لا تنسَ قراءة وردك اليومي لتبقى على جدول ختمتك.'**
  String get khatmaDailyReminderBody;

  /// No description provided for @khatmaRemediationAction.
  ///
  /// In ar, this message translates to:
  /// **'استعراض الخيارات'**
  String get khatmaRemediationAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
