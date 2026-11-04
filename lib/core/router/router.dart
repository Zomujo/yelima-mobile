import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/user/domain/entities/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/user/user_providers.dart';
import '../core_providers.dart';
import '../../shared/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/ai_chat_screen.dart';
import 'package:yelima/features/vitals/presentation/screens/reading_logging_screen.dart';
import '../../features/appointment/presentation/screens/appointments_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:yelima/features/user/presentation/screens/registration_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/health_conditions/presentation/screens/health_profile_screen.dart';
import '../../features/symptoms/presentation/screens/all_symptoms_screen.dart';
import '../../features/medications/presentation/screens/medications_screen.dart';
import '../../features/medications/presentation/screens/add_medication_screen.dart';
import '../../features/medications/presentation/screens/medicine_details_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../shared/screens/not_found_screen.dart';
import 'package:yelima/features/home/presentation/screens/main_scaffold.dart';
import '../config/features.dart';
import 'route_paths.dart';
import '../../shared/screens/unsynced_changes_screen.dart';
import '../../features/auth/presentation/screens/session_expired_screen.dart';
import '../../features/user/presentation/screens/profile_unavailable_screen.dart';
import 'app_redirect.dart';
import '../services/monitoring_service.dart';

part 'router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Sends links and pushes for the hidden AI chat to home.
String? _whileChatHidden(BuildContext context, GoRouterState state) =>
    Features.aiChat ? null : RoutePaths.home;

final shellNavigatorKey = GlobalKey<NavigatorState>();

class _Ping extends ChangeNotifier {
  void call() => notifyListeners();
}

/// Fires on every login or profile change, so the redirect rules run again.
@Riverpod(keepAlive: true)
Listenable redirectRefresh(Ref ref) {
  final ping = _Ping();
  ref
    ..listen(authControllerProvider, (_, __) => ping())
    ..listen(userControllerProvider, (_, __) => ping());
  return ping;
}

/// The app's routes and redirect rules.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = ref.watch(redirectRefreshProvider);
  final startup = ref.watch(appStartupProvider);
  final expiry = ref.watch(sessionExpiryProvider);
  final prefs = ref.watch(sharedPrefsServiceProvider);
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    refreshListenable: Listenable.merge([refresh, startup, expiry]),
    observers: [MonitoringService.instance.analyticsObserver],
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final user = ref.read(userControllerProvider);
      return appRedirect(state.uri, state.matchedLocation, (
        initialized: auth.isInitialized && user.isInitialized,
        syncing: auth.isInitialSyncInProgress,
        splashDone: startup.isAnimationComplete,
        onboarded: prefs.hasCompletedOnboarding(),
        authenticated: auth.isAuthenticated,
        registered:
            user.userEntity?.registrationStatus == RegistrationStatus.complete,
        expired: expiry.isExpired,
        profileUnavailable: user.profileUnavailable,
      ));
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => RoutePaths.home,
      ),
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.signIn,
        builder: (context, state) => const AuthScreen(isSignUp: false),
      ),
      GoRoute(
        path: RoutePaths.signUp,
        builder: (context, state) => const AuthScreen(isSignUp: true),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.unsyncedChanges,
        builder: (context, state) =>
            UnsyncedChangesScreen(sync: ref.read(mutationSyncManagerProvider)),
      ),
      GoRoute(
        path: RoutePaths.profileUnavailable,
        builder: (context, state) => const ProfileUnavailableScreen(),
      ),
      GoRoute(
        path: RoutePaths.sessionExpired,
        builder: (context, state) => const SessionExpiredScreen(),
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
        redirect: _whileChatHidden,
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
      GoRoute(
        path: RoutePaths.symptoms,
        builder: (context, state) => const AllSymptomsScreen(),
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
            redirect: _whileChatHidden,
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
  ref.onDispose(router.dispose);
  return router;
}
