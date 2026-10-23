import 'route_paths.dart';

/// App state the redirect rules depend on.
typedef RedirectState = ({
  bool initialized,
  bool syncing,
  bool splashDone,
  bool onboarded,
  bool authenticated,
  bool registered,
  bool expired,
  bool profileUnavailable,
});

/// Decides where navigation should go for [uri]; null keeps the current route.
String? appRedirect(Uri uri, String location, RedirectState s) {
  final isAuthRoute = location == RoutePaths.signIn ||
      location == RoutePaths.signUp ||
      location == RoutePaths.forgotPassword;
  final isRegistrationRoute = location == RoutePaths.registration;
  final isSplashRoute = location == RoutePaths.splash;
  final isWelcomeRoute = location == RoutePaths.welcome;
  final isExpiredRoute = location == RoutePaths.sessionExpired;
  final isUnavailableRoute = location == RoutePaths.profileUnavailable;

  // The route the user originally wanted, carried through ?redirect=.
  final intendedPath = uri.queryParameters['redirect'] ??
      (isAuthRoute ||
              isRegistrationRoute ||
              isSplashRoute ||
              isWelcomeRoute ||
              isExpiredRoute ||
              isUnavailableRoute
          ? null
          : uri.toString());

  String withRedirect(String path) {
    if (intendedPath == null || intendedPath == '/') return path;
    return '$path?redirect=${Uri.encodeComponent(intendedPath)}';
  }

  if (!s.initialized || s.syncing || !s.splashDone) {
    if (isAuthRoute || isSplashRoute || isWelcomeRoute) return null;
    return withRedirect(RoutePaths.splash);
  }

  if (!s.onboarded) return isWelcomeRoute ? null : RoutePaths.welcome;

  if (!s.authenticated) {
    return isAuthRoute ? null : withRedirect(RoutePaths.signIn);
  }

  // Login expired: lock the app until the user signs in again or logs out.
  if (s.expired) return isExpiredRoute ? null : RoutePaths.sessionExpired;

  // Profile couldn't load: offer a retry rather than sending a registered user to registration.
  if (s.profileUnavailable) {
    return isUnavailableRoute ? null : RoutePaths.profileUnavailable;
  }

  if (!s.registered) {
    return isRegistrationRoute ? null : withRedirect(RoutePaths.registration);
  }

  if (isAuthRoute ||
      isRegistrationRoute ||
      isSplashRoute ||
      isExpiredRoute ||
      isUnavailableRoute) {
    return intendedPath ?? RoutePaths.home;
  }
  return null;
}
