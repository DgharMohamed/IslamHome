// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Islam Home';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodNight => 'Good Night';

  @override
  String get prayerTimes => 'Prayer Times';

  @override
  String get dailyVerse => 'Daily Verse';

  @override
  String get khatmaProgress => 'Khatma Progress';

  @override
  String reachedSurah(String surah) {
    return 'Reached Surah $surah';
  }

  @override
  String get exploreSections => 'Explore Sections';

  @override
  String get quranMushaf => 'Holy Quran';

  @override
  String get quranTitle => 'The Holy Quran';

  @override
  String get quranSubtitle => 'Tafsir, Reading & translation';

  @override
  String get quranSyncTitle => 'Audio-Read Quran';

  @override
  String get quranSyncSubtitle => 'Sync recitation with text';

  @override
  String get propheticHadith => 'Prophetic Hadiths';

  @override
  String get hadithOfTheDay => 'Hadith of the Day';

  @override
  String get azkarDuas => 'Azkar and Duas';

  @override
  String get adhkarOfTheDay => 'Daily Adhkar';

  @override
  String get radioLive => 'Radio & Live';

  @override
  String get favoriteReciters => 'Favorite Reciters';

  @override
  String get viewAll => 'View All';

  @override
  String get settings => 'Settings';

  @override
  String get notificationsAthan => 'Notifications & Athan';

  @override
  String get athanNotifications => 'Athan Notifications';

  @override
  String get enabledForAll => 'Enabled for all prayers';

  @override
  String get disabled => 'Disabled';

  @override
  String get appearanceLanguage => 'Appearance & Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Always enabled for eye comfort';

  @override
  String get appLanguage => 'App Language';

  @override
  String get juzMarkers => 'Show Juz Markers';

  @override
  String get juzMarkersSubtitle =>
      'Display transition badges between Quran parts';

  @override
  String get arabic => 'Arabic';

  @override
  String get aboutApp => 'About App';

  @override
  String get appVersion => 'App Version';

  @override
  String get shareApp => 'Share App';

  @override
  String get rateApp => 'Rate App';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get globalSearch => 'Global Search';

  @override
  String get searchSurah => 'Search for surah...';

  @override
  String get downloadAll => 'Download All';

  @override
  String get favorites => 'Favorites';

  @override
  String get downloads => 'Downloads';

  @override
  String get quranText => 'Quran Text';

  @override
  String get tasbeeh => 'Tasbeeh';

  @override
  String get liveTv => 'Live TV';

  @override
  String get books => 'Books';

  @override
  String get nextPrayer => 'Next Prayer';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get qibla => 'Qibla';

  @override
  String get fajr => 'Fajr';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get noBookmarkSaved => 'No bookmark saved';

  @override
  String get hadithBooks => 'Hadith Books';

  @override
  String get nineBooksOfSunnah => 'Nine Books of Sunnah';

  @override
  String hadithCount(int count) {
    return '$count Hadith';
  }

  @override
  String page(int number) {
    return 'Page $number';
  }

  @override
  String get noHadithsAvailableOffline =>
      'No hadiths available offline for this book.\nPlease connect to the internet to download.';

  @override
  String get azkar => 'Azkar';

  @override
  String get duas => 'Duas';

  @override
  String get selectedDuas => 'Selected Duas';

  @override
  String get dailyMuslimAzkar => 'Daily Muslim Azkar';

  @override
  String get morningAzkar => 'Morning Azkar';

  @override
  String get eveningAzkar => 'Evening Azkar';

  @override
  String get sleepAzkar => 'Sleep Adhkar';

  @override
  String get wakeUpAzkar => 'Wake up Azkar';

  @override
  String get mosqueAzkar => 'Mosque Azkar';

  @override
  String get adhanAzkar => 'Adhan Azkar';

  @override
  String get wuduAzkar => 'Wudu Azkar';

  @override
  String get propheticDuas => 'Prophetic Duas';

  @override
  String get quranDuas => 'Quran Duas';

  @override
  String get prophetsDuas => 'Prophets Duas';

  @override
  String get miscellaneousAzkar => 'Miscellaneous Azkar';

  @override
  String get done => 'Done';

  @override
  String get startingDownloadAll => 'Starting to download all surahs...';

  @override
  String downloadCompleted(int count) {
    return 'Completed downloading $count surahs';
  }

  @override
  String surahNumber(String number) {
    return 'Surah No. $number';
  }

  @override
  String recitationOf(String name) {
    return 'Recitation of $name';
  }

  @override
  String get downloadSuccessful => 'Download successful';

  @override
  String downloadFailed(String error) {
    return 'Download failed: $error';
  }

  @override
  String get electronicTasbeeh => 'Electronic Tasbeeh';

  @override
  String get totalTasbeehs => 'Total: null';

  @override
  String get tapToCount => 'Tap to count';

  @override
  String get reset => 'Reset';

  @override
  String get history => 'History';

  @override
  String get mushaf => 'Holy Mushaf';

  @override
  String pageSavedAsBookmark(int page) {
    return 'Page $page saved as bookmark';
  }

  @override
  String get readingModeText => 'Text Reading Mode';

  @override
  String lastReadMushaf(int page) {
    return 'Last Read (Page $page)';
  }

  @override
  String lastReadAyah(String surah, String ayah) {
    return 'Last Read ($surah : $ayah)';
  }

  @override
  String mushafWithPage(int page) {
    return 'Holy Mushaf (Page $page)';
  }

  @override
  String pageXOf604(int page) {
    return 'Page $page of 604';
  }

  @override
  String get previous => 'Previous';

  @override
  String get index => 'Index';

  @override
  String get next => 'Next';

  @override
  String get errorLoadingPage => 'Error loading page';

  @override
  String get surahIndex => 'Surah Index';

  @override
  String get errorLoadingSurahs => 'Error loading surahs';

  @override
  String get meccan => 'Meccan';

  @override
  String get medinan => 'Medinan';

  @override
  String ayahsCount(int count) {
    return '$count Ayahs';
  }

  @override
  String pageN(int page) {
    return 'Page $page';
  }

  @override
  String get showMushaf => 'Show Mushaf';

  @override
  String get selectTranslation => 'Select Translation';

  @override
  String get selectTafsir => 'Select Tafsir';

  @override
  String get chooseTranslation => 'Choose Translation';

  @override
  String get chooseTafsir => 'Choose Tafsir';

  @override
  String get chooseSurah => 'Choose Surah';

  @override
  String verseN(Object number) {
    return 'Verse $number';
  }

  @override
  String get noTafsirAvailable => 'No tafsir available currently';

  @override
  String get radio => 'Radio';

  @override
  String get videos => 'Prophetic Biography';

  @override
  String get myAccount => 'My Account';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodLost => 'Lost';

  @override
  String get moodTired => 'Tired';

  @override
  String get surahSharh => 'Surah Ash-Sharh';

  @override
  String get descAnxious =>
      'Remember that with hardship comes ease. This surah brings peace to anxious hearts.';

  @override
  String get actionReadSurah => 'Read Surah';

  @override
  String get surahYusuf => 'Surah Yusuf';

  @override
  String get descSad =>
      'A story of patience and relief after hardship. A balm for sad hearts.';

  @override
  String get surahRahman => 'Surah Ar-Rahman';

  @override
  String get descHappy =>
      'The best way to thank Allah for His blessings. Which of your Lord\'s favors will you deny?';

  @override
  String get surahFatiha => 'Surah Al-Fatiha';

  @override
  String get descLost =>
      'The Mother of the Book and a prayer for guidance to the straight path.';

  @override
  String get descTired =>
      'Rest your soul and calm your mind with the remembrance of Allah before sleep.';

  @override
  String get actionGoToAzkar => 'Go to Adhkar';

  @override
  String becauseYouFeel(String mood) {
    return 'Because you feel $mood';
  }

  @override
  String get howDoYouFeel => 'How do you feel right now?';

  @override
  String get unknownName => 'Unknown';

  @override
  String mushafCount(int count) {
    return '$count Surah';
  }

  @override
  String get nowPlaying => 'Now Playing...';

  @override
  String get reciterLabel => 'Reciter';

  @override
  String get verseOfTheDay => 'Verse of the Day';

  @override
  String get dailyVerseText =>
      'Indeed, with hardship comes ease * Indeed, with hardship comes ease';

  @override
  String get prayerTimesTitle => 'Prayer Times';

  @override
  String get noPrayerTimesFound => 'No prayer times found for these inputs';

  @override
  String get cityLabel => 'City';

  @override
  String get countryLabel => 'Country';

  @override
  String get updateTimesButton => 'Update Times';

  @override
  String prayerTimeError(String error) {
    return 'Error occurred: $error';
  }

  @override
  String get sunrise => 'Sunrise';

  @override
  String get nowListening => 'Now Listening';

  @override
  String get sleepTimer => 'Sleep Timer';

  @override
  String get share => 'Share';

  @override
  String comingSoon(Object feature) {
    return '$feature will be enabled soon';
  }

  @override
  String get startingDownload => 'Starting download...';

  @override
  String get download => 'Download';

  @override
  String get playlist => 'Playlist';

  @override
  String get currentPlaylist => 'Current Playlist';

  @override
  String audioCount(Object count) {
    return '$count audios';
  }

  @override
  String get nowPlayingLabel => 'Now Playing';

  @override
  String timeRemaining(Object time) {
    return 'Time remaining: $time';
  }

  @override
  String get stopTimer => 'Stop Timer';

  @override
  String get sleepTimerStopped => 'Sleep timer stopped';

  @override
  String timerSetFor(Object time) {
    return 'Timer set for $time';
  }

  @override
  String get surahIdNotFound => 'Surah identifier not found';

  @override
  String get errorLoadingText => 'Error loading text';

  @override
  String shareRecitationText(Object link, Object reciter, Object title) {
    return 'Listen to $title by $reciter via Islamic Library App.\n\n$link';
  }

  @override
  String minutes(Object count) {
    return '$count minutes';
  }

  @override
  String timerOption(String count) {
    return '$count minutes';
  }

  @override
  String get readingModeOnlyForQuran =>
      'Reading mode is only available for the Holy Quran';

  @override
  String get liveTvTitle => 'Live TV';

  @override
  String get religiousChannelsDescription => 'Religious channels 24/7';

  @override
  String get videoPlayerError => 'Unable to play video';

  @override
  String get checkInternetConnection =>
      'Please check your internet connection and try again';

  @override
  String get retry => 'Retry';

  @override
  String get islamicRadioTitle => 'Islamic Radio';

  @override
  String get liveRadioDescription => 'Live broadcast 24/7';

  @override
  String get searchRadioHint => 'Search for station...';

  @override
  String get videoLibraryTitle => 'Prophetic Biography';

  @override
  String get searchVideoHint => 'Search biography...';

  @override
  String get all => 'All';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get reciters => 'Reciters';

  @override
  String get surahs => 'Surahs';

  @override
  String get noFavoriteReciters => 'No favorite reciters';

  @override
  String get noFavoriteSurahs => 'No favorite surahs';

  @override
  String get noFavoriteHadiths => 'No favorite hadiths';

  @override
  String get unknownReciter => 'Unknown';

  @override
  String downloadingSurah(String surah) {
    return 'Downloading $surah...';
  }

  @override
  String get downloaded => 'Downloaded';

  @override
  String get downloadsTitle => 'Downloads';

  @override
  String get downloadedSurahs => 'Downloaded Surahs';

  @override
  String get downloadedLibraryDescription => 'Your downloaded audio library';

  @override
  String get libraryEmpty => 'Library is empty';

  @override
  String get downloadedFilesWillAppearHere =>
      'Downloaded files will appear here';

  @override
  String downloadedSurahCount(Object count) {
    return '$count downloaded';
  }

  @override
  String get audioFile => 'Audio File';

  @override
  String get deleteFileQuestion => 'Delete File?';

  @override
  String get deleteFileConfirmation =>
      'Are you sure you want to permanently delete this file?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get booksLibraryTitle => 'Books Library';

  @override
  String get articlesAndBooksTitle => 'Articles & Books';

  @override
  String get searchLibraryHint => 'Search library...';

  @override
  String get booksLabel => 'Books';

  @override
  String get articlesLabel => 'Articles';

  @override
  String get audiosLabel => 'Audio';

  @override
  String get noSearchResults => 'No search results';

  @override
  String get downloadButton => 'Download';

  @override
  String pageCount(int page) {
    return 'Page $page';
  }

  @override
  String get allRecitersTitle => 'All Reciters';

  @override
  String get chooseYourFavoriteReciter => 'Choose your favorite reciter';

  @override
  String get searchForReciter => 'Search for a reciter...';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get trySearchingWithOtherWords => 'Try searching with other words';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get mainMenu => 'Main Menu';

  @override
  String get readingMedia => 'Reading & Media';

  @override
  String get utilitiesTools => 'Utilities & Tools';

  @override
  String get appNameEnglish => 'Islam Home';

  @override
  String get appNameArabic => 'Bait Al-Islam';

  @override
  String get home => 'Home';

  @override
  String get hadith => 'Hadith';

  @override
  String surahName(String name) {
    return '$name';
  }

  @override
  String reciterName(String name) {
    return '$name';
  }

  @override
  String get useLocation => 'Use Current Location';

  @override
  String get locationServicesDisabled => 'Location services are disabled.';

  @override
  String get locationPermissionsDenied => 'Location permissions are denied.';

  @override
  String get locationPermissionsPermanentlyDenied =>
      'Location permissions are permanently denied, we cannot request permissions.';

  @override
  String failedToGetLocation(String error) {
    return 'Failed to get location: $error';
  }

  @override
  String get updateLocation => 'Update Location';

  @override
  String get surahDuha => 'Surah Ad-Duha';

  @override
  String get descDuha =>
      'Your Lord has not forsaken you. A divine message for every heart feeling distressed.';

  @override
  String get actionGoToDua => 'Go to Supplications';

  @override
  String get startTasbeeh => 'Start Tasbeeh';

  @override
  String get rememberAllah => 'Remembrance of Allah';

  @override
  String get descHappyDhikr =>
      'Praising Allah increases blessings and sustains happiness.';

  @override
  String get allahIsNear => 'Allah is Near';

  @override
  String get descLostDhikr =>
      'Allah is always close to you, guiding you and hearing your prayers if you lose your way.';

  @override
  String get descAnxiousDhikr =>
      'Remembrance of Allah calms anxious hearts. Say: \"Indeed, with hardship comes ease\" and trust in His mercy.';

  @override
  String get rewardForTired => 'Reward for Tiredness';

  @override
  String get descTiredDhikr =>
      'Remember that your tiredness is rewarded, and Allah does not burden a soul beyond its capacity.';

  @override
  String get searchHint => 'Search Quran, Hadith, Adhkar...';

  @override
  String searchQuranSubtitle(String surah, int ayah) {
    return 'Quran: $surah ($ayah)';
  }

  @override
  String searchHadithSubtitle(String book, String chapter) {
    return 'Hadith: $book - $chapter';
  }

  @override
  String searchAdhkarSubtitle(String category) {
    return 'Adhkar: $category';
  }

  @override
  String get exploreLibrary => 'Explore the Library';

  @override
  String get searchDescription => 'Search for verses, hadiths, and prayers';

  @override
  String get khatmaPlannerTitle => 'Smart Khatma Planner';

  @override
  String get khatmaPlannerSubtitle =>
      'Specify the duration to complete the Quran';

  @override
  String get startKhatma => 'Start Khatma';

  @override
  String get days => 'Days';

  @override
  String get pagesDaily => 'Pages daily';

  @override
  String get pagesPerPrayer => 'Pages per prayer';

  @override
  String remainingToday(int count) {
    return '$count pages remaining today';
  }

  @override
  String get onTrack => 'You are on track';

  @override
  String get setupPlan => 'Setup Plan';

  @override
  String get cancelPlan => 'Cancel Plan';

  @override
  String get manageNotificationSettings => 'Manage Notification Settings';

  @override
  String get manageNotificationSettingsSubtitle =>
      'Open system settings for notifications';

  @override
  String get continueYourKhatma => 'Continue Your Khatma';

  @override
  String juzAndSurah(Object juz, Object surah) {
    return 'Juz $juz - $surah';
  }

  @override
  String get smartSuggestionsForNewPlan =>
      'Smart suggestions for your new plan:';

  @override
  String get khatmaInMonth => 'Khatma in a month';

  @override
  String get oneJuzDaily => '1 Juz daily';

  @override
  String get khatmaInTwoMonths => 'Khatma in two months';

  @override
  String get fifteenPagesDaily => '15 pages daily';

  @override
  String pagesRemainingToday(Object count) {
    return '$count pages remaining today';
  }

  @override
  String get khatmaHistory => 'Khatma History';

  @override
  String get khatmaSettings => 'Khatma Settings';

  @override
  String get duaKhatm => 'Dua for Completing Quran';

  @override
  String get mayAllahAccept => 'May Allah accept from you';

  @override
  String get shareDua => 'Share Dua';

  @override
  String get mayAllahAcceptAll => 'May Allah accept from us and you';

  @override
  String get continueReading => 'Continue Reading';

  @override
  String get activePlans => 'Active Plans';

  @override
  String get totalAchievement => 'Total Achievement';

  @override
  String khatmaCount(int count) {
    return 'You have completed the Quran $count times';
  }

  @override
  String get currentPageLabel => 'Current Page';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get dailyTargetLabel => 'Today\'s Target';

  @override
  String get duration => 'Duration';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get khatmaSuccessful => 'Khatma Completed Successfully';

  @override
  String get noActivePlans => 'No active plans currently';

  @override
  String get noHistoryYet => 'No history recorded yet';

  @override
  String get previousAchievements => 'Previous Achievements:';

  @override
  String get previousKhatmaHistory => 'Previous Khatmas History';

  @override
  String get blessedKhatma => 'Blessed Khatma';

  @override
  String get noKhatmasRecorded => 'No khatmas recorded yet';

  @override
  String get khatmCompletedPraise => 'Completed with praise to Allah';

  @override
  String daysCount(int count) {
    return '$count Days';
  }

  @override
  String get newKhatma => 'New Khatma';

  @override
  String get prayerAdjustment => 'Prayer Time Adjustment';

  @override
  String get prayerAdjustmentSubtitle => 'Add or subtract minutes (DST)';

  @override
  String adjustMinutes(Object minutes) {
    return 'Adjust $minutes minutes';
  }

  @override
  String get manualOffset => 'Manual Time Offset';

  @override
  String hours(Object count) {
    return '$count hours';
  }

  @override
  String get hour => 'Hour';

  @override
  String get adjustHours => 'Adjust Hours';

  @override
  String get useAutoLocation => 'Use Auto Location (GPS)';

  @override
  String get moreSettings => 'More Settings...';

  @override
  String get audioServiceNotReady =>
      'Audio service not ready yet, please try again';

  @override
  String get playingInBackground => 'Playing clip as background audio';

  @override
  String failedToPlay(String error) {
    return 'Failed to play clip: $error';
  }

  @override
  String get later => 'Later';

  @override
  String get activateNow => 'Activate Now';

  @override
  String get downloadAllStarted => 'Started downloading all to playlist';

  @override
  String get noServerLinkError => 'Error: No server link for reciter';

  @override
  String playlistPlayError(String error) {
    return 'Error playing playlist: $error';
  }

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get noSensors => 'Device does not have sensors';

  @override
  String get save => 'Save';

  @override
  String get playlistNotFound => 'Playlist not found';

  @override
  String get createNewPlaylist => 'Create New Playlist';

  @override
  String get playlistImportedSuccessfully => 'Playlist imported successfully';

  @override
  String get readingSettings => 'Reading Settings';

  @override
  String get translation => 'Translation';

  @override
  String get tafsir => 'Tafsir';

  @override
  String get switchToListView => 'Switch to List View';

  @override
  String get switchToFlowView => 'Switch to Flow View';

  @override
  String get surah => 'Surah';

  @override
  String get pageLabel => 'Page';

  @override
  String get juz => 'Juz';

  @override
  String get hizb => 'Hizb';

  @override
  String get nightMode => 'Night Mode';

  @override
  String get dayMode => 'Day Mode';

  @override
  String get lastReadSaved => 'Saved as last read';

  @override
  String get lastReadUpdated => 'Last read time updated';

  @override
  String lastReadReplaced(
    String prevSurah,
    int prevAyah,
    String newSurah,
    int newAyah,
  ) {
    return 'Replaced $prevSurah:$prevAyah with $newSurah:$newAyah';
  }

  @override
  String get lastReadSaveFailed => 'Failed to save. Please try again.';

  @override
  String get narrator => 'Narrator';

  @override
  String get book => 'Book';

  @override
  String get chapter => 'Chapter';

  @override
  String get copy => 'Copy';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get jumpToHadith => 'Jump to Hadith';

  @override
  String get searchHadith => 'Search Hadith...';

  @override
  String get bookmark => 'Bookmark';

  @override
  String get hijriAdjustment => 'Hijri Date Adjustment';

  @override
  String get hijriAdjustmentSubtitle =>
      'Add or subtract days for regional accuracy';

  @override
  String adjustDays(Object days) {
    return 'Adjust $days days';
  }

  @override
  String get fontSettings => 'Font Settings';

  @override
  String get mushafFontSize => 'Mushaf Font Size';

  @override
  String get translationFontSize => 'Translation Font Size';

  @override
  String get playlists => 'Playlists';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get noPlaylistsYet => 'No playlists yet';

  @override
  String get playlistCreated => 'Playlist created successfully';

  @override
  String get deletePlaylist => 'Delete Playlist';

  @override
  String get renamePlaylist => 'Rename Playlist';

  @override
  String get playlistNameHint => 'Playlist name...';

  @override
  String get create => 'Create';

  @override
  String surahsCount(int count) {
    return '$count Surahs';
  }

  @override
  String get noPlaylistsMessage =>
      'No playlists found. Create one from the favorites section.';

  @override
  String addedToPlaylist(Object playlistName) {
    return 'Added to $playlistName';
  }

  @override
  String get duaKhatmQuran => 'Quran Completion Dua';

  @override
  String get lastRead => 'Last Read';

  @override
  String get chooseReciter => 'Choose Reciter';

  @override
  String get fontSize => 'Font Size';

  @override
  String get search => 'Search';

  @override
  String errorPlayingAudio(String message) {
    return 'Error playing audio: $message';
  }

  @override
  String navigatedToAyah(String surah, int ayah) {
    return 'Navigated to $surah - Ayah $ayah';
  }

  @override
  String get setTarget => 'Set Target';

  @override
  String get tasbeehHistory => 'Tasbeeh History';

  @override
  String get noTasbeehToday => 'No tasbeeh recorded today';

  @override
  String get dailySummary => 'Today\'s Summary';

  @override
  String get hourlyBreakdown => 'Activity by Hour';

  @override
  String get detailedLog => 'Detailed Log';

  @override
  String get weeklyActivity => 'Weekly Activity';

  @override
  String streakDays(int count) {
    return '$count day streak';
  }

  @override
  String get todayTotal => 'Today';

  @override
  String get allTimeTasbeehs => 'All-time total';

  @override
  String get setCompleteTitle => 'Set Complete!';

  @override
  String get setCompleteSubtitle => 'May Allah accept your dhikr';

  @override
  String get totalLabel => 'Total';

  @override
  String get calculationMethodTitle => 'Calculation Method';

  @override
  String get sidebarMainQuran => 'Home & Quran';

  @override
  String get sidebarTools => 'Muslim Tools';

  @override
  String get sidebarContent => 'Islamic Content';

  @override
  String get sidebarOther => 'Other';

  @override
  String get sidebarTagline => 'Spiritual Journey & Library';

  @override
  String get sira => 'Life of the Prophet';

  @override
  String get prophetLife => 'Life of the Prophet ﷺ';

  @override
  String get allSections => 'All';

  @override
  String get activeDownloads => 'Active';

  @override
  String get completedDownloads => 'Completed';

  @override
  String get downloadingTab => 'Downloading';

  @override
  String get downloadedTab => 'Downloaded';

  @override
  String get noActiveDownloads => 'No active downloads';

  @override
  String get noActiveDownloadsDesc =>
      'You can download Surahs to listen offline later';

  @override
  String get quranSection => 'The Holy Quran';

  @override
  String get seerahSection => 'Prophetic Biography';

  @override
  String get emptyDownloadsHistory => 'Download history is empty';

  @override
  String get emptyDownloadsHistoryDesc =>
      'You haven\'t downloaded any Surahs yet';
}
