class Url {
  // static const String baseUrl = 'https://quran.titiktolak.com';
  static const String baseUrl = 'http://192.168.100.4:8000';
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
}
