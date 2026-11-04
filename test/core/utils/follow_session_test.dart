import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/core_providers.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/core/utils/follow_session.dart';

final _ended = StateProvider<int>((ref) => 0);

final _screen = Provider.autoDispose<void>((ref) {
  followSession(ref, onEnd: () => ref.read(_ended.notifier).state++);
});

void main() {
  late SessionLifecycleService service;
  late ProviderContainer c;

  setUp(() {
    service = SessionLifecycleService();
    c = ProviderContainer(
        overrides: [sessionLifecycleProvider.overrideWithValue(service)]);
  });

  tearDown(() => c.dispose());

  test('a live provider gets session events', () async {
    final sub = c.listen(_screen, (_, __) {});
    await service.startSession('u');
    await service.endSession();

    expect(c.read(_ended), 1);
    sub.close();
  });

  test('a disposed provider no longer gets them', () async {
    c.listen(_screen, (_, __) {}).close();
    await Future<void>.delayed(Duration.zero); // let auto-dispose run

    await service.startSession('u');
    await service.endSession();

    expect(c.read(_ended), 0);
  });
}
