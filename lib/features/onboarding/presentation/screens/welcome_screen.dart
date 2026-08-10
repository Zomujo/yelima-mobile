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
      if (currentLocale == 'tw' || currentLocale == 'en') {
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
              _buildLanguageOption(
                code: 'en',
                title: 'English',
                subtitle: 'US/UK',
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(
                code: 'tw',
                title: 'Akan Twi',
                subtitle: 'Ghana',
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

  Widget _buildLanguageOption({
    required String code,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedLang == code;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLang = code;
        });
        context.read<LocaleController>().setLocale(Locale(code));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  code.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.titleMedium(
                    title,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 4),
                  AppText.bodySmall(
                    subtitle,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 28,
              )
            else
              const Icon(
                Icons.circle_outlined,
                color: Colors.grey,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
