import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/user/domain/entities/user_entity.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/user/presentation/controllers/user_controller.dart';
import '../../shared/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/ai_chat_screen.dart';
import '../../features/reading_logging/presentation/screens/reading_logging_screen.dart';
import '../../features/appointment/presentation/screens/appointments_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/registration_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/health_conditions/presentation/screens/health_profile_screen.dart';
import '../../features/medications/presentation/screens/medications_screen.dart';
import '../../features/medications/presentation/screens/add_medication_screen.dart';
import '../../features/medications/presentation/screens/medicine_details_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../shared/screens/not_found_screen.dart';
import '../../shared/screens/main_scaffold.dart';
import 'route_paths.dart';
import '../services/monitoring_service.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter createRouter(AuthController authController, UserController userController) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RoutePaths.splash,
      refreshListenable: Listenable.merge([authController, userController]),
      observers: [MonitoringService.instance.analyticsObserver],
      redirect: (context, state) {
        final isInitialized = authController.isInitialized && userController.isInitialized;
        final isAuthenticated = authController.isAuthenticated;
        final isSyncInProgress = authController.isInitialSyncInProgress;

        final isRegistrationComplete =
            userController.userEntity?.registrationStatus ==
                RegistrationStatus.complete;

        final isAuthRoute = state.matchedLocation == RoutePaths.signIn ||
            state.matchedLocation == RoutePaths.signUp ||
            state.matchedLocation == RoutePaths.forgotPassword;
        final isRegistrationRoute =
            state.matchedLocation == RoutePaths.registration;
        final isSplashRoute = state.matchedLocation == RoutePaths.splash;

        // ── Still initializing or syncing profile → hold navigation ──
        // If we're on an auth route (sign-in/up), the GlobalAsyncLoader overlay
        // is covering the screen — return null to stay put. Redirecting to splash
        // here causes it to render BEHIND the semi-transparent loader overlay,
        // which the user can see. Only send to splash if we're somewhere else.
        if (!isInitialized || isSyncInProgress) {
          if (isAuthRoute || isSplashRoute) return null;
          return RoutePaths.splash;
        }

        // If we are on the splash screen and initialization is done,
        // we stay on splash and let the SplashScreen widget itself trigger
        // the navigation after its animations complete.
        if (isSplashRoute) {
          return null;
        }

        if (!isAuthenticated) {
          return isAuthRoute ? null : RoutePaths.signIn;
        }

        // Authenticated users
        if (!isRegistrationComplete) {
          return isRegistrationRoute ? null : RoutePaths.registration;
        }

        // Fully registered users shouldn't see auth or registration routes
        if (isAuthRoute || isRegistrationRoute) {
          return RoutePaths.home;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: RoutePaths.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RoutePaths.signIn,
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: RoutePaths.signUp,
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: RoutePaths.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: RoutePaths.registration,
          builder: (context, state) => const RegistrationScreen(),
        ),
        GoRoute(
          path: RoutePaths.medications,
          builder: (context, state) => const MedicationsScreen(),
        ),
        GoRoute(
          path: RoutePaths.addMedication,
          builder: (context, state) => const AddMedicationScreen(),
        ),
        GoRoute(
          path: RoutePaths.medicineDetails,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return MedicineDetailsScreen(medicationId: id);
          },
        ),
        GoRoute(
          path: RoutePaths.progress,
          builder: (context, state) => const ProgressScreen(),
        ),
        GoRoute(
          path: RoutePaths.aiChat,
          builder: (context, state) => const AiChatScreen(),
        ),
        GoRoute(
          path: RoutePaths.editProfile,
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: RoutePaths.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: RoutePaths.healthProfile,
          builder: (context, state) => const HealthProfileScreen(),
        ),
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          pageBuilder: (context, state, child) => NoTransitionPage(
            child: MainScaffold(child: child),
          ),
          routes: [
            GoRoute(
              path: RoutePaths.home,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
            GoRoute(
              path: RoutePaths.chat,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ChatScreen(),
              ),
            ),
            GoRoute(
              path: RoutePaths.readingLogging,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ReadingLoggingScreen(),
              ),
            ),
            GoRoute(
              path: RoutePaths.appointments,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AppointmentsScreen(),
              ),
            ),
            GoRoute(
              path: RoutePaths.profile,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }
}

// Helper for standardized page transitions
Page<T> buildPageWithTransition<T>({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
