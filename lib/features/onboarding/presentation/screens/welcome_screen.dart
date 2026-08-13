import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:yelima/core/router/route_paths.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/shared/widgets/layout/app_button.dart';
import 'package:yelima/core/services/shared_prefs_service.dart';
import 'package:yelima/injection_container.dart';
import 'package:yelima/core/controllers/locale_controller.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/core/constants/app_images.dart';
import 'package:yelima/shared/widgets/forms/app_dropdown.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentLocale =
          context.read<LocaleController>().locale?.languageCode;
      if (['en', 'tw', 'ee', 'ga'].contains(currentLocale)) {
        setState(() {
          _selectedLang = currentLocale!;
        });
      }
    });
  }

  void _onContinue() async {
    context.read<LocaleController>().setLocale(Locale(_selectedLang));
    await sl<SharedPrefsService>().setOnboardingCompleted();
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
                items: const ['en', 'tw', 'ee', 'ga'],
                itemLabelBuilder: (code) {
                  switch (code) {
                    case 'en':
                      return context.l10n.english;
                    case 'tw':
                      return context.l10n.akanTwi;
                    case 'ee':
                      return context.l10n.ewe;
                    case 'ga':
                      return context.l10n.ga;
                    default:
                      return context.l10n.english;
                  }
                },
                onChanged: (code) {
                  setState(() {
                    _selectedLang = code;
                  });
                  context.read<LocaleController>().setLocale(Locale(code));
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
