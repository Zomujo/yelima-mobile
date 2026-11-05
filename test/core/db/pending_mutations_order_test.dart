import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  test('changes queued in the same second are sent in the order they were made',
      () async {
    final db = testDb();
    addTearDown(db.close);

    // Times are stored to the second, so these all tie on createdAt.
    await withClock(Clock.fixed(DateTime(2026, 11, 4, 10)), () async {
      for (var i = 0; i < 20; i++) {
        await db.pendingMutationsDao.queueMutation(
            entityId: 'm$i',
            entityType: 'medication',
            action: i == 0 ? 'create' : 'update',
            payload: const {});
      }
    });

    final queued = await db.pendingMutationsDao.getAllPendingMutations();
    expect([for (final m in queued) m.entityId],
        [for (var i = 0; i < 20; i++) 'm$i']);
  });
}
