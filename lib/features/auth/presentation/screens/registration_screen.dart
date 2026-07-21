import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_paths.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../controllers/auth_controller.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../widgets/registration_app_bar.dart';
import '../widgets/steps/registration_step_one.dart';
import '../widgets/steps/registration_step_two.dart';
import '../widgets/steps/registration_step_three.dart';

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

    /// Clamp initial page to 0-2 range to prevent out-of-bounds error.
    final initialPage = status.index.clamp(0, 2);
    _currentPage = ValueNotifier<int>(initialPage);
    _pageController = PageController(initialPage: initialPage);
  }

  void _nextStep() {
    final page = (_pageController.page ?? 0).toInt();

    if (page < 2) {
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
    final authController = context.read<AuthController>();
    context.go(RoutePaths.signUp); // clear deep link intent before sign out
    await authController.signOut(context);
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
      backgroundColor: const Color(0xFFFAF9F6), // Off-white
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _currentPage,
              builder: (context, currentPage, _) {
                return RegistrationAppBar(
                  currentStep: currentPage + 1,
                  totalSteps: 3,
                  onClose: () async {
                    final authController = context.read<AuthController>();
                    context.go(RoutePaths
                        .signUp); // clear deep link intent before sign out
                    await authController.signOut(context);
                  },
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
