class Url {
  // static const String baseUrl = 'https://quran.titiktolak.com';
  // static const String baseUrl = 'http://10.0.2.2:8000';
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String quranPage = '/api/quran';
  static const String dropdownSurah = '/api/quran/dropdown-surah';
  static const String dropdownJuz = '/api/quran/dropdown-juz';
  static const String dropdownPage = '/api/quran/dropdown-page';
  static const String loginGoogle = '/api/login/google';
  static const String loginApple = '/api/login/apple';
  static const String login = '/api/login';
  static const String changeProfile = '/api/change-profile';
  static const String groups = '/api/groups';
  static const String quranOfflineIndex = '/api/quran/offline/index';
  static const String quranOfflinePage = '/api/quran/offline/page';
  static const String quranOfflineDropdowns = '/api/quran/offline/dropdowns';
  static const String campaigns = '/api/campaigns';
  static const String umrah = '/api/umrah';
  static const String umrahFilters = '/api/umrah/filters';
  static const String campaignCategories = '/api/campaign-categories';
  static const String logout = '/api/logout';
  static const String listMarkers = '/api/list-markers';
  static const String saveMarkers = '/api/toggle-marker';
  static const String listUserMarkers = '/api/list-user-markers';
  static const String nearbyMosques = '/api/nearby-mosques';

  static const String readingHistory = '/api/reading-history';
  static const String readingHistoryWeekly = '/api/reading-history/weekly';

  static const String paymentMethodes = '/api/payment-methodes';
  static const String notifications = '/api/notifications';
  static const String notificationsCategories = '/api/notifications/categories';
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
  static String blogShare(int id) => '/api/blogs/$id/share';
  static const String prayers = '/api/prayers';
  static const String myPrayers = '/api/my-prayers';
  static String prayerDetail(int id) => '/api/prayers/$id';
  static String amenPrayer(int id) => '/api/prayers/$id/amen';
  static const String prayerTimes = '/api/prayer-times';
  static const String readingHistoryTotal = '/api/reading-history/total';

  // Popups
  static const String popups = '/api/popups';
  static String popupView(int id) => '/api/popups/$id/view';
  static String popupDismiss(int id) => '/api/popups/$id/dismiss';
  static String popupClick(int id) => '/api/popups/$id/click';

  // Blog Comments
  static String blogComments(int id) => '/api/blogs/$id/comments';
  static const String blogCommentsStore = '/api/blog-comments';
  static String blogCommentUpdate(int id) => '/api/blog-comments/$id';
  static String blogCommentDelete(int id) => '/api/blog-comments/$id';

  // Memorization
  static const String memorizationLevels = '/api/memorization/levels';
  static String memorizationLevelDetail(int id) =>
      '/api/memorization/levels/$id';
  static String memorizationQuestionComplete(int id) =>
      '/api/memorization/questions/$id/complete';
  static const String memorizationStats = '/api/memorization/stats';
  static const String memorizationLeaderboard = '/api/memorization/leaderboard';
  static const String dzikirStats = '/api/dzikir/stats';
  static const String dzikirView = '/api/dzikir/view';

  static const String deleteAccount = '/api/delete-account';
  static const String reciters = '/api/reciters';
}
