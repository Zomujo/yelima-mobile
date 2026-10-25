import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/services/recent_fetches.dart';

void main() {
  final start = DateTime(2026, 10, 24, 9);

  test('a download stays fresh for one minute, then counts as stale', () {
    final recent = RecentFetches();
    withClock(Clock.fixed(start), () => recent.markFetched('appointments'));

    expect(
        withClock(Clock.fixed(start.add(const Duration(seconds: 59))),
            () => recent.isFresh('appointments')),
        isTrue);
    expect(
        withClock(Clock.fixed(start.add(const Duration(minutes: 1))),
            () => recent.isFresh('appointments')),
        isFalse);
  });

  test('the saved answer comes back only while fresh', () {
    final recent = RecentFetches()..markFetched('page', 'rows');

    expect(recent.valueOf<String>('page'), 'rows');
    recent.clear();
    expect(recent.valueOf<String>('page'), isNull);
  });

  test('the connection coming back or a synced change makes everything stale',
      () async {
    final online = StreamController<bool>();
    final synced = StreamController<String>();
    final recent =
        RecentFetches(connectivity: online.stream, synced: synced.stream);

    recent.markFetched('vitals');
    online.add(true); // the start-up "online" signal is not a reconnect
    await pumpEventQueue();
    expect(recent.isFresh('vitals'), isTrue);
    online.add(false);
    await pumpEventQueue();
    expect(recent.isFresh('vitals'), isTrue);

    online.add(true);
    await pumpEventQueue();
    expect(recent.isFresh('vitals'), isFalse);

    recent.markFetched('vitals');
    synced.add('vital_history');
    await pumpEventQueue();
    expect(recent.isFresh('vitals'), isFalse);
    await recent.dispose();
  });

  test('two screens asking at the same moment share one download', () async {
    final recent = RecentFetches();
    var downloads = 0;
    final gate = Completer<String>();
    Future<String> download() {
      downloads++;
      return gate.future;
    }

    final first = recent.share('readings', download);
    final second = recent.share('readings', download);
    gate.complete('rows');

    expect(await first, 'rows');
    expect(await second, 'rows');
    expect(downloads, 1);
    // Once finished, the next ask starts a new download.
    await recent.share('readings', () async => downloads++);
    expect(downloads, 2);
  });

  test('sign-in and sign-out start from nothing fresh', () async {
    final recent = RecentFetches()..markFetched('medications');

    await recent.onSessionEnded();

    expect(recent.isFresh('medications'), isFalse);
  });
}
