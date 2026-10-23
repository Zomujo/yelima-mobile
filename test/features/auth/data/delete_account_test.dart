import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/auth/data/datasources/auth_remote_data_source.dart';

import '../../../helpers/fake_api.dart';

class MockAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserInfo extends Mock implements UserInfo {}

class MockGoogle extends Mock implements GoogleSignIn {}

class FakeCredential extends Fake implements AuthCredential {}

class MockCredentialResult extends Mock implements UserCredential {}

void main() {
  const cleanPath = 'api/v1/client/clean';
  late FakeApi api;
  late MockUser user;
  late AuthRemoteDataSource source;
  late List<String> steps;

  setUpAll(() => registerFallbackValue(FakeCredential()));

  setUp(() {
    steps = [];
    api = FakeApi();
    user = MockUser();
    final info = MockUserInfo();
    when(() => info.providerId).thenReturn('password');
    when(() => user.providerData).thenReturn([info]);
    when(() => user.email).thenReturn('ama@example.com');
    when(() => user.uid).thenReturn('uid-1');
    when(() => user.reauthenticateWithCredential(any())).thenAnswer((_) async {
      steps.add('reauth');
      return MockCredentialResult();
    });
    when(() => user.delete()).thenAnswer((_) async => steps.add('deleteLogin'));
    final auth = MockAuth();
    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.signOut()).thenAnswer((_) async => steps.add('signOut'));
    final google = MockGoogle();
    when(() => google.isSignedIn()).thenAnswer((_) async => false);
    source = AuthRemoteDataSource(
      firebaseAuth: auth,
      apiClient: api.client,
      googleSignIn: google,
    );
  });

  test(
      'ACC-EC-06/07: confirms identity, the server deletes everything, then it signs out',
      () async {
    api.onRequest('DELETE', cleanPath, (_) {
      steps.add('deleteServerData');
      return FakeReply.ok(null);
    });

    await source.deleteAccount(password: 'pw');

    expect(steps, ['reauth', 'deleteServerData', 'signOut']);
    verifyNever(() => user.delete());
  });

  test('if the server delete fails, the user stays signed in to retry',
      () async {
    api.on('DELETE', cleanPath, FakeReply.error(500));

    await expectLater(source.deleteAccount(password: 'pw'), throwsException);

    expect(steps, ['reauth']);
  });

  test('a wrong password stops before anything is deleted', () async {
    when(() => user.reauthenticateWithCredential(any()))
        .thenThrow(FirebaseAuthException(code: 'wrong-password'));

    await expectLater(source.deleteAccount(password: 'bad'),
        throwsA(isA<FirebaseAuthException>()));

    expect(api.requests, isEmpty);
    expect(steps, isEmpty);
  });
}
