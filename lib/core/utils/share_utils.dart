import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ShareUtils {
  static const MethodChannel _channel = MethodChannel('com.dracin.app/share');

  /// Shares text using the system's native share sheet
  static Future<void> shareText(String text, {String? subject}) async {
    try {
      await _channel.invokeMethod('share', {
        'text': text,
        'subject': subject ?? 'Share Drama',
      });
    } on PlatformException catch (e) {
      debugPrint('Error sharing text: ${e.message}');
      // Fallback or ignore
    }
  }

  /// Copies text to clipboard
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Opens a URL using the system's default browser or app
  /// This is a "no-package" alternative to url_launcher
  static Future<void> openUrl(String url) async {
    try {
      await _channel.invokeMethod('openUrl', {'url': url});
    } on PlatformException catch (e) {
      debugPrint('Error opening URL: ${e.message}');
    }
  }

  /// Share to WhatsApp
  static Future<void> shareToWhatsApp(String text) async {
    final url = 'whatsapp://send?text=${Uri.encodeComponent(text)}';
    await openUrl(url);
  }

  /// Share to Telegram
  static Future<void> shareToTelegram(String text) async {
    final url = 'https://t.me/share/url?url=${Uri.encodeComponent(text)}';
    await openUrl(url);
  }

  /// Share to Facebook
  static Future<void> shareToFacebook(String text) async {
    // Facebook usually requires a URL
    final url =
        'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(text)}';
    await openUrl(url);
  }
}
