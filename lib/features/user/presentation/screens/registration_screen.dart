import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/core/theme/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yelima/core/router/route_paths.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';
import 'package:yelima/features/user/user_providers.dart';
import 'package:yelima/features/user/presentation/widgets/registration/registration_app_bar.dart';
import 'package:yelima/features/user/presentation/widgets/registration/registration_step_one.dart';
import 'package:yelima/features/user/presentation/widgets/registration/registration_step_two.dart';
import 'package:yelima/features/user/presentation/widgets/registration/registration_step_three.dart';
import 'package:yelima/features/user/presentation/widgets/registration/registration_step_four.dart';
import 'package:yelima/features/auth/presentation/widgets/logout_flow.dart';

/// The four registration steps, resuming where the user left off.
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  late final PageController _pageController;
  late int _page;

  @override
  void initState() {
    super.initState();

    final status =
        ref.read(userControllerProvider).userEntity?.registrationStatus ??
            RegistrationStatus.personalDetails;

    /// Clamp initial page to 0-3 range to prevent out-of-bounds error.
    _page = status.index.clamp(0, 3);
    _pageController = PageController(initialPage: _page);
  }

  /// Slides to [page]: in from the right going forward, from the left going back.
  void _goTo(int page) {
    setState(() => _page = page);
    if (AppMotion.reduced(context)) return _pageController.jumpToPage(page);
    _pageController.animateToPage(page,
        duration: AppMotion.slow, curve: AppMotion.enter);
  }

  void _nextStep() =>
      // After the last step registration is done.
      _page < 3 ? _goTo(_page + 1) : context.go(RoutePaths.home);

  void _previousStep() => _goTo(_page - 1);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Android back goes to the previous step; on step 1 it leaves the app as before.
    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _previousStep();
      },
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RegistrationAppBar(
                currentStep: _page + 1,
                totalSteps: 4,
                onClose: () => logOutWithSyncCheck(context),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    RegistrationStepOne(onContinue: _nextStep),
                    RegistrationStepTwo(
                        onBack: _previousStep, onContinue: _nextStep),
                    RegistrationStepThree(
                        onBack: _previousStep, onContinue: _nextStep),
                    RegistrationStepFour(
                        onBack: _previousStep, onContinue: _nextStep),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
