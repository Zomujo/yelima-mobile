import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/auth/data/datasources/auth_remote_data_source.dart';

import '../../../helpers/fake_api.dart';

class MockAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserInfo extends Mock implements UserInfo {}

class MockFirestore extends Mock implements FirebaseFirestore {}

// Firestore's references are sealed; mocking them is the usual way to test without a backend.
// ignore: subtype_of_sealed_class
class MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDoc extends Mock implements DocumentReference<Map<String, dynamic>> {}

class MockGoogle extends Mock implements GoogleSignIn {}

class FakeCredential extends Fake implements AuthCredential {}

class MockCredentialResult extends Mock implements UserCredential {}

void main() {
  const cleanPath = 'api/v1/client/clean';
  late FakeApi api;
  late MockUser user;
  late MockDoc doc;
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
    doc = MockDoc();
    when(() => doc.delete())
        .thenAnswer((_) async => steps.add('deleteProfile'));
    final users = MockCollection();
    when(() => users.doc('uid-1')).thenReturn(doc);
    final firestore = MockFirestore();
    when(() => firestore.collection('users')).thenReturn(users);
    final google = MockGoogle();
    when(() => google.isSignedIn()).thenAnswer((_) async => false);
    source = AuthRemoteDataSource(
      firebaseAuth: auth,
      apiClient: api.client,
      googleSignIn: google,
      firestore: firestore,
    );
  });

  test(
      'ACC-EC-06/07: confirms identity, deletes server data, then the profile, then the login',
      () async {
    api.onRequest('DELETE', cleanPath, (_) {
      steps.add('deleteServerData');
      return FakeReply.ok(null);
    });

    await source.deleteAccount(password: 'pw');

    expect(
        steps, ['reauth', 'deleteServerData', 'deleteProfile', 'deleteLogin']);
  });

  test('if the server delete fails, the profile and login are kept for a retry',
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
