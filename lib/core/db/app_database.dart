import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:ffi';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;

import 'tables/vital_histories.dart';
import 'tables/ai_chat_conversations.dart';
import 'tables/pending_deletions.dart';
import 'tables/user_profiles.dart';
import 'tables/pending_mutations.dart';
import 'tables/appointments.dart';
import 'tables/medications.dart';
import 'tables/preloaded_medications.dart';
import 'daos/vitals_dao.dart';
import 'daos/ai_chat_dao.dart';
import 'daos/user_profiles_dao.dart';
import 'daos/pending_mutations_dao.dart';
import 'daos/appointments_dao.dart';
import 'daos/medications_dao.dart';
import 'tables/adherence_globals.dart';
import 'tables/adherence_global_days.dart';
import 'tables/medication_logs.dart';
import 'tables/audio_cache.dart';
import 'daos/adherence_dao.dart';
import 'daos/audio_cache_dao.dart';
import 'tables/symptoms.dart';
import 'daos/symptoms_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  VitalHistories,
  AiChatConversations,
  PendingDeletions,
  UserProfiles,
  PendingMutations,
  Appointments,
  Medications,
  PreloadedMedications,
  AdherenceGlobals,
  AdherenceGlobalDays,
  MedicationLogs,
  AudioCache,
  Symptoms
], daos: [
  VitalsDao,
  AiChatDao,
  UserProfilesDao,
  PendingMutationsDao,
  AppointmentsDao,
  MedicationsDao,
  AdherenceDao,
  AudioCacheDao,
  SymptomsDao
])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 18;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(aiChatConversations);
        }
        if (from < 3) {
          await m.addColumn(vitalHistories, vitalHistories.recordedAt);
          await m.createTable(pendingDeletions);
        }
        if (from < 4) {
          // Schema 4 changes
        }
        if (from < 5) {
          // Add table
          await m.createTable(userProfiles);
        }
        if (from < 6) {
          // Add createdAt column to UserProfiles table
          await m.addColumn(userProfiles, userProfiles.createdAt);
        }
        if (from < 7) {
          await m.createTable(pendingMutations);
        }
        if (from < 8) {
          // Medications table removed
        }
        if (from < 9) {
          await m.createTable(appointments);
        }
        if (from < 10) {
          try {
            await m.addColumn(pendingMutations, pendingMutations.retryCount);
          } catch (e) {
            debugPrint(
                'Migration to 10: Column retry_count might already exist. Exception: $e');
          }
        }
        if (from < 11) {
          await m.createTable(medications);
          await m.createTable(preloadedMedications);
        }
        if (from < 12) {
          // Destructive migration for medications to change primary key
          await customStatement('DROP TABLE IF EXISTS medications;');
          await m.createTable(medications);
        }
        if (from < 13) {
          await m.createTable(adherenceGlobals);
          await m.createTable(adherenceGlobalDays);
          await m.createTable(medicationLogs);
        }
        if (from < 14) {
          await m.createTable(audioCache);
        }
        if (from < 15) {
          await m.addColumn(vitalHistories, vitalHistories.vitalSubType);
        }
        if (from < 16) {
          await m.addColumn(userProfiles, userProfiles.completedTutorialsJson);
        }
        if (from < 17) {
          await m.createTable(symptoms);
        }
        if (from < 18) {
          await m.addColumn(userProfiles, userProfiles.facilityId);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    // Setup encryption key
    const secureStorage = FlutterSecureStorage();
    const keyString = "db_encryption_key";
    String? encryptionKey = await secureStorage.read(key: keyString);
    if (encryptionKey == null) {
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      encryptionKey =
          values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await secureStorage.write(key: keyString, value: encryptionKey);
    }

    return NativeDatabase.createInBackground(
      file,
      isolateSetup: () async {
        if (Platform.isAndroid) {
          open.overrideFor(OperatingSystem.android, () {
            return DynamicLibrary.open('libsqlcipher.so');
          });
        }
      },
      setup: (db) {
        db.execute("PRAGMA key = '$encryptionKey';");
      },
    );
  });
}
