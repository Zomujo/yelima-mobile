import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yelima/core/router/route_paths.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/core/theme/app_motion.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/shared/widgets/layout/app_button.dart';
import 'package:yelima/core/core_providers.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/core/constants/app_images.dart';
import 'package:yelima/shared/widgets/forms/app_dropdown.dart';
import 'package:yelima/shared/widgets/motion/entrance.dart';
import 'package:yelima/shared/widgets/motion/fade_switch.dart';

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

  void _onLanguageChanged(String code) {
    setState(() => _selectedLang = code);
    ref.read(localeControllerProvider.notifier).setLocale(Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const _Logo(),
              const SizedBox(height: 8),
              _SwitchingText(
                index: 1,
                child: AppText.headlineMedium(
                  l10n.welcomeTitle,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              _SwitchingText(
                index: 2,
                child: AppText.bodyLarge(
                  l10n.chooseLanguage,
                  textAlign: TextAlign.center,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 48),
              Entrance(
                index: 3,
                child: AppDropdown<String>(
                  value: _selectedLang,
                  hintText: l10n.chooseLanguage,
                  items: languageCodes,
                  itemLabelBuilder: l10n.languageName,
                  onChanged: _onLanguageChanged,
                ),
              ),
              const Spacer(flex: 3),
              Entrance(
                index: 4,
                child: AppButton(
                  text: l10n.continueText,
                  onPressed: _onContinue,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The app logo, fading in while it grows gently into place.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final logo = Center(
      child: Transform.scale(
        scale: 2.0,
        child: const Image(image: AppImages.logoPng, width: 120, height: 120),
      ),
    );
    if (AppMotion.reduced(context)) return logo;
    return logo
        .animate()
        .fadeIn(duration: AppMotion.slow, curve: AppMotion.enter)
        .scaleXY(
            begin: 0.9,
            end: 1,
            duration: AppMotion.slow,
            curve: AppMotion.enter);
  }
}

/// Centred text that rises in at [index] and cross-fades when the language changes.
class _SwitchingText extends StatelessWidget {
  const _SwitchingText({required this.index, required this.child});

  final int index;
  final AppText child;

  @override
  Widget build(BuildContext context) => Entrance(
        index: index,
        child: Center(child: FadeSwitch(id: child.text, child: child)),
      );
}
