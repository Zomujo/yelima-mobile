import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:yelima/core/services/connectivity_service.dart';

void main() {
  var online = true, probes = 0;
  late StreamController<Object?> network;
  late ConnectivityService service;

  setUp(() {
    online = true;
    probes = 0;
    network = StreamController<Object?>.broadcast();
    service = ConnectivityService(
      networkChanges: network.stream,
      check: (option) async {
        probes++;
        await Future<void>.delayed(Duration.zero);
        return InternetCheckResult(option: option, isSuccess: online);
      },
    );
  });

  tearDown(() => network.close());

  // Each check asks both probe servers at once.
  int checks() => probes ~/ 2;

  test('online only when a request gets through', () async {
    online = false;
    expect(await service.isConnected, isFalse);
    online = true;
    network.add('wifi'); // back online: the retry must not reuse "offline"
    await Future<void>.delayed(Duration.zero);
    expect(await service.isConnected, isTrue);
  });

  test('callers at the same moment share one check', () async {
    await Future.wait([for (var i = 0; i < 5; i++) service.isConnected]);
    expect(checks(), 1);
  });

  test('an answer is reused briefly, then checked again', () async {
    var now = DateTime(2026, 11, 4, 10);
    await withClock(Clock(() => now), () async {
      online = false;
      await service.isConnected;
      online = true;
      expect(await service.isConnected, isFalse);
      expect(checks(), 1);

      now = now.add(ConnectivityService.fresh);
      expect(await service.isConnected, isTrue);
      expect(checks(), 2);
    });
  });

  test('a network change or coming back on screen checks again', () async {
    await service.isConnected;
    network.add('wifi');
    await Future<void>.delayed(Duration.zero);
    await service.isConnected;
    expect(checks(), 2);

    service.resume();
    await service.isConnected;
    expect(checks(), 3);
  });

  test("a check from before a network change isn't reused or remembered",
      () async {
    final slow = Completer<bool>();
    var first = true;
    service = ConnectivityService(
      networkChanges: network.stream,
      check: (option) async {
        probes++;
        final ok = first ? await slow.future : online;
        return InternetCheckResult(option: option, isSuccess: ok);
      },
    );
    final old = service.isConnected; // starts on the old network
    network.add('wifi');
    await Future<void>.delayed(Duration.zero);
    first = false;

    expect(await service.isConnected, isTrue); // a new check, not the old one
    slow.complete(false);
    expect(await old, isFalse);
    expect(service.lastKnownOnline, isTrue); // the old answer is dropped
  });

  test('the stream says each change once, starting with the current state',
      () async {
    online = false;
    final seen = <bool>[];
    final sub = service.onConnectivityChanged.listen(seen.add);
    await pumpEventQueue();
    expect(service.lastKnownOnline, isFalse);

    online = true;
    network.add('wifi');
    await pumpEventQueue();
    network.add('wifi'); // no change: nothing new
    await pumpEventQueue();
    expect(seen, [false, true]);
    await sub.cancel();

    final late = await service.onConnectivityChanged.first;
    expect(late, isTrue); // a new listener hears the current state
  });

  test('offline it checks every 2 s, online every 10 s', () {
    fakeAsync((time) {
      // Built inside fake time, so its timers are fake too.
      final service = ConnectivityService(
        networkChanges: network.stream,
        check: (option) async {
          probes++;
          return InternetCheckResult(option: option, isSuccess: online);
        },
      );
      online = false;
      final sub = service.onConnectivityChanged.listen((_) {});
      time.flushMicrotasks();
      expect(checks(), 1);

      time.elapse(ConnectivityService.offlineEvery);
      expect(checks(), 2);

      online = true; // back, with no word from the phone
      time.elapse(ConnectivityService.offlineEvery);
      expect(service.lastKnownOnline, isTrue);
      expect(checks(), 3);

      time.elapse(ConnectivityService.offlineEvery);
      expect(checks(), 3); // online now: the next check is 10 s away
      time.elapse(ConnectivityService.onlineEvery);
      expect(checks(), 4);
      sub.cancel();
    });
  });

  test(
      'a reply from our server means online at once, whatever a slow check says',
      () async {
    final slow = Completer<bool>();
    service = ConnectivityService(
      networkChanges: network.stream,
      check: (option) async {
        probes++;
        return InternetCheckResult(
            option: option, isSuccess: await slow.future);
      },
    );
    final seen = <bool>[];
    final sub = service.onConnectivityChanged.listen(seen.add);
    await pumpEventQueue(); // a check is running and hangs

    service.sawReply();
    slow.complete(false);
    await pumpEventQueue();
    expect(seen, [true]);
    expect(await service.isConnected, isTrue);
    await sub.cancel();
  });

  test('a failed request checks again only if we thought we were online',
      () async {
    await service.isConnected;
    final sub = service.onConnectivityChanged.listen((_) {});
    await pumpEventQueue();
    final before = checks();

    service.sawNetworkError();
    await pumpEventQueue();
    expect(checks(), before + 1);

    online = false;
    service.sawNetworkError();
    await pumpEventQueue();
    service.sawNetworkError(); // already offline: no extra checks
    await pumpEventQueue();
    expect(checks(), before + 2);
    await sub.cancel();
  });
}
