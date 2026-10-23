import 'dart:io';
import 'dart:math';

/// Returns the database key, making one only when there is no database to lose.
///
/// A failing [read] (e.g. the iOS keychain locked before first unlock) is rethrown:
/// the open fails and is retried later, instead of a new key orphaning the data.
/// If the key is gone but [dbFile] exists, the file can never be read again, so it
/// is moved aside with [quarantineDb] and a fresh key is made.
Future<String> resolveDbKey({
  required File dbFile,
  required Future<String?> Function() read,
  required Future<void> Function(String key) write,
  void Function(String reason)? onQuarantined,
}) async {
  final existing = await read();
  if (existing != null) return existing;

  if (dbFile.existsSync()) {
    await quarantineDb(dbFile);
    onQuarantined?.call('key_missing');
  }
  final random = Random.secure();
  final key = List.generate(32, (_) => random.nextInt(256))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  await write(key);
  return key;
}

/// Moves a database that can't be read to `<name>.unreadable-<ms>` (with its -wal and -shm),
/// so nothing is deleted and support can still recover it.
Future<void> quarantineDb(File dbFile, {DateTime? now}) async {
  final suffix = 'unreadable-${(now ?? DateTime.now()).millisecondsSinceEpoch}';
  for (final ext in ['', '-wal', '-shm']) {
    final f = File('${dbFile.path}$ext');
    if (f.existsSync()) await f.rename('${dbFile.path}$ext.$suffix');
  }
}
