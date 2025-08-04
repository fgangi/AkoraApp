// lib/data/sources/local/app_database.dart

import 'dart:io';

import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// This will generate a file named 'app_database.g.dart'.
// VS Code will show an error on this line until you run the build_runner command.
part 'app_database.g.dart';

// --- TABLE DEFINITION ---
// We name the Dart class `Therapies` (plural) and the generated data class `Therapy` (singular).
@DataClassName('Therapy')
class Therapies extends Table {
  // --- Columns ---
  // Primary Key: An integer that automatically increments.
  IntColumn get id => integer().autoIncrement()();

  // Drug Info
  TextColumn get drugName => text()();
  TextColumn get drugDosage => text()();

  // Frequency & Time
  TextColumn get takingFrequency => text().map(const TakingFrequencyConverter())();
  IntColumn get reminderHour => integer()();
  IntColumn get reminderMinute => integer()();
  BoolColumn get repeatAfter10Min => boolean()();
  
  // Duration
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();

  // Extra Reminders
  IntColumn get doseThreshold => integer()();
  DateTimeColumn get expiryDate => dateTime().nullable()(); // This column can be empty (null).
  TextColumn get notificationSound => text().map(const NotificationSoundConverter())();

  // Therapy State (for features like pausing or deleting)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();
}

// --- ENUM CONVERTERS ---
// SQLite doesn't have an ENUM type, so we tell Drift how to store our Dart enums as simple text.
class TakingFrequencyConverter extends TypeConverter<TakingFrequency, String> {
  const TakingFrequencyConverter();
  @override
  TakingFrequency fromSql(String fromDb) => TakingFrequency.values.byName(fromDb);
  @override
  String toSql(TakingFrequency value) => value.name;
}

class NotificationSoundConverter extends TypeConverter<NotificationSound, String> {
  const NotificationSoundConverter();
  @override
  NotificationSound fromSql(String fromDb) => NotificationSound.values.byName(fromDb);
  @override
  String toSql(NotificationSound value) => value.name;
}


// --- DATABASE CLASS ---
// This annotation tells Drift to generate the necessary code for the 'Therapies' table.
@DriftDatabase(tables: [Therapies])
class AppDatabase extends _$AppDatabase {
  // Constructor. We pass the database connection to the superclass.
  AppDatabase() : super(_openConnection());

  // You must bump this number whenever you change the table structure (e.g., add a column).
  @override
  int get schemaVersion => 1;

  // --- DATABASE METHODS (Data Access Object - DAO) ---
  
  /// Creates a new therapy entry in the database.
  Future<int> createTherapy(TherapiesCompanion entry) {
    return into(therapies).insert(entry);
  }

  /// Watches all active therapies in the database.
  /// Returns a Stream, which means your UI can automatically update
  /// whenever the therapy data changes.
  Stream<List<Therapy>> watchAllActiveTherapies() {
    return (select(therapies)
          ..where((t) => t.isActive.equals(true) & t.isPaused.equals(false))
          ..orderBy([
            (t) => OrderingTerm(expression: t.reminderHour),
            (t) => OrderingTerm(expression: t.reminderMinute),
          ]))
        .watch();
  }
  
  /// Updates an existing therapy entry in the database.
  /// Drift's 'replace' method will update all fields of the row
  /// that matches the primary key of the provided 'Therapy' object.
  Future<void> updateTherapy(Therapy entry) {
    return update(therapies).replace(entry);
  }

  /// Deletes a therapy from the database by its ID.
  Future<void> deleteTherapy(int id) {
    return (delete(therapies)..where((t) => t.id.equals(id))).go();
  }

  /// Gets a single therapy by its ID. Useful for the edit screen.
  Future<Therapy> getTherapyById(int id) {
    return (select(therapies)..where((t) => t.id.equals(id))).getSingle();
  }
}

// This private function is responsible for finding the correct location
// for the database file on the device and opening the connection.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'akora_db.sqlite'));
    return NativeDatabase(file);
  });
}