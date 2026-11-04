import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yelima/core/router/route_paths.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/shared/widgets/layout/app_button.dart';
import 'package:yelima/core/core_providers.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/core/constants/app_images.dart';
import 'package:yelima/shared/widgets/forms/app_dropdown.dart';

/// First launch: pick the app language, then continue to sign-in.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentLocale = ref.read(localeControllerProvider)?.languageCode;
      if (languageCodes.contains(currentLocale)) {
        setState(() {
          _selectedLang = currentLocale!;
        });
      }
    });
  }

  void _onContinue() async {
    ref
        .read(localeControllerProvider.notifier)
        .setLocale(Locale(_selectedLang));
    await ref.read(sharedPrefsServiceProvider).setOnboardingCompleted();
    if (mounted) {
      context.go(RoutePaths.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: Transform.scale(
                  scale: 2.0,
                  child: const Image(
                    image: AppImages.logoPng,
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: AppText.headlineMedium(
                  context.l10n.welcomeTitle,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: AppText.bodyLarge(
                  context.l10n.chooseLanguage,
                  textAlign: TextAlign.center,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 48),
              AppDropdown<String>(
                value: _selectedLang,
                hintText: context.l10n.chooseLanguage,
                items: languageCodes,
                itemLabelBuilder: context.l10n.languageName,
                onChanged: (code) {
                  setState(() {
                    _selectedLang = code;
                  });
                  ref
                      .read(localeControllerProvider.notifier)
                      .setLocale(Locale(code));
                },
              ),
              const Spacer(flex: 3),
              AppButton(
                text: context.l10n.continueText,
                onPressed: _onContinue,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
