import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/db/db_key.dart';

void main() {
  late Directory dir;
  late File db;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('yelima_db_key_');
    db = File('${dir.path}/db.sqlite');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  List<String> files() =>
      dir.listSync().map((f) => f.uri.pathSegments.last).toList()..sort();

  test('uses the stored key and touches nothing', () async {
    db.writeAsStringSync('data');

    final key = await resolveDbKey(
        dbFile: db,
        read: () async => 'stored',
        write: (_) async => fail('no write'));

    expect(key, 'stored');
    expect(files(), ['db.sqlite']);
  });

  test('a brand-new install gets a new 64-hex-char key', () async {
    String? written;

    final key = await resolveDbKey(
        dbFile: db, read: () async => null, write: (k) async => written = k);

    expect(key, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(written, key);
  });

  test('CORE-EC-11: a failing key read changes nothing and is retried later',
      () async {
    db.writeAsStringSync('data');

    await expectLater(
        resolveDbKey(
            dbFile: db,
            read: () => throw Exception('keychain locked'),
            write: (_) async => fail('must not write a new key')),
        throwsException);

    expect(files(), ['db.sqlite']);
  });

  test(
      'CORE-EC-10: a lost key moves the old database aside instead of deleting it',
      () async {
    db.writeAsStringSync('data');
    File('${db.path}-wal').writeAsStringSync('wal');
    final reasons = <String>[];

    await resolveDbKey(
        dbFile: db,
        read: () async => null,
        write: (_) async {},
        onQuarantined: reasons.add);

    expect(db.existsSync(), isFalse);
    expect(files().every((f) => f.contains('.unreadable-')), isTrue);
    expect(files(), hasLength(2));
    expect(reasons, ['key_missing']);
  });

  test('quarantine keeps the file contents', () async {
    db.writeAsStringSync('precious');

    await quarantineDb(db, now: DateTime.fromMillisecondsSinceEpoch(42));

    expect(File('${db.path}.unreadable-42').readAsStringSync(), 'precious');
  });
}
