import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/router/router.dart';
import 'package:yelima/features/auth/presentation/controllers/auth_controller.dart';
import 'package:yelima/features/auth/presentation/controllers/auth_state.dart';
import 'package:yelima/features/user/presentation/controllers/user_state.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';

class FakeAuth extends AuthController {
  @override
  AuthState build() => const AuthState();

  void set(AuthState s) => state = s;
}

class FakeUser extends UserController {
  @override
  UserState build() => const UserState();

  void set(UserState s) => state = s;
}

void main() {
  late ProviderContainer c;
  var pings = 0;

  setUp(() {
    pings = 0;
    c = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(FakeAuth.new),
      userControllerProvider.overrideWith(FakeUser.new),
    ]);
    c.read(redirectRefreshProvider).addListener(() => pings++);
  });

  tearDown(() => c.dispose());

  FakeAuth auth() => c.read(authControllerProvider.notifier) as FakeAuth;
  FakeUser user() => c.read(userControllerProvider.notifier) as FakeUser;

  test('every auth update re-runs the redirect, even an equal one', () {
    final ready = c.read(authControllerProvider).copyWith(isInitialized: true);
    auth().set(ready);
    auth().set(ready.copyWith());

    expect(pings, 2);
  });

  test('a profile change re-runs the redirect; an unchanged one does not', () {
    user().set(const UserState(isInitialized: true));
    user().set(const UserState(isInitialized: true));

    expect(pings, 1);
  });
}
