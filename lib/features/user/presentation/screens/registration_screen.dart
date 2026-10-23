import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:yelima/core/router/route_paths.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';
import 'package:yelima/features/user/presentation/widgets/registration/registration_app_bar.dart';
import 'package:yelima/features/user/presentation/widgets/registration/registration_step_one.dart';
import 'package:yelima/features/user/presentation/widgets/registration/registration_step_two.dart';
import 'package:yelima/features/user/presentation/widgets/registration/registration_step_three.dart';
import 'package:yelima/features/user/presentation/widgets/registration/registration_step_four.dart';
import 'package:yelima/features/auth/presentation/widgets/logout_flow.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentPage;

  @override
  void initState() {
    super.initState();

    final userController = context.read<UserController>();
    final status = userController.userEntity?.registrationStatus ??
        RegistrationStatus.personalDetails;

    /// Clamp initial page to 0-3 range to prevent out-of-bounds error.
    final initialPage = status.index.clamp(0, 3);
    _currentPage = ValueNotifier<int>(initialPage);
    _pageController = PageController(initialPage: initialPage);
  }

  void _nextStep() {
    final page = (_pageController.page ?? 0).toInt();

    if (page < 3) {
      _pageController.nextPage(
        curve: Curves.easeOutExpo,
        duration: const Duration(milliseconds: 300),
      );
      _currentPage.value = page + 1;
      return;
    }

    /// Done with registration.
    context.go(RoutePaths.home);
  }

  void _previousStep() async {
    final page = (_pageController.page ?? 0).toInt();

    if (page > 0) {
      _pageController.previousPage(
        curve: Curves.easeOutExpo,
        duration: const Duration(milliseconds: 300),
      );
      _currentPage.value = page - 1;
      return;
    }

    /// Sign out and return to sign up if on the first step.
    await logOutWithSyncCheck(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _currentPage,
              builder: (context, currentPage, _) {
                return RegistrationAppBar(
                  currentStep: currentPage + 1,
                  totalSteps: 4,
                  onClose: () => logOutWithSyncCheck(context),
                );
              },
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
    );
  }
}
