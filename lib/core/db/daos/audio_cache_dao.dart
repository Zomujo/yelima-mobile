import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/audio_cache.dart';

part 'audio_cache_dao.g.dart';

@DriftAccessor(tables: [AudioCache])
class AudioCacheDao extends DatabaseAccessor<AppDatabase>
    with _$AudioCacheDaoMixin {
  AudioCacheDao(super.db);

  Future<void> savePath(String id, String filename) {
    return into(audioCache).insertOnConflictUpdate(
      AudioCacheCompanion(
        id: Value(id),
        filename: Value(filename),
      ),
    );
  }

  Future<String?> getPath(String id) async {
    final record = await (select(audioCache)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return record?.filename;
  }

  Future<void> removePath(String id) {
    return (delete(audioCache)..where((t) => t.id.equals(id))).go();
  }

  Future<List<String>> getAllFilenames() async {
    final records = await select(audioCache).get();
    return records.map((r) => r.filename).toList();
  }

  Future<void> clearCache() {
    return delete(audioCache).go();
  }
}
