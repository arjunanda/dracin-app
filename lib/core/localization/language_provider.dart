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
    'select_language': {
      AppLanguage.id: 'Pilih Bahasa',
      AppLanguage.en: 'Select Language',
    },
    'indonesian': {
      AppLanguage.id: 'Bahasa Indonesia',
      AppLanguage.en: 'Indonesian',
    },
    'english': {AppLanguage.id: 'Bahasa Inggris', AppLanguage.en: 'English'},
    'notification_settings': {
      AppLanguage.id: 'Pengaturan Notifikasi',
      AppLanguage.en: 'Notification Settings',
    },
    'new_episodes': {
      AppLanguage.id: 'Episode Baru',
      AppLanguage.en: 'New Episodes',
    },
    'new_episodes_desc': {
      AppLanguage.id: 'Dapatkan pemberitahuan saat episode baru dirilis.',
      AppLanguage.en: 'Get notified when new episodes are released.',
    },
    'promotions': {
      AppLanguage.id: 'Promosi & Penawaran',
      AppLanguage.en: 'Promotions & Offers',
    },
    'promotions_desc': {
      AppLanguage.id: 'Dapatkan info tentang diskon dan konten spesial.',
      AppLanguage.en: 'Get info about discounts and special content.',
    },
    'system_notif': {
      AppLanguage.id: 'Notifikasi Sistem',
      AppLanguage.en: 'System Notifications',
    },
    'system_notif_desc': {
      AppLanguage.id: 'Pembaruan penting tentang akun dan aplikasi Anda.',
      AppLanguage.en: 'Important updates about your account and app.',
    },
    'about_description': {
      AppLanguage.id:
          'Dracin adalah platform streaming drama pilihan Anda yang menghadirkan konten terbaik dengan kualitas premium. Nikmati pengalaman menonton sinematik dengan koleksi drama yang terus diperbarui.',
      AppLanguage.en:
          'Dracin is your go-to drama streaming platform bringing the best content with premium quality. Enjoy a cinematic viewing experience with a constantly updated collection of dramas.',
    },
    'app_name': {AppLanguage.id: 'Dracin App', AppLanguage.en: 'Dracin App'},
    'company': {
      AppLanguage.id: 'Dikembangkan oleh KiSah Team',
      AppLanguage.en: 'Developed by KiSah Team',
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
