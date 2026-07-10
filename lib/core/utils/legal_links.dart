import 'package:url_launcher/url_launcher.dart';

class LegalLinks {
  static const String privacyPolicy = 'https://doc-hosting.flycricket.io/yelima-privacy-policy/8f70bb5e-1319-46ea-88db-ff7843e9e403/privacy';
  static const String termsOfService = 'https://doc-hosting.flycricket.io/yelima-term-and-conditions/7ffe7f54-9ef2-4eb7-a79e-8e09b25753d5/terms';

  static Future<void> launchPrivacy() async {
    final url = Uri.parse(privacyPolicy);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> launchTerms() async {
    final url = Uri.parse(termsOfService);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
