import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/router/app_redirect.dart';

void main() {
  RedirectState stateWith({
    bool initialized = true,
    bool syncing = false,
    bool splashDone = true,
    bool onboarded = true,
    bool authenticated = true,
    bool registered = true,
    bool expired = false,
    bool profileUnavailable = false,
  }) =>
      (
        initialized: initialized,
        syncing: syncing,
        splashDone: splashDone,
        onboarded: onboarded,
        authenticated: authenticated,
        registered: registered,
        expired: expired,
        profileUnavailable: profileUnavailable,
      );

  final ready = stateWith();

  String? go(String location, RedirectState s) =>
      appRedirect(Uri.parse(location), Uri.parse(location).path, s);

  group('while starting up', () {
    for (final s in [
      stateWith(initialized: false),
      stateWith(syncing: true),
      stateWith(splashDone: false),
    ]) {
      test('holds a deep link on splash and remembers it ($s)', () {
        expect(go('/medications/abc', s),
            '/splash?redirect=${Uri.encodeComponent('/medications/abc')}');
      });
    }

    test('stays on splash, welcome and auth routes', () {
      for (final loc in [
        '/splash',
        '/welcome',
        '/sign-in',
        '/sign-up',
        '/forgot-password'
      ]) {
        expect(go(loc, stateWith(initialized: false)), isNull, reason: loc);
      }
    });
  });

  test('sends users who have not onboarded to welcome, without redirect', () {
    expect(go('/home', stateWith(onboarded: false, authenticated: false)),
        '/welcome');
    expect(go('/welcome', stateWith(onboarded: false)), isNull);
  });

  group('signed out', () {
    final s = stateWith(authenticated: false, registered: false);

    test('goes to sign-in and keeps the target', () {
      expect(go('/progress', s),
          '/sign-in?redirect=${Uri.encodeComponent('/progress')}');
    });

    test('leaves auth routes alone', () {
      expect(go('/sign-up', s), isNull);
      expect(go('/forgot-password', s), isNull);
    });

    test('carries an existing redirect through splash to sign-in', () {
      expect(go('/splash?redirect=%2Fprogress', s),
          '/sign-in?redirect=${Uri.encodeComponent('/progress')}');
    });
  });

  group('signed in but registration incomplete', () {
    final s = stateWith(registered: false);

    test('goes to registration', () {
      expect(go('/home', s),
          '/registration?redirect=${Uri.encodeComponent('/home')}');
    });

    test('stays on registration', () {
      expect(go('/registration', s), isNull);
    });
  });

  group('fully registered', () {
    test('leaves app routes alone', () {
      expect(go('/home', ready), isNull);
      expect(go('/medications/abc', ready), isNull);
    });

    test('moves off splash, auth and registration to home', () {
      for (final loc in ['/splash', '/sign-in', '/registration']) {
        expect(go(loc, ready), '/home', reason: loc);
      }
    });

    test('honours the remembered target', () {
      expect(go('/sign-in?redirect=%2Fprogress', ready), '/progress');
    });

    test('a root redirect is not carried', () {
      expect(go('/', stateWith(authenticated: false)), '/sign-in');
    });
  });

  group('session expired', () {
    final s = stateWith(expired: true);

    test('locks every app route behind the session-expired screen', () {
      for (final loc in [
        '/home',
        '/medications/abc',
        '/sign-in',
        '/registration'
      ]) {
        expect(go(loc, s), '/session-expired', reason: loc);
      }
      expect(go('/session-expired', s), isNull);
    });

    test('once signed in again, the lock screen moves on to home', () {
      expect(go('/session-expired', ready), '/home');
    });

    test('a signed-out user never sees the lock screen', () {
      expect(go('/home', stateWith(expired: true, authenticated: false)),
          '/sign-in?redirect=${Uri.encodeComponent('/home')}');
    });
  });

  group('ACC-EC-05: profile could not load', () {
    final s = stateWith(profileUnavailable: true, registered: false);

    test('a registered user is not sent to registration while offline', () {
      expect(go('/home', s), '/profile-unavailable');
      expect(go('/registration', s), '/profile-unavailable');
      expect(go('/profile-unavailable', s), isNull);
    });

    test('once loaded, the retry screen moves on', () {
      expect(go('/profile-unavailable', ready), '/home');
    });
  });
}
