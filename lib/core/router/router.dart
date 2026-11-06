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
import '../theme/app_motion.dart';
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

/// A full-screen route showing [screen].
GoRoute _page(String path, Widget screen, {GoRouterRedirect? redirect}) =>
    GoRoute(path: path, redirect: redirect, builder: (_, __) => screen);

/// A form opened like a sheet: it slides up instead of in from the side.
GoRoute _sheet(String path, Widget screen) => GoRoute(
    path: path,
    pageBuilder: (_, state) => MaterialPage(
        key: state.pageKey, fullscreenDialog: true, child: screen));

/// A bottom-bar tab: a quick cross-fade, no sliding.
GoRoute _tab(String path, Widget screen, {GoRouterRedirect? redirect}) =>
    GoRoute(
      path: path,
      redirect: redirect,
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: screen,
        transitionDuration: AppMotion.quick,
        reverseTransitionDuration: AppMotion.quick,
        transitionsBuilder: (context, animation, _, child) =>
            AppMotion.reduced(context)
                ? child
                : FadeTransition(
                    opacity: CurvedAnimation(
                        parent: animation, curve: AppMotion.enter),
                    child: child),
      ),
    );

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
      GoRoute(path: '/', redirect: (_, __) => RoutePaths.home),
      _page(RoutePaths.splash, const SplashScreen()),
      _page(RoutePaths.welcome, const WelcomeScreen()),
      _page(RoutePaths.signIn, const AuthScreen(isSignUp: false)),
      _page(RoutePaths.signUp, const AuthScreen(isSignUp: true)),
      _page(RoutePaths.forgotPassword, const ForgotPasswordScreen()),
      GoRoute(
        path: RoutePaths.unsyncedChanges,
        builder: (_, __) =>
            UnsyncedChangesScreen(sync: ref.read(mutationSyncManagerProvider)),
      ),
      _page(RoutePaths.profileUnavailable, const ProfileUnavailableScreen()),
      _page(RoutePaths.sessionExpired, const SessionExpiredScreen()),
      _page(RoutePaths.registration, const RegistrationScreen()),
      _page(RoutePaths.medications, const MedicationsScreen()),
      _sheet(RoutePaths.addMedication, const AddMedicationScreen()),
      GoRoute(
        path: RoutePaths.medicineDetails,
        builder: (_, state) =>
            MedicineDetailsScreen(medicationId: state.pathParameters['id']!),
      ),
      _page(RoutePaths.progress, const ProgressScreen()),
      _page(RoutePaths.aiChat, const AiChatScreen(),
          redirect: _whileChatHidden),
      _sheet(RoutePaths.editProfile, const EditProfileScreen()),
      _page(RoutePaths.settings, const SettingsScreen()),
      _page(RoutePaths.healthProfile, const HealthProfileScreen()),
      _page(RoutePaths.symptoms, const AllSymptomsScreen()),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        pageBuilder: (_, __, child) =>
            NoTransitionPage(child: MainScaffold(child: child)),
        routes: [
          _tab(RoutePaths.home, const HomeScreen()),
          _tab(RoutePaths.chat, const ChatScreen(), redirect: _whileChatHidden),
          _tab(RoutePaths.readingLogging, const ReadingLoggingScreen()),
          _tab(RoutePaths.appointments, const AppointmentsScreen()),
          _tab(RoutePaths.profile, const ProfileScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
  ref.onDispose(router.dispose);
  return router;
}
