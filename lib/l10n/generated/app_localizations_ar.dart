// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بيت الإسلام';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodNight => 'ليلة سعيدة';

  @override
  String get prayerTimes => 'مواقيت الصلاة';

  @override
  String get dailyVerse => 'آية اليوم';

  @override
  String get khatmaProgress => 'متابعة الختمة';

  @override
  String get generalReadingProgress => 'تقدم القراءة العام';

  @override
  String reachedSurah(String surah) {
    return 'وصلت إلى سورة $surah';
  }

  @override
  String get exploreSections => 'استكشف الأقسام';

  @override
  String get homeSectionQuranAndSeerah => 'القرآن الكريم والسيرة النبوية';

  @override
  String get homeSectionWorshipAndPrayer => 'العبادة والصلاة';

  @override
  String get homeSectionMediaAndBroadcast => 'البث والإعلام';

  @override
  String get homeSectionMyLibrary => 'مكتبتي';

  @override
  String get quranMushaf => 'المصحف الشريف';

  @override
  String get quranTitle => 'القرآن الكريم';

  @override
  String get quranSubtitle => 'تفسير، قراءة وترجمة';

  @override
  String get quranSyncTitle => 'القرآن الصوتي المقروء';

  @override
  String get quranSyncSubtitle => 'مزامنة التلاوة مع النص';

  @override
  String get audioTafsir => 'تفسير القرآن المسموع';

  @override
  String get propheticHadith => 'الأحاديث النبوية';

  @override
  String get hadithOfTheDay => 'حديث اليوم';

  @override
  String get azkarDuas => 'الأذكار والأدعية';

  @override
  String get adhkarOfTheDay => 'أذكار المسلم';

  @override
  String get radioLive => 'الإذاعات والمباشر';

  @override
  String get favoriteReciters => 'قراؤك المفضلون';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get notificationsAthan => 'التنبيهات والآذان';

  @override
  String get athanNotifications => 'تنبيهات الآذان';

  @override
  String get enabledForAll => 'مفعلة لكافة الصلوات';

  @override
  String get disabled => 'معطلة';

  @override
  String get appearanceLanguage => 'المظهر واللغة';

  @override
  String get darkMode => 'المظهر الداكن';

  @override
  String get darkModeSubtitle => 'مفعل دائماً للراحة البصرية';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get juzMarkers => 'إظهار فواصل الأجزاء';

  @override
  String get juzMarkersSubtitle => 'عرض شارات الانتقال بين أجزاء القرآن';

  @override
  String get arabic => 'العربية';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get shareApp => 'شارك التطبيق';

  @override
  String get rateApp => 'قيم التطبيق';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get globalSearch => 'بحث شامل';

  @override
  String get searchSurah => 'بحث عن سورة...';

  @override
  String get downloadAll => 'تحميل الكل';

  @override
  String get favorites => 'المفضلة';

  @override
  String get downloads => 'التنزيلات';

  @override
  String get quranText => 'نص القرآن';

  @override
  String get tasbeeh => 'التسبيح';

  @override
  String get liveTv => 'البث المباشر';

  @override
  String get books => 'المكتبة المقروءة';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String get qibla => 'القبلة';

  @override
  String get fajr => 'الفجر';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String get noBookmarkSaved => 'لا توجد علامة مرجعية محفوظة';

  @override
  String get hadithBooks => 'كتب الحديث';

  @override
  String get nineBooksOfSunnah => 'تسع كتب من أصول السنة';

  @override
  String hadithCount(int count) {
    return '$count حديث';
  }

  @override
  String page(int number) {
    return 'صفحة $number';
  }

  @override
  String get noHadithsAvailableOffline =>
      'لا توجد أحاديث متاحة أوفلاين لهذا الكتاب.\nيرجى الاتصال بالإنترنت للتحميل.';

  @override
  String get azkar => 'الأذكار';

  @override
  String get duas => 'الأدعية';

  @override
  String get selectedDuas => 'أدعية مختارة';

  @override
  String get dailyMuslimAzkar => 'أذكار المسلم اليومية';

  @override
  String get morningAzkar => 'أذكار الصباح';

  @override
  String get eveningAzkar => 'أذكار المساء';

  @override
  String get sleepAzkar => 'أذكار النوم';

  @override
  String get wakeUpAzkar => 'أذكار الاستيقاظ';

  @override
  String get mosqueAzkar => 'أذكار المسجد';

  @override
  String get adhanAzkar => 'أذكار الآذان';

  @override
  String get wuduAzkar => 'أذكار الوضوء';

  @override
  String get propheticDuas => 'أدعية نبوية';

  @override
  String get quranDuas => 'أدعية قرآنية';

  @override
  String get prophetsDuas => 'أدعية الأنبياء';

  @override
  String get miscellaneousAzkar => 'أذكار متنوعة';

  @override
  String get done => 'تم';

  @override
  String get startingDownloadAll => 'بدأ تحميل جميع السور...';

  @override
  String downloadCompleted(int count) {
    return 'تم اكتمال تحميل $count سورة';
  }

  @override
  String surahNumber(String number) {
    return 'سورة رقم $number';
  }

  @override
  String recitationOf(String name) {
    return 'تلاوة $name';
  }

  @override
  String get downloadSuccessful => 'تم التحميل بنجاح';

  @override
  String downloadFailed(String error) {
    return 'فشل التحميل: $error';
  }

  @override
  String get electronicTasbeeh => 'مسبحة إلكترونية';

  @override
  String totalTasbeehs(int count) {
    return 'إجمالي التسبيحات: $count';
  }

  @override
  String get tapToCount => 'اضغط في أي مكان في الدائرة للتسبيح';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get history => 'السجل';

  @override
  String get mushaf => 'المصحف الشريف';

  @override
  String pageSavedAsBookmark(int page) {
    return 'تم حفظ الصفحة $page كعلامة مرجعية';
  }

  @override
  String get readingModeText => 'وضع القراءة النصي';

  @override
  String lastReadMushaf(int page) {
    return 'آخر قرائة (صفحة $page)';
  }

  @override
  String lastReadAyah(String surah, String ayah) {
    return 'آخر قراءة ($surah : $ayah)';
  }

  @override
  String mushafWithPage(int page) {
    return 'المصحف الشريف (صفحة $page)';
  }

  @override
  String pageXOf604(int page) {
    return 'صفحة $page من 604';
  }

  @override
  String get previous => 'السابقة';

  @override
  String get index => 'الفهرس';

  @override
  String get next => 'التالية';

  @override
  String get errorLoadingPage => 'حدث خطأ في تحميل الصفحة';

  @override
  String get surahIndex => 'فهرس السور';

  @override
  String get errorLoadingSurahs => 'حدث خطأ في تحميل السور';

  @override
  String get meccan => 'مكية';

  @override
  String get medinan => 'مدنية';

  @override
  String ayahsCount(int count) {
    return '$count آية';
  }

  @override
  String pageN(int page) {
    return 'صفحة $page';
  }

  @override
  String get showMushaf => 'عرض المصحف';

  @override
  String get selectTranslation => 'اختر الترجمة';

  @override
  String get selectTafsir => 'اختر التفسير';

  @override
  String get chooseTranslation => 'اختر الترجمة';

  @override
  String get chooseTafsir => 'اختر التفسير';

  @override
  String get chooseSurah => 'اختر السورة';

  @override
  String verseN(Object number) {
    return 'الآية $number';
  }

  @override
  String get noTafsirAvailable => 'لا يوجد تفسير متاح حالياً';

  @override
  String get radio => 'الإذاعات';

  @override
  String get videos => 'السيرة النبوية';

  @override
  String get myAccount => 'حسابي';

  @override
  String get moodAnxious => 'قلق';

  @override
  String get moodSad => 'حزين';

  @override
  String get moodHappy => 'سعيد';

  @override
  String get moodLost => 'تائه';

  @override
  String get moodTired => 'متعب';

  @override
  String get surahSharh => 'سورة الشرح';

  @override
  String get descAnxious =>
      'تذكر دائماً أن مع العسر يسراً، هذه السورة تبعث الطمأنينة في القلوب القلقة.';

  @override
  String get actionReadSurah => 'اقرأ السورة';

  @override
  String get surahYusuf => 'سورة يوسف';

  @override
  String get descSad => 'قصة الصبر والفرج بعد الضيق. إنها بلسم للقلوب الحزينة.';

  @override
  String get surahRahman => 'سورة الرحمن';

  @override
  String get descHappy =>
      'خير ما يشكر به الله على نعمه وفضله. فبأي آلاء ربكما تكذبان.';

  @override
  String get surahFatiha => 'سورة الفاتحة';

  @override
  String get descLost =>
      'أم الكتاب والدعاء بالهداية للصراط المستقيم في كل حين.';

  @override
  String get descTired => 'لتستريح نفسك ويهدأ بالك بذكر الله قبل المنام.';

  @override
  String get actionGoToAzkar => 'اذهب للأذكار';

  @override
  String becauseYouFeel(String mood) {
    return 'لأنك تشعر بـ $mood';
  }

  @override
  String get howDoYouFeel => 'بماذا تشعر الآن؟';

  @override
  String get unknownName => 'اسم غير معروف';

  @override
  String mushafCount(int count) {
    return '$count مصحف';
  }

  @override
  String get nowPlaying => 'جاري التشغيل...';

  @override
  String get playbackPaused => 'التشغيل متوقف';

  @override
  String get reciterLabel => 'القارئ';

  @override
  String get verseOfTheDay => 'آية اليوم';

  @override
  String get dailyVerseText =>
      'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا * إِنَّ مَعَ الْعُسْرِ يُسْرًا';

  @override
  String get prayerTimesTitle => 'مواقيت الصلاة';

  @override
  String get noPrayerTimesFound => 'لم يتم العثور على مواقيت لهذه المدخلات';

  @override
  String get cityLabel => 'المدينة';

  @override
  String get countryLabel => 'الدولة';

  @override
  String get updateTimesButton => 'تحديث المواقيت';

  @override
  String prayerTimeError(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get sunrise => 'الشروق';

  @override
  String get nowListening => 'جاري الاستماع';

  @override
  String get sleepTimer => 'مؤقت النوم';

  @override
  String get share => 'مشاركة';

  @override
  String comingSoon(Object feature) {
    return 'سيتم تفعيل $feature قريباً';
  }

  @override
  String get startingDownload => 'جاري بدء التحميل...';

  @override
  String get download => 'تحميل';

  @override
  String get playlist => 'القائمة';

  @override
  String get currentPlaylist => 'قائمة التشغيل الحالية';

  @override
  String audioCount(Object count) {
    return '$count صوتيات';
  }

  @override
  String get nowPlayingLabel => 'يعمل الآن';

  @override
  String timeRemaining(Object time) {
    return 'الوقت المتبقي: $time';
  }

  @override
  String get stopTimer => 'إيقاف المؤقت';

  @override
  String get sleepTimerStopped => 'تم إيقاف مؤقت النوم';

  @override
  String timerSetFor(Object time) {
    return 'تم ضبط المؤقت لـ $time';
  }

  @override
  String get surahIdNotFound => 'لم يتم العثور على معرف السورة';

  @override
  String get errorLoadingText => 'خطأ في تحميل النص';

  @override
  String shareRecitationText(Object link, Object reciter, Object title) {
    return 'استمع إلى $title بصوت القارئ $reciter عبر تطبيق المكتبة الإسلامية.\n\n$link';
  }

  @override
  String minutes(Object count) {
    return '$count دقيقة';
  }

  @override
  String timerOption(String count) {
    return '$count دقيقة';
  }

  @override
  String get readingModeOnlyForQuran => 'وضع القراءة متاح للقرآن الكريم فقط';

  @override
  String get liveTvTitle => 'البث المباشر';

  @override
  String get religiousChannelsDescription => 'قنوات دينية على مدار الساعة';

  @override
  String get videoPlayerError => 'تعذر تشغيل الفيديو';

  @override
  String get checkInternetConnection =>
      'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get islamicRadioTitle => 'الإذاعات الإسلامية';

  @override
  String get liveRadioDescription => 'بث مباشر على مدار الساعة';

  @override
  String get searchRadioHint => 'ابحث عن إذاعة...';

  @override
  String get videoLibraryTitle => 'السيرة النبوية';

  @override
  String get searchVideoHint => 'ابحث في السيرة النبوية...';

  @override
  String get all => 'الكل';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get reciters => 'القراء';

  @override
  String get surahs => 'السور';

  @override
  String get noFavoriteReciters => 'لا يوجد قراء في المفضلة';

  @override
  String get noFavoriteSurahs => 'لا توجد سور في المفضلة';

  @override
  String get noFavoriteHadiths => 'لا توجد أحاديث في المفضلة';

  @override
  String get unknownReciter => 'غير معروف';

  @override
  String downloadingSurah(String surah) {
    return 'جاري تحميل سورة $surah...';
  }

  @override
  String get downloaded => 'تم التحميل';

  @override
  String get downloadsTitle => 'التنزيلات';

  @override
  String get downloadedSurahs => 'السور المحملة';

  @override
  String get downloadedLibraryDescription => 'مكتبتك الصوتية المحملة';

  @override
  String get libraryEmpty => 'المكتبة فارغة';

  @override
  String get downloadedFilesWillAppearHere => 'الملفات المحملة ستظهر هنا';

  @override
  String downloadedSurahCount(Object count) {
    return '$count سورة محملة';
  }

  @override
  String get audioFile => 'ملف صوتي';

  @override
  String get deleteFileQuestion => 'حذف الملف؟';

  @override
  String get deleteFileConfirmation => 'هل أنت متأكد من حذف هذا الملف نهائياً؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get booksLibraryTitle => 'مكتبة الكتب';

  @override
  String get articlesAndBooksTitle => 'المقالات والكتب';

  @override
  String get searchLibraryHint => 'ابحث في المكتبة...';

  @override
  String get booksLabel => 'كتب';

  @override
  String get articlesLabel => 'مقالات';

  @override
  String get audiosLabel => 'صوتيات';

  @override
  String get noSearchResults => 'لا توجد نتائج بحث';

  @override
  String get downloadButton => 'تحميل';

  @override
  String pageCount(int page) {
    return 'صفحة $page';
  }

  @override
  String get allRecitersTitle => 'جميع القراء';

  @override
  String get chooseYourFavoriteReciter => 'اختر القارئ المفضل لديك';

  @override
  String get searchForReciter => 'ابحث عن قارئ...';

  @override
  String get noResultsFound => 'لا توجد نتائج';

  @override
  String get trySearchingWithOtherWords => 'جرب البحث بكلمات أخرى';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get mainMenu => 'القائمة الرئيسية';

  @override
  String get readingMedia => 'محتوى القراءة';

  @override
  String get utilitiesTools => 'الأدوات المساعدة';

  @override
  String get appNameEnglish => 'Islam Home';

  @override
  String get appNameArabic => 'بيت الإسلام';

  @override
  String get home => 'الرئيسية';

  @override
  String get hadith => 'الحديث';

  @override
  String surahName(String name) {
    return '$name';
  }

  @override
  String reciterName(String name) {
    return '$name';
  }

  @override
  String get useLocation => 'استخدام الموقع الحالي';

  @override
  String get locationServicesDisabled => 'خدمات الموقع معطلة.';

  @override
  String get locationPermissionsDenied => 'تم رفض إذن الوصول للموقع.';

  @override
  String get locationPermissionsPermanentlyDenied =>
      'تم رفض إذن الموقع بشكل دائم.';

  @override
  String failedToGetLocation(String error) {
    return 'فشل في الحصول على الموقع: $error';
  }

  @override
  String get updateLocation => 'تحديث الموقع';

  @override
  String get surahDuha => 'سورة الضحى';

  @override
  String get descDuha =>
      'ما ودعك ربك وما قلى. رسالة ربانية لكل قلب يشعر بالضيق والحزن.';

  @override
  String get actionGoToDua => 'اذهب للأدعية';

  @override
  String get startTasbeeh => 'ابدأ التسبيح';

  @override
  String get rememberAllah => 'ذكر الله';

  @override
  String get descHappyDhikr =>
      'الحمد لله تزيد النعمة وتبارك في الرزق وتديم السعادة.';

  @override
  String get allahIsNear => 'الله قريب منك';

  @override
  String get descLostDhikr =>
      'الله قريب منك دائماً، يوجهك ويسمع دعاءك إذا ضللت الطريق.';

  @override
  String get descAnxiousDhikr =>
      'ذكر الله يُطمئن القلوب القلقة. ردِّد: ﴿إن مع العسر يسراً﴾ وتوكل على رحمته.';

  @override
  String get rewardForTired => 'أجر التعب';

  @override
  String get descTiredDhikr =>
      'تذكر أن تعبك مأجور، وأن الله لا يحملك فوق طاقتك. استرح بذكر الله.';

  @override
  String get searchHint => 'ابحث في القرآن، الحديث، الأذكار...';

  @override
  String searchQuranSubtitle(String surah, int ayah) {
    return 'القرآن: $surah ($ayah)';
  }

  @override
  String searchHadithSubtitle(String book, String chapter) {
    return 'الحديث: $book - $chapter';
  }

  @override
  String searchAdhkarSubtitle(String category) {
    return 'الأذكار: $category';
  }

  @override
  String get exploreLibrary => 'استكشف المكتبة';

  @override
  String get searchDescription => 'ابحث عن الآيات والأحاديث والأدعية';

  @override
  String get khatmaPlannerTitle => 'مخطط الختمة الذكي';

  @override
  String get khatmaPlannerSubtitle => 'حدد المدة التي ترغب بختم القرآن فيها';

  @override
  String get startKhatma => 'ابدأ الختمة';

  @override
  String get days => 'يوم';

  @override
  String get pagesDaily => 'صفحات يومياً';

  @override
  String get pagesPerPrayer => 'صفحات لكل صلاة';

  @override
  String remainingToday(int count) {
    return 'المتبقي لك اليوم: $count صفحات';
  }

  @override
  String get onTrack => 'أنت على الجدول';

  @override
  String get setupPlan => 'ضبط الخطة';

  @override
  String get cancelPlan => 'إلغاء الخطة';

  @override
  String get manageNotificationSettings => 'إدارة إعدادات الإشعارات';

  @override
  String get manageNotificationSettingsSubtitle =>
      'فتح إعدادات النظام للإشعارات';

  @override
  String get notificationDiagnosticsTitle => 'تشخيص الإشعارات';

  @override
  String get notificationDiagnosticsSubtitle =>
      'تحقق من حالة الصلاحيات الفعلية لضمان عمل تنبيهات الآذان';

  @override
  String get notificationDiagnosticsHealthy => 'إعدادات الإشعارات سليمة';

  @override
  String get notificationDiagnosticsNeedsFix => 'بعض الإعدادات تحتاج إصلاح';

  @override
  String get notificationPermissionTitle => 'صلاحية الإشعارات';

  @override
  String get notificationPermissionSubtitle =>
      'يجب تفعيلها لاستلام تنبيهات الآذان والتذكير';

  @override
  String get exactAlarmPermissionTitle => 'صلاحية المنبّهات الدقيقة';

  @override
  String get exactAlarmPermissionSubtitle =>
      'مطلوبة في أندرويد 12+ لتشغيل تنبيه الآذان في وقته الدقيق';

  @override
  String get batteryOptimizationTitle => 'تحسين البطارية';

  @override
  String get batteryOptimizationSubtitle =>
      'عطّل تحسين البطارية لهذا التطبيق لمنع تأخير أو حظر تنبيهات الآذان';

  @override
  String get notRequiredOnThisDevice => 'غير مطلوب على هذا الجهاز';

  @override
  String get fixNow => 'إصلاح الآن';

  @override
  String get enabled => 'مفعّل';

  @override
  String get requiresFix => 'يحتاج إصلاح';

  @override
  String get refreshStatus => 'تحديث الحالة';

  @override
  String get openSystemSettings => 'فتح إعدادات النظام';

  @override
  String get continueYourKhatma => 'واصل ختمـتك';

  @override
  String juzAndSurah(Object juz, Object surah) {
    return 'الجزء $juz - $surah';
  }

  @override
  String get smartSuggestionsForNewPlan => 'اقتراحات ذكية لنظامك الجديد:';

  @override
  String get khatmaInMonth => 'ختمة في شهر';

  @override
  String get oneJuzDaily => '1 جزء يومياً';

  @override
  String get khatmaInTwoMonths => 'ختمة في شهرين';

  @override
  String get fifteenPagesDaily => '15 صفحة يومياً';

  @override
  String pagesRemainingToday(Object count) {
    return 'بقي لك $count صفحات لليوم';
  }

  @override
  String get khatmaHistory => 'سجل الختمات';

  @override
  String get khatmaSettings => 'إعدادات الختمة';

  @override
  String get duaKhatm => 'دعاء ختم القرآن';

  @override
  String get mayAllahAccept => 'تقبل الله منك';

  @override
  String get shareDua => 'مشاركة الدعاء';

  @override
  String get mayAllahAcceptAll => 'تقبل الله منا ومنكم';

  @override
  String get continueReading => 'إكمال القراءة';

  @override
  String get continueListening => 'إكمال الاستماع';

  @override
  String get activePlans => 'الخطط النشطة';

  @override
  String get totalAchievement => 'إجمالي الإنجاز';

  @override
  String khatmaCount(int count) {
    return 'لقد ختمت القرآن $count مرات';
  }

  @override
  String get currentPageLabel => 'الصفحة الحالية';

  @override
  String get remainingLabel => 'المتبقي';

  @override
  String get dailyTargetLabel => 'ورد اليوم';

  @override
  String get duration => 'المدة';

  @override
  String get dailyGoal => 'الهدف اليومي';

  @override
  String get khatmaSuccessful => 'تم الختم بنجاح';

  @override
  String get noActivePlans => 'لا توجد خطط نشطة حالياً';

  @override
  String get noHistoryYet => 'لا يوجد تاريخ مسجل بعد';

  @override
  String get previousAchievements => 'إنجازات سابقة:';

  @override
  String get previousKhatmaHistory => 'سجل الختمات السابقة';

  @override
  String get blessedKhatma => 'ختمة مباركة';

  @override
  String get noKhatmasRecorded => 'لا يوجد ختمات مسجلة بعد';

  @override
  String get khatmCompletedPraise => 'تم الختم بحمد الله';

  @override
  String daysCount(int count) {
    return '$count يوم';
  }

  @override
  String get newKhatma => 'ختمة جديدة';

  @override
  String get prayerAdjustment => 'تعديل مواقيت الصلاة';

  @override
  String get prayerAdjustmentSubtitle => 'إضافة أو إنقاص دقائق للمواقيت (DST)';

  @override
  String adjustMinutes(Object minutes) {
    return 'تعديل $minutes دقيقة';
  }

  @override
  String get manualOffset => 'فرق التوقيت اليدوي';

  @override
  String hours(Object count) {
    return '$count ساعة';
  }

  @override
  String get hour => 'ساعة';

  @override
  String get adjustHours => 'تعديل الساعات';

  @override
  String get useAutoLocation => 'استخدام الموقع التلقائي (GPS)';

  @override
  String get moreSettings => 'المزيد من الإعدادات...';

  @override
  String get audioServiceNotReady =>
      'خدمة الصوت لم تكتمل بعد، يرجى المحاولة مرة أخرى';

  @override
  String get playingInBackground => 'تم تشغيل المقطع كصوت في الخلفية';

  @override
  String failedToPlay(String error) {
    return 'فشل تشغيل المقطع: $error';
  }

  @override
  String get later => 'لاحقاً';

  @override
  String get activateNow => 'تفعيل الآن';

  @override
  String get downloadAllStarted => 'تم بدء تحميل الكل إلى القائمة';

  @override
  String get noServerLinkError => 'خطأ: لا يوجد رابط خادم للقارئ';

  @override
  String playlistPlayError(String error) {
    return 'خطأ في تشغيل القائمة: $error';
  }

  @override
  String get grantPermission => 'منح الإذن';

  @override
  String error(String message) {
    return 'حدث خطأ: $message';
  }

  @override
  String get noSensors => 'الجهاز لا يحتوي على مستشعرات';

  @override
  String get save => 'حفظ';

  @override
  String get playlistNotFound => 'القائمة غير موجودة';

  @override
  String get createNewPlaylist => 'إنشاء قائمة جديدة';

  @override
  String get playlistImportedSuccessfully => 'تم استيراد قائمة التشغيل بنجاح';

  @override
  String get readingSettings => 'إعدادات القراءة';

  @override
  String get translation => 'الترجمة';

  @override
  String get tafsir => 'التفسير';

  @override
  String get switchToListView => 'تبديل إلى عرض القائمة';

  @override
  String get switchToFlowView => 'تبديل إلى عرض الترتيل';

  @override
  String get surah => 'سورة';

  @override
  String get pageLabel => 'صفحة';

  @override
  String get juz => 'الجزء';

  @override
  String get hizb => 'الحزب';

  @override
  String get nightMode => 'الوضع الليلي';

  @override
  String get dayMode => 'الوضع النهاري';

  @override
  String get lastReadSaved => 'تم حفظ الآية كآخر قراءة';

  @override
  String get lastReadUpdated => 'تم تحديث وقت آخر قراءة';

  @override
  String lastReadReplaced(
    String prevSurah,
    int prevAyah,
    String newSurah,
    int newAyah,
  ) {
    return 'تم استبدال $prevSurah:$prevAyah بـ $newSurah:$newAyah';
  }

  @override
  String get lastReadSaveFailed => 'فشل الحفظ. يرجى المحاولة مرة أخرى.';

  @override
  String get narrator => 'الراوي';

  @override
  String get book => 'الكتاب';

  @override
  String get chapter => 'الباب';

  @override
  String get copy => 'نسخ';

  @override
  String get copiedToClipboard => 'تم النسخ إلى الحافظة';

  @override
  String get jumpToHadith => 'انتقال لحديث';

  @override
  String get searchHadith => 'بحث في الأحاديث...';

  @override
  String get bookmark => 'حفظ';

  @override
  String get hijriAdjustment => 'تعديل التاريخ الهجري';

  @override
  String get hijriAdjustmentSubtitle =>
      'زيادة أو نقصان الأيام لتوافق رؤية الهلال في بلدك';

  @override
  String adjustDays(Object days) {
    return 'تعديل $days يوم';
  }

  @override
  String get fontSettings => 'إعدادات الخط';

  @override
  String get mushafFontSize => 'حجم المصحف';

  @override
  String get translationFontSize => 'حجم الترجمة';

  @override
  String get playlists => 'قوائم التشغيل';

  @override
  String get addToPlaylist => 'إضافة إلى قائمة تشغيل';

  @override
  String get noPlaylistsYet => 'لا توجد قوائم تشغيل بعد';

  @override
  String get playlistCreated => 'تم إنشاء قائمة التشغيل بنجاح';

  @override
  String get deletePlaylist => 'حذف القائمة';

  @override
  String get renamePlaylist => 'تعديل الاسم';

  @override
  String get playlistNameHint => 'اسم القائمة...';

  @override
  String get create => 'إنشاء';

  @override
  String surahsCount(int count) {
    return '$count سور';
  }

  @override
  String get noPlaylistsMessage =>
      'لا توجد قوائم تشغيل. أنشئ واحدة من قسم المفضلات.';

  @override
  String addedToPlaylist(Object playlistName) {
    return 'تمت الإضافة إلى $playlistName';
  }

  @override
  String get duaKhatmQuran => 'دعاء ختم القرآن';

  @override
  String get lastRead => 'آخر قراءة';

  @override
  String get chooseReciter => 'اختر المقرئ';

  @override
  String get fontSize => 'حجم الخط';

  @override
  String get search => 'بحث';

  @override
  String errorPlayingAudio(String message) {
    return 'خطأ في تشغيل الصوت: $message';
  }

  @override
  String navigatedToAyah(String surah, int ayah) {
    return 'تم الانتقال إلى $surah - آية $ayah';
  }

  @override
  String get setTarget => 'تحديد الهدف';

  @override
  String get tasbeehHistory => 'سجل التسبيح';

  @override
  String get noTasbeehToday => 'لا يوجد تسبيح لهذا اليوم';

  @override
  String get dailySummary => 'ملخص اليوم';

  @override
  String get hourlyBreakdown => 'توزيع الساعات';

  @override
  String get detailedLog => 'السجل التفصيلي';

  @override
  String get weeklyActivity => 'نشاط الأسبوع';

  @override
  String streakDays(int count) {
    return 'سلسلة $count يوم';
  }

  @override
  String get todayTotal => 'اليوم';

  @override
  String get today => 'اليوم';

  @override
  String get allTimeTasbeehs => 'إجمالي كل الأوقات';

  @override
  String get total => 'الإجمالي';

  @override
  String get streak => 'السلسلة';

  @override
  String get setCompleteTitle => 'اكتملت الجولة!';

  @override
  String get setCompleteSubtitle => 'تقبل الله ذكرك';

  @override
  String get totalLabel => 'الإجمالي';

  @override
  String get calculationMethodTitle => 'طريقة الحساب';

  @override
  String get sidebarMainQuran => 'الرئيسية والقرآن';

  @override
  String get sidebarTools => 'أدوات المسلم';

  @override
  String get sidebarContent => 'المحتوى الإسلامي';

  @override
  String get sidebarOther => 'أخرى';

  @override
  String get sidebarTagline => 'رحلة روحية ومكتبة';

  @override
  String get sidebarAppDescription => 'رفيقك الإسلامي اليومي';

  @override
  String get sira => 'حياة الرسول';

  @override
  String get prophetLife => 'حياة الرسول ﷺ';

  @override
  String get allSections => 'الكل';

  @override
  String get activeDownloads => 'نشطة';

  @override
  String get completedDownloads => 'مكتملة';

  @override
  String get downloadingTab => 'جاري التحميل';

  @override
  String get downloadedTab => 'المحملة';

  @override
  String get noActiveDownloads => 'لا توجد تحميلات نشطة';

  @override
  String get noActiveDownloadsDesc =>
      'يمكنك تحميل السور للاستماع إليها لاحقاً بدون إنترنت';

  @override
  String get quranSection => 'القرآن الكريم';

  @override
  String get seerahSection => 'السيرة النبوية';

  @override
  String get emptyDownloadsHistory => 'سجل التنزيلات فارغ';

  @override
  String get emptyDownloadsHistoryDesc => 'لم تقم بتنزيل أي سور بعد';

  @override
  String get khatmaV2Title => 'ختمة جديدة';

  @override
  String get khatmaV2TypeStepTitle => 'ما هو هدفك؟';

  @override
  String get khatmaV2Reading => 'قراءة عامة';

  @override
  String get khatmaV2ReadingDesc => 'قراءة كاملة للقرآن الكريم';

  @override
  String get khatmaV2Memorization => 'حفظ';

  @override
  String get khatmaV2MemorizationDesc => 'التركيز على الحفظ مع متابعة ذكية';

  @override
  String get khatmaV2Revision => 'مراجعة';

  @override
  String get khatmaV2RevisionDesc => 'تثبيت حفظك السابق';

  @override
  String get khatmaV2Listening => 'استماع';

  @override
  String get khatmaV2ListeningDesc => 'الاستماع المتدرج للقرآن مع تتبع يومي';

  @override
  String get khatmaV2DetailsStepTitle => 'تفاصيل الختمة';

  @override
  String get khatmaV2TitleLabel => 'العنوان (مثلاً: ختمة رمضان)';

  @override
  String get khatmaV2Range => 'النطاق';

  @override
  String get khatmaV2StartPage => 'صفحة البداية';

  @override
  String get khatmaV2EndPage => 'صفحة النهاية';

  @override
  String get khatmaV2SchedulingStepTitle => 'الجدولة والمحرك';

  @override
  String get khatmaV2DurationDays => 'المدة (بالأيام)';

  @override
  String get khatmaV2QuickDurations => 'مدد سريعة';

  @override
  String get khatmaV2EnginePrefs => 'تفضيلات المحرك';

  @override
  String get khatmaV2SmartRemediation => 'المعالجة الذكية';

  @override
  String get khatmaV2SmartRemediationDesc => 'يعدل هدفك تلقائياً إذا فاتك يوم';

  @override
  String get khatmaV2FixedDaily => 'هدف يومي ثابت';

  @override
  String get khatmaV2FixedDailyDesc => 'لا يتغير أبداً، حتى لو تأخر التقدم';

  @override
  String get khatmaV2StartJourney => 'ابدأ الرحلة';

  @override
  String get khatmaV2Continue => 'متابعة';

  @override
  String get khatmaV2Back => 'رجوع';

  @override
  String khatmaV2MyKhatma(Object type) {
    return 'ختمتي لـ $type';
  }

  @override
  String get khatmaV2NoActive => 'لا توجد ختمة نشطة';

  @override
  String get khatmaV2StartJourneyDesc =>
      'ابدأ رحلة جديدة مع نظام الختمة الذكي.';

  @override
  String get khatmaV2SetupNew => 'إعداد ختمة جديدة';

  @override
  String get khatmaV2DeleteTrack => 'حذف هذا المسار';

  @override
  String get khatmaV2DeleteTrackTitle => 'حذف المسار؟';

  @override
  String khatmaV2DeleteTrackBody(Object title) {
    return 'سيتم حذف \"$title\" وكل تقدمه بشكل نهائي.';
  }

  @override
  String khatmaV2RecordPage(Object page) {
    return 'تسجيل صفحة $page';
  }

  @override
  String get khatmaV2SelectTrack => 'اختر الختمة';

  @override
  String khatmaV2ProgressSaved(Object track) {
    return 'تم حفظ التقدم في $track';
  }

  @override
  String khatmaV2TrackTypeSuffix(Object type) {
    return 'مسار $type';
  }

  @override
  String get khatmaV2UnitLabel => 'وحدة التتبع';

  @override
  String get khatmaV2UnitPage => 'صفحات';

  @override
  String get khatmaV2UnitJuz => 'أجزاء';

  @override
  String get khatmaV2StartJuz => 'جزء البداية';

  @override
  String get khatmaV2EndJuz => 'جزء النهاية';

  @override
  String get khatmaV2JuzCount => 'عدد الأجزاء';

  @override
  String khatmaV2RecordJuz(Object juz) {
    return 'تسجيل الجزء $juz';
  }

  @override
  String get khatmaV2UnitPageSingle => 'صفحة';

  @override
  String get khatmaV2UnitJuzSingle => 'جزء';

  @override
  String get khatmaHeatmapLess => 'أقل';

  @override
  String get khatmaHeatmapMore => 'أكثر';

  @override
  String get khatmaV2UnitSurah => 'سور';

  @override
  String get khatmaV2UnitSurahSingle => 'سورة';

  @override
  String get khatmaV2StartSurah => 'سورة البداية';

  @override
  String get khatmaV2EndSurah => 'سورة النهاية';

  @override
  String khatmaV2RecordSurah(Object surah) {
    return 'تسجيل سورة $surah';
  }

  @override
  String get khatmaV2ValidationRangeOrder =>
      'يجب أن تكون البداية أصغر من أو تساوي النهاية.';

  @override
  String khatmaV2ValidationStartOutOfRange(int max) {
    return 'قيمة البداية يجب أن تكون بين 1 و $max.';
  }

  @override
  String khatmaV2ValidationEndOutOfRange(int max) {
    return 'قيمة النهاية يجب أن تكون بين 1 و $max.';
  }

  @override
  String get khatmaV2ValidationDurationDays =>
      'مدة الخطة يجب أن تكون يومًا واحدًا على الأقل.';

  @override
  String get playAyah => 'استماع للآية';

  @override
  String get testNotification => 'اختبار الإشعار';

  @override
  String get testNotificationSubtitle => 'اضغط للتأكد من أن التنبيهات تعمل';

  @override
  String get locationPermissionRequired => 'إذن الموقع مطلوب';

  @override
  String get unableToStartAudioTryAgain =>
      'تعذر تشغيل الصوت الآن. يرجى المحاولة مرة أخرى.';

  @override
  String get guestUser => 'زائر';

  @override
  String appVersionLabel(Object version) {
    return 'الإصدار $version';
  }

  @override
  String get reciterNoSurahsAvailable => 'لا توجد سور متاحة لهذا القارئ';

  @override
  String get back => 'رجوع';

  @override
  String get adhkarTitle => 'الأذكار';

  @override
  String get adhkarSearchTooltip => 'بحث';

  @override
  String get adhkarFavoritesTooltip => 'المفضلة';

  @override
  String get noAdhkarDataFound => 'لا توجد بيانات أذكار';

  @override
  String get noAdhkarInCategory => 'لا توجد أذكار في هذا القسم';

  @override
  String get searchAdhkarHint => 'ابحث في النص العربي أو الإنجليزي أو القسم';

  @override
  String get typeToSearchAdhkar => 'اكتب للبحث في الأذكار';

  @override
  String get noAdhkarMatches => 'لا توجد نتائج';

  @override
  String get favoriteAdhkarTitle => 'الأذكار المفضلة';

  @override
  String get noFavoriteAdhkar => 'لا توجد عناصر في المفضلة';

  @override
  String get dhikrDetailsTitle => 'تفاصيل الذكر';

  @override
  String get toggleFavorite => 'تبديل المفضلة';

  @override
  String get dhikrNotFound => 'الذكر غير موجود';

  @override
  String get referenceLabel => 'المصدر';

  @override
  String get repeatCounter => 'عداد التكرار';

  @override
  String get completedThisDhikr => 'تم إكمال هذا الذكر';

  @override
  String get countLabel => 'تسبيح';

  @override
  String get adhkarCategoryMorning => 'أذكار الصباح';

  @override
  String get adhkarCategoryEvening => 'أذكار المساء';

  @override
  String get adhkarCategorySleep => 'أذكار النوم';

  @override
  String get adhkarCategoryPrayer => 'أذكار الصلاة';

  @override
  String get adhkarCategoryAfterPrayer => 'بعد الصلاة';

  @override
  String get adhkarCategoryMosque => 'أذكار المسجد';

  @override
  String get adhkarCategoryFood => 'أذكار الطعام';

  @override
  String get adhkarCategoryTravel => 'أذكار السفر';

  @override
  String get adhkarCategoryHome => 'أذكار المنزل';

  @override
  String get adhkarCategoryGeneral => 'أذكار عامة';

  @override
  String get adhkarCategoryTasbeeh => 'التسبيح';

  @override
  String get adhkarCategoryQuranDua => 'أدعية قرآنية';

  @override
  String get athanOnboardingPrompt =>
      'هل ترغب في تفعيل تنبيهات الآذان لكل صلاة؟ يمكنك دائماً تغيير هذا من إعدادات مواقيت الصلاة.';

  @override
  String get adhanAlertsMayNotWork => 'تنبيهات الآذان قد لا تعمل';

  @override
  String get enableExactAlarmsFromSettings =>
      'الرجاء تفعيل إذن \"التنبيهات الدقيقة\" من الإعدادات.';

  @override
  String get enable => 'تفعيل';

  @override
  String get prePrayerReminders => 'تذكير ما قبل الصلاة';

  @override
  String prePrayerReminderSubtitle(int minutes) {
    return 'تنبيه للاستعداد والأذكار قبل الصلاة بـ $minutes دقيقة';
  }

  @override
  String get remindBefore => 'وقت التذكير';

  @override
  String get previewAdhanSound => 'سماع صوت الآذان';

  @override
  String get tapToListen => 'اضغط للاستماع';

  @override
  String get playlistPlayAll => 'تشغيل الكل';

  @override
  String get noSurahsInPlaylist => 'لا توجد سور في هذه القائمة';

  @override
  String playlistShareText(Object name, Object data) {
    return 'قائمة تشغيل: $name\nاستمع إليها عبر تطبيق المكتبة الإسلامية:\nislamiclibrary://playlist?data=$data';
  }

  @override
  String favoritesEmptyHint(Object section) {
    return 'أضف أول عنصر من قسم $section وسيظهر هنا مباشرة.';
  }

  @override
  String openSectionLabel(Object section) {
    return 'فتح $section';
  }

  @override
  String get noFavoriteTafsirClips => 'لا توجد تفاسير في المفضلة';

  @override
  String get noFavoriteSeerahClips => 'لا توجد مقاطع سيرة في المفضلة';

  @override
  String get chooseYourLanguage => 'اختر لغتك';

  @override
  String get languageArabicSubtitle => 'العربية';

  @override
  String get languageEnglishSubtitle => 'الإنجليزية';

  @override
  String get permissionsCannotBeRevokedInApp =>
      'لا يمكن إلغاء الصلاحيات من داخل التطبيق. يرجى تعديلها من إعدادات الجهاز.';

  @override
  String get permissionDeniedEnableFromSettings =>
      'تم رفض الصلاحية. يرجى تفعيلها من الإعدادات.';

  @override
  String get welcome => 'أهلاً بك';

  @override
  String get permissionsSetupSubtitle => 'لنقم بإعداد تجربتك';

  @override
  String get permissionsNotificationsTitle => 'التنبيهات والتشغيل في الخلفية';

  @override
  String get permissionsNotificationsSubtitle =>
      'ابق على اطلاع وواصل تشغيل الصوت';

  @override
  String get permissionsLocationTitle => 'مواقيت الصلاة و القبلة';

  @override
  String get permissionsLocationSubtitle =>
      'مواقيت صلاة دقيقة بناءً على الموقع';

  @override
  String get permissionsUpdatesTitle => 'التحديثات التلقائية';

  @override
  String get permissionsUpdatesSubtitle => 'السماح للتطبيق بالتحديث من الداخل';

  @override
  String get startNow => 'ابدأ الآن';

  @override
  String get calculationMethodDescription =>
      'اختر طريقة حساب مواقيت الصلاة المناسبة لمنطقتك';

  @override
  String get finishSetup => 'إتمام الإعداد';

  @override
  String get storySectionTitle => 'القصة';

  @override
  String get keyEventsTitle => 'أبرز الأحداث';

  @override
  String get keyLessonTitle => 'الدرس المستفاد';

  @override
  String tasbeehSessionCount(int count) {
    return 'الجلسة $count';
  }

  @override
  String get setActiveListeningTrack => 'تحديد مسار الاستماع النشط';

  @override
  String get currentActiveTrack => 'النشط حاليًا';

  @override
  String get chooseActiveListeningTrack => 'اختر مسار الاستماع النشط';

  @override
  String activeListeningTrackSetMessage(Object title) {
    return 'تم تعيين \"$title\" كمسار الاستماع النشط';
  }

  @override
  String get clearActiveTrack => 'إلغاء المسار النشط';

  @override
  String get muslimWorldLeague => 'رابطة العالم الإسلامي';

  @override
  String get mushafSettings => 'إعدادات المصحف';

  @override
  String get themeLabel => 'المظهر';

  @override
  String get riwayaSettings => 'إعدادات الرواية';

  @override
  String get chooseQuranRecitationStyle => 'اختر رواية القرآن الكريم';

  @override
  String get downloadMoreRiwayat => 'تحميل روايات أخرى';

  @override
  String get available => 'متاح';

  @override
  String get tafsirLabel => 'التفسير';

  @override
  String get playVerseAudio => 'تشغيل الآية';

  @override
  String get noTranslationAvailable => 'لا توجد ترجمة متاحة.';

  @override
  String get failedToLoadTranslation => 'تعذر تحميل الترجمة.';

  @override
  String hadithShareText(Object text) {
    return 'اقرأ هذا الحديث من تطبيق المكتبة الإسلامية: $text';
  }

  @override
  String get hadithBookBukhari => 'صحيح البخاري';

  @override
  String get hadithBookMuslim => 'صحيح مسلم';

  @override
  String get hadithBookAbuDawud => 'سنن أبي داود';

  @override
  String get hadithBookTirmidhi => 'جامع الترمذي';

  @override
  String get hadithBookNasai => 'سنن النسائي';

  @override
  String get hadithBookIbnMajah => 'سنن ابن ماجه';

  @override
  String get hadithBookMalik => 'موطأ مالك';

  @override
  String get hadithBookNawawi => 'الأربعون النووية';

  @override
  String get hadithBookQudsi => 'الأحاديث القدسية';

  @override
  String get reciterUnavailableNow =>
      'عذراً، لا تتوفر تلاوة لهذا القارئ حالياً';

  @override
  String get unableToLoadPlayableAyahAudio =>
      'تعذر تحميل مقطع الآية لهذا الاختيار.';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة.';

  @override
  String get chooseTafsirSource => 'اختر مصدر التفسير';

  @override
  String get noTafsirSourcesAvailable => 'لا توجد مصادر تفسير متاحة حالياً.';

  @override
  String get fullIndex => 'الفهرس الكامل';

  @override
  String get theme => 'المظهر';

  @override
  String get riwaya => 'الرواية';

  @override
  String get manualLocationInput => 'إدخال يدوي';
}
