import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/logger.dart';

/// Service responsible for managing application updates.
///
/// Handles both:
/// 1. OTA (Over-The-Air) patches via Shorebird.
/// 2. Store updates (App Store / Play Store) via Upgrader logic.
class UpdateService {
  static const String _appStoreId = 'YOUR_APP_STORE_ID';
  static const String _bundleId = 'YOUR_BUNDLE_ID';

  /// Launches the platform-specific store page for the app.
  static Future<void> launchStore() async {
    try {
      final Uri url;
      if (Platform.isIOS) {
        url = Uri.parse('https://apps.apple.com/app/id$_appStoreId');
      } else {
        url = Uri.parse(
            'https://play.google.com/store/apps/details?id=$_bundleId');
      }

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      AppLogger.e('UpdateService: Error launching store', e);
    }
  }

  /// Checks for background OTA patches (Shorebird).
  ///
  /// This should be called during app startup.
  static Future<void> checkForOTAPatches() async {
    try {
      // Note: In a real implementation, you would use:
      // final shorebird = ShorebirdCodePush();
      // if (shorebird.isShorebirdAvailable()) {
      //   final isNewPatchAvailable = await shorebird.isNewPatchAvailableForDownload();
      //   if (isNewPatchAvailable) {
      //     AppLogger.i('UpdateService: New OTA patch found, downloading...');
      //   }
      // }
      AppLogger.d('UpdateService: Shorebird check skipped (Stub)');
    } catch (e) {
      AppLogger.e('UpdateService: Shorebird check failed', e);
    }
  }

  /// Standardized dialog to inform user about a required update.
  static void showUpdateDialog(BuildContext context, {bool force = false}) {
    showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (context) => AlertDialog(
        title: const Text('Update Available 🚀'),
        content: const Text(
          'A new version of the app is available. Update now to get the latest features and improvements.',
        ),
        actions: [
          if (!force)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              launchStore();
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }
}
