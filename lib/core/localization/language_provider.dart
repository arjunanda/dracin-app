import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { id, en }

final languageProvider = StateProvider<AppLanguage>((ref) => AppLanguage.id);

class AppStrings {
  static Map<String, Map<AppLanguage, String>> _strings = {
    'settings': {AppLanguage.id: 'Pengaturan', AppLanguage.en: 'Settings'},
    'theme': {AppLanguage.id: 'Tema', AppLanguage.en: 'Theme'},
    'language': {AppLanguage.id: 'Bahasa', AppLanguage.en: 'Language'},
    'notifications': {
      AppLanguage.id: 'Notifikasi',
      AppLanguage.en: 'Notifications',
    },
    'help_center': {
      AppLanguage.id: 'Pusat Bantuan',
      AppLanguage.en: 'Help Center',
    },
    'about_dracin': {
      AppLanguage.id: 'Tentang Dracin',
      AppLanguage.en: 'About Dracin',
    },
    'edit_profile': {
      AppLanguage.id: 'Edit Profil',
      AppLanguage.en: 'Edit Profile',
    },
    'logout': {AppLanguage.id: 'Keluar', AppLanguage.en: 'Logout'},
    'preferences': {
      AppLanguage.id: 'PREFERENSI',
      AppLanguage.en: 'PREFERENCES',
    },
    'support': {AppLanguage.id: 'DUKUNGAN', AppLanguage.en: 'SUPPORT'},
    'version': {AppLanguage.id: 'Versi', AppLanguage.en: 'Version'},
    'home': {AppLanguage.id: 'Beranda', AppLanguage.en: 'Home'},
    'for_you': {AppLanguage.id: 'Untuk Anda', AppLanguage.en: 'For You'},
    'watchlist': {AppLanguage.id: 'Daftar Tonton', AppLanguage.en: 'Watchlist'},
    'profile': {AppLanguage.id: 'Profil', AppLanguage.en: 'Profile'},
    'my_watchlist': {
      AppLanguage.id: 'Daftar Tonton Saya',
      AppLanguage.en: 'My Watchlist',
    },
    'login': {AppLanguage.id: 'Masuk', AppLanguage.en: 'Login'},
    'help': {AppLanguage.id: 'Bantuan', AppLanguage.en: 'Help'},
    'watchlist_subtitle': {
      AppLanguage.id: 'Anda punya {count} drama untuk ditonton',
      AppLanguage.en: 'You have {count} dramas to catch up on',
    },
    'empty_watchlist_title': {
      AppLanguage.id: 'Belum ada tontonan?',
      AppLanguage.en: 'Nothing to watch?',
    },
    'empty_watchlist_subtitle': {
      AppLanguage.id:
          'Daftar tontonanmu masih sepi.\nWaktunya cari tontonan baru!',
      AppLanguage.en:
          'Your watchlist is feeling a bit lonely.\nTime to find your next obsession!',
    },
    'explore_dramas': {
      AppLanguage.id: 'Jelajahi Drama',
      AppLanguage.en: 'Explore Dramas',
    },
    'trending': {
      AppLanguage.id: 'Tren Sekarang',
      AppLanguage.en: 'Trending Now',
    },
    'latest': {AppLanguage.id: 'Terbaru', AppLanguage.en: 'Latest'},
    'recommended': {
      AppLanguage.id: 'Rekomendasi',
      AppLanguage.en: 'Recommended',
    },
    'top_rated': {
      AppLanguage.id: 'Rating Tertinggi',
      AppLanguage.en: 'Top Rated',
    },
  };

  static String get(String key, AppLanguage lang) {
    return _strings[key]?[lang] ?? key;
  }
}
