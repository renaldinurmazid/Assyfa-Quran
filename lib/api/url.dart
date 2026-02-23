class Url {
  static const String baseUrl = 'https://quran.titiktolak.com';
  // static const String baseUrl = 'http://10.0.2.2:8000';
  static const String quranPage = '/api/quran';
  static const String dropdownSurah = '/api/quran/dropdown-surah';
  static const String dropdownJuz = '/api/quran/dropdown-juz';
  static const String loginGoogle = '/api/login/google';
  static const String changeProfile = '/api/change-profile';
  static const String groups = '/api/groups';
  static const String quranOfflineIndex = '/api/quran/offline/index';
  static const String quranOfflinePage = '/api/quran/offline/page';
  static const String campaigns = '/api/campaigns';
  static const String logout = '/api/logout';
  static const String listMarkers = '/api/list-markers';
  static const String saveMarkers = '/api/toggle-marker';
  static const String listUserMarkers = '/api/list-user-markers';

  static const String readingHistory = '/api/reading-history';
  static const String readingHistoryWeekly = '/api/reading-history/weekly';

  static const String paymentMethodes = '/api/payment-methodes';
  static const String notifications = '/api/notifications';
  static String markAsRead(int id) => '/api/notifications/$id/read';
  static const String markAllAsRead = '/api/notifications/read-all';

  static const String publicGroups = '/api/public-groups';

  static const String donations = '/api/donations';
  static const String saveFcmToken = '/api/save-fcm-token';

  static const String mosqueCharity = '/api/mosque-charities';
  static const String banners = '/api/banners';

  static const String mosqueCharityPayment = '/api/mosque-donations';
  static const String leaderboard = '/api/reading-history/leaderboard';
  static const String myReferral = '/api/my-referral';

  static const String appShareLeaderboard = '/api/app-share/leaderboard';
  static const String blogs = '/api/blogs';
  static const String blogCategories = '/api/blog-categories';
  static String blogDetail(String slug) => '/api/blogs/$slug';
  static String recordView(String slug) => '/api/blogs/$slug/view';
  static String toggleLike(int id) => '/api/blogs/$id/like';
  static const String prayers = '/api/prayers';
  static String prayerDetail(int id) => '/api/prayers/$id';
  static String amenPrayer(int id) => '/api/prayers/$id/amen';
  static const String prayerTimes = '/api/prayer-times';
}
