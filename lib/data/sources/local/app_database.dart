// coverage:ignore-file
import 'dart:convert';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DataClassName('Therapy')
class Therapies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get drugName => text()();
  TextColumn get drugDosage => text()();
  TextColumn get doseAmount => text().withDefault(const Constant('1'))();
  TextColumn get takingFrequency => text().map(const TakingFrequencyConverter())();
  TextColumn get reminderTimes => text().map(const ReminderTimesConverter())();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  IntColumn get doseThreshold => integer()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  IntColumn get dosesRemaining => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();
}

@DataClassName('MedicationLog')
class MedicationLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get therapyId => integer().references(Therapies, #id)();
  DateTimeColumn get scheduledDoseTime => dateTime()();
  DateTimeColumn get actualTakenTime => dateTime()();
  TextColumn get status => text()();
}

class TakingFrequencyConverter extends TypeConverter<TakingFrequency, String> {
  const TakingFrequencyConverter();
  @override
  TakingFrequency fromSql(String fromDb) => TakingFrequency.values.byName(fromDb);
  @override
  String toSql(TakingFrequency value) => value.name;
}

class ReminderTimesConverter extends TypeConverter<List<String>, String> {
  const ReminderTimesConverter();
  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return (jsonDecode(fromDb) as List).cast<String>();
  }
  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}

@DriftDatabase(tables: [Therapies, MedicationLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  Future<int> createTherapy(TherapiesCompanion entry) {
    return into(therapies).insert(entry);
  }

  Stream<List<Therapy>> watchAllActiveTherapies() {
    return (select(therapies)
          ..where((t) => t.isActive.equals(true) & t.isPaused.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.drugName)]))
        .watch();
  }
  
  Future<void> updateTherapy(Therapy entry) {
    return update(therapies).replace(entry);
  }

  Future<void> deleteTherapy(int id) {
    return (delete(therapies)..where((t) => t.id.equals(id))).go();
  }

  Future<Therapy> getTherapyById(int id) {
    return (select(therapies)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> logDoseTaken({
    required int therapyId,
    required DateTime scheduledTime,
    required int amount,
  }) async {
    final entry = MedicationLogsCompanion.insert(
      therapyId: therapyId,
      scheduledDoseTime: scheduledTime,
      actualTakenTime: DateTime.now(),
      status: 'taken',
    );
    await into(medicationLogs).insert(entry);
    // Pass the amount to the decrement helper
    await _decrementDosesRemaining(therapyId, amount: amount);
  }

  
  Future<void> _decrementDosesRemaining(int therapyId, {int amount = 1}) async {
    final statement = update(therapies)..where((t) => t.id.equals(therapyId));
    await statement.write(
      TherapiesCompanion.custom(
        // Use the passed amount instead of a hardcoded 1
        dosesRemaining: therapies.dosesRemaining - Constant(amount),
      ),
    );
  }


  // Renamed for clarity and updated return type.
  Stream<List<MedicationLog>> watchDoseLogsForDay({
    required int therapyId,
    required DateTime day,
  }) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

    return (select(medicationLogs)
          ..where((log) => log.therapyId.equals(therapyId))
          ..where((log) => log.scheduledDoseTime.isBetween(Constant(startOfDay), Constant(endOfDay))))
        // Use .watch() to get a stream of the entire list of results
        .watch();
  }

  Future<void> removeDoseLog({
    required int therapyId,
    required DateTime scheduledTime,
    required int amount,
  }) async {
    await (delete(medicationLogs)
          ..where((log) => log.therapyId.equals(therapyId))
          ..where((log) => log.scheduledDoseTime.equals(scheduledTime)))
        .go();
    // Pass the amount to the increment helper
    await _incrementDosesRemaining(therapyId, amount: amount);
  }

  Future<void> _incrementDosesRemaining(int therapyId, {int amount = 1}) async {
    final statement = update(therapies)..where((t) => t.id.equals(therapyId));
    await statement.write(
      TherapiesCompanion.custom(
        dosesRemaining: therapies.dosesRemaining + Constant(amount),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'akora_db.sqlite'));
    return NativeDatabase(file);
  });
}