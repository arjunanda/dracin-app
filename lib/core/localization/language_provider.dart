import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { id, en }

final languageProvider = StateProvider<AppLanguage>((ref) => AppLanguage.en);

class AppStrings {
  static final Map<String, Map<AppLanguage, String>> _strings = {
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
    'faq_account_detail': {
      AppLanguage.id:
          '• Cara Reset Password: Klik "Lupa Password" di halaman login.\n• Ubah Profil: Buka menu Profile > Edit.\n• Keamanan: Jangan bagikan akun Anda dengan orang lain.',
      AppLanguage.en:
          '• How to Reset Password: Click "Forgot Password" on login page.\n• Change Profile: Go to Profile > Edit.\n• Security: Do not share your account with others.',
    },
    'faq_streaming_detail': {
      AppLanguage.id:
          '• Koneksi: Pastikan internet Anda stabil (min. 5Mbps).\n• Kualitas: Atur kualitas video ke "Otomatis".\n• Cache: Bersihkan cache aplikasi jika video macet.',
      AppLanguage.en:
          '• Connection: Ensure stable internet (min. 5Mbps).\n• Quality: Set video quality to "Auto".\n• Cache: Clear app cache if video lags.',
    },
    'welcome_back': {
      AppLanguage.id: 'Selamat Datang',
      AppLanguage.en: 'Welcome Back',
    },
    'login_subtitle': {
      AppLanguage.id: 'Masuk untuk melanjutkan menonton drama favorit Anda.',
      AppLanguage.en: 'Login to continue watching your favorite dramas.',
    },
    'continue_google': {
      AppLanguage.id: 'Lanjutkan dengan Google',
      AppLanguage.en: 'Continue with Google',
    },
    'continue_facebook': {
      AppLanguage.id: 'Lanjutkan dengan Facebook',
      AppLanguage.en: 'Continue with Facebook',
    },
    'continue_tiktok': {
      AppLanguage.id: 'Lanjutkan dengan TikTok',
      AppLanguage.en: 'Continue with TikTok',
    },
    'login_disclaimer': {
      AppLanguage.id:
          'Dengan masuk, Anda menyetujui Ketentuan Layanan dan Kebijakan Privasi kami.',
      AppLanguage.en:
          'By logging in, you agree to our Terms of Service and Privacy Policy.',
    },
    'back': {AppLanguage.id: 'Kembali', AppLanguage.en: 'Back'},
    'top_rated': {
      AppLanguage.id: 'Rating Tertinggi',
      AppLanguage.en: 'Top Rated',
    },
    'help_center_desc': {
      AppLanguage.id:
          'Temukan jawaban atas pertanyaan Anda atau hubungi tim dukungan kami.',
      AppLanguage.en:
          'Find answers to your questions or contact our support team.',
    },
    'faq_account_title': {
      AppLanguage.id: 'Masalah Akun',
      AppLanguage.en: 'Account Issues',
    },
    'faq_account_desc': {
      AppLanguage.id: 'Cara mengatur ulang kata sandi dan mengelola profil.',
      AppLanguage.en: 'How to reset passwords and manage profiles.',
    },
    'faq_billing_title': {
      AppLanguage.id: 'Pembayaran & Langganan',
      AppLanguage.en: 'Billing & Subscription',
    },
    'faq_billing_desc': {
      AppLanguage.id: 'Informasi tentang paket dan metode pembayaran.',
      AppLanguage.en: 'Information about plans and payment methods.',
    },
    'faq_streaming_title': {
      AppLanguage.id: 'Kualitas Streaming',
      AppLanguage.en: 'Streaming Quality',
    },
    'faq_streaming_desc': {
      AppLanguage.id: 'Tips untuk pemutaran video yang lancar.',
      AppLanguage.en: 'Tips for smooth video playback.',
    },
    'share_to': {AppLanguage.id: 'Bagikan ke', AppLanguage.en: 'Share to'},
    'cancel': {AppLanguage.id: 'Batal', AppLanguage.en: 'Cancel'},
    'copy_link': {AppLanguage.id: 'Salin Tautan', AppLanguage.en: 'Copy Link'},
  };

  static String get(String key, AppLanguage lang) {
    return _strings[key]?[lang] ?? key;
  }
}
