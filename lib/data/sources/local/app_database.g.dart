// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TherapiesTable extends Therapies
    with TableInfo<$TherapiesTable, Therapy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TherapiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _drugNameMeta = const VerificationMeta(
    'drugName',
  );
  @override
  late final GeneratedColumn<String> drugName = GeneratedColumn<String>(
    'drug_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _drugDosageMeta = const VerificationMeta(
    'drugDosage',
  );
  @override
  late final GeneratedColumn<String> drugDosage = GeneratedColumn<String>(
    'drug_dosage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseAmountMeta = const VerificationMeta(
    'doseAmount',
  );
  @override
  late final GeneratedColumn<String> doseAmount = GeneratedColumn<String>(
    'dose_amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1'),
  );
  static const VerificationMeta _doseUnitMeta = const VerificationMeta(
    'doseUnit',
  );
  @override
  late final GeneratedColumn<String> doseUnit = GeneratedColumn<String>(
    'dose_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('compressa'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TakingFrequency, String>
  takingFrequency = GeneratedColumn<String>(
    'taking_frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<TakingFrequency>($TherapiesTable.$convertertakingFrequency);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  reminderTimes = GeneratedColumn<String>(
    'reminder_times',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($TherapiesTable.$converterreminderTimes);
  static const VerificationMeta _repeatAfter10MinMeta = const VerificationMeta(
    'repeatAfter10Min',
  );
  @override
  late final GeneratedColumn<bool> repeatAfter10Min = GeneratedColumn<bool>(
    'repeat_after10_min',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("repeat_after10_min" IN (0, 1))',
    ),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseThresholdMeta = const VerificationMeta(
    'doseThreshold',
  );
  @override
  late final GeneratedColumn<int> doseThreshold = GeneratedColumn<int>(
    'dose_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dosesRemainingMeta = const VerificationMeta(
    'dosesRemaining',
  );
  @override
  late final GeneratedColumn<int> dosesRemaining = GeneratedColumn<int>(
    'doses_remaining',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isPausedMeta = const VerificationMeta(
    'isPaused',
  );
  @override
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
    'is_paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    drugName,
    drugDosage,
    doseAmount,
    doseUnit,
    takingFrequency,
    reminderTimes,
    repeatAfter10Min,
    startDate,
    endDate,
    doseThreshold,
    expiryDate,
    dosesRemaining,
    isActive,
    isPaused,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'therapies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Therapy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('drug_name')) {
      context.handle(
        _drugNameMeta,
        drugName.isAcceptableOrUnknown(data['drug_name']!, _drugNameMeta),
      );
    } else if (isInserting) {
      context.missing(_drugNameMeta);
    }
    if (data.containsKey('drug_dosage')) {
      context.handle(
        _drugDosageMeta,
        drugDosage.isAcceptableOrUnknown(data['drug_dosage']!, _drugDosageMeta),
      );
    } else if (isInserting) {
      context.missing(_drugDosageMeta);
    }
    if (data.containsKey('dose_amount')) {
      context.handle(
        _doseAmountMeta,
        doseAmount.isAcceptableOrUnknown(data['dose_amount']!, _doseAmountMeta),
      );
    }
    if (data.containsKey('dose_unit')) {
      context.handle(
        _doseUnitMeta,
        doseUnit.isAcceptableOrUnknown(data['dose_unit']!, _doseUnitMeta),
      );
    }
    if (data.containsKey('repeat_after10_min')) {
      context.handle(
        _repeatAfter10MinMeta,
        repeatAfter10Min.isAcceptableOrUnknown(
          data['repeat_after10_min']!,
          _repeatAfter10MinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repeatAfter10MinMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('dose_threshold')) {
      context.handle(
        _doseThresholdMeta,
        doseThreshold.isAcceptableOrUnknown(
          data['dose_threshold']!,
          _doseThresholdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_doseThresholdMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    }
    if (data.containsKey('doses_remaining')) {
      context.handle(
        _dosesRemainingMeta,
        dosesRemaining.isAcceptableOrUnknown(
          data['doses_remaining']!,
          _dosesRemainingMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_paused')) {
      context.handle(
        _isPausedMeta,
        isPaused.isAcceptableOrUnknown(data['is_paused']!, _isPausedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Therapy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Therapy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      drugName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drug_name'],
      )!,
      drugDosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drug_dosage'],
      )!,
      doseAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_amount'],
      )!,
      doseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_unit'],
      )!,
      takingFrequency: $TherapiesTable.$convertertakingFrequency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}taking_frequency'],
        )!,
      ),
      reminderTimes: $TherapiesTable.$converterreminderTimes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reminder_times'],
        )!,
      ),
      repeatAfter10Min: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}repeat_after10_min'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      doseThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dose_threshold'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      ),
      dosesRemaining: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}doses_remaining'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isPaused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paused'],
      )!,
    );
  }

  @override
  $TherapiesTable createAlias(String alias) {
    return $TherapiesTable(attachedDatabase, alias);
  }

  static TypeConverter<TakingFrequency, String> $convertertakingFrequency =
      const TakingFrequencyConverter();
  static TypeConverter<List<String>, String> $converterreminderTimes =
      const ReminderTimesConverter();
}

class Therapy extends DataClass implements Insertable<Therapy> {
  final int id;
  final String drugName;
  final String drugDosage;
  final String doseAmount;
  final String doseUnit;
  final TakingFrequency takingFrequency;
  final List<String> reminderTimes;
  final bool repeatAfter10Min;
  final DateTime startDate;
  final DateTime endDate;
  final int doseThreshold;
  final DateTime? expiryDate;
  final int? dosesRemaining;
  final bool isActive;
  final bool isPaused;
  const Therapy({
    required this.id,
    required this.drugName,
    required this.drugDosage,
    required this.doseAmount,
    required this.doseUnit,
    required this.takingFrequency,
    required this.reminderTimes,
    required this.repeatAfter10Min,
    required this.startDate,
    required this.endDate,
    required this.doseThreshold,
    this.expiryDate,
    this.dosesRemaining,
    required this.isActive,
    required this.isPaused,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['drug_name'] = Variable<String>(drugName);
    map['drug_dosage'] = Variable<String>(drugDosage);
    map['dose_amount'] = Variable<String>(doseAmount);
    map['dose_unit'] = Variable<String>(doseUnit);
    {
      map['taking_frequency'] = Variable<String>(
        $TherapiesTable.$convertertakingFrequency.toSql(takingFrequency),
      );
    }
    {
      map['reminder_times'] = Variable<String>(
        $TherapiesTable.$converterreminderTimes.toSql(reminderTimes),
      );
    }
    map['repeat_after10_min'] = Variable<bool>(repeatAfter10Min);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['dose_threshold'] = Variable<int>(doseThreshold);
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    if (!nullToAbsent || dosesRemaining != null) {
      map['doses_remaining'] = Variable<int>(dosesRemaining);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['is_paused'] = Variable<bool>(isPaused);
    return map;
  }

  TherapiesCompanion toCompanion(bool nullToAbsent) {
    return TherapiesCompanion(
      id: Value(id),
      drugName: Value(drugName),
      drugDosage: Value(drugDosage),
      doseAmount: Value(doseAmount),
      doseUnit: Value(doseUnit),
      takingFrequency: Value(takingFrequency),
      reminderTimes: Value(reminderTimes),
      repeatAfter10Min: Value(repeatAfter10Min),
      startDate: Value(startDate),
      endDate: Value(endDate),
      doseThreshold: Value(doseThreshold),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      dosesRemaining: dosesRemaining == null && nullToAbsent
          ? const Value.absent()
          : Value(dosesRemaining),
      isActive: Value(isActive),
      isPaused: Value(isPaused),
    );
  }

  factory Therapy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Therapy(
      id: serializer.fromJson<int>(json['id']),
      drugName: serializer.fromJson<String>(json['drugName']),
      drugDosage: serializer.fromJson<String>(json['drugDosage']),
      doseAmount: serializer.fromJson<String>(json['doseAmount']),
      doseUnit: serializer.fromJson<String>(json['doseUnit']),
      takingFrequency: serializer.fromJson<TakingFrequency>(
        json['takingFrequency'],
      ),
      reminderTimes: serializer.fromJson<List<String>>(json['reminderTimes']),
      repeatAfter10Min: serializer.fromJson<bool>(json['repeatAfter10Min']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      doseThreshold: serializer.fromJson<int>(json['doseThreshold']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      dosesRemaining: serializer.fromJson<int?>(json['dosesRemaining']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isPaused: serializer.fromJson<bool>(json['isPaused']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'drugName': serializer.toJson<String>(drugName),
      'drugDosage': serializer.toJson<String>(drugDosage),
      'doseAmount': serializer.toJson<String>(doseAmount),
      'doseUnit': serializer.toJson<String>(doseUnit),
      'takingFrequency': serializer.toJson<TakingFrequency>(takingFrequency),
      'reminderTimes': serializer.toJson<List<String>>(reminderTimes),
      'repeatAfter10Min': serializer.toJson<bool>(repeatAfter10Min),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'doseThreshold': serializer.toJson<int>(doseThreshold),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'dosesRemaining': serializer.toJson<int?>(dosesRemaining),
      'isActive': serializer.toJson<bool>(isActive),
      'isPaused': serializer.toJson<bool>(isPaused),
    };
  }

  Therapy copyWith({
    int? id,
    String? drugName,
    String? drugDosage,
    String? doseAmount,
    String? doseUnit,
    TakingFrequency? takingFrequency,
    List<String>? reminderTimes,
    bool? repeatAfter10Min,
    DateTime? startDate,
    DateTime? endDate,
    int? doseThreshold,
    Value<DateTime?> expiryDate = const Value.absent(),
    Value<int?> dosesRemaining = const Value.absent(),
    bool? isActive,
    bool? isPaused,
  }) => Therapy(
    id: id ?? this.id,
    drugName: drugName ?? this.drugName,
    drugDosage: drugDosage ?? this.drugDosage,
    doseAmount: doseAmount ?? this.doseAmount,
    doseUnit: doseUnit ?? this.doseUnit,
    takingFrequency: takingFrequency ?? this.takingFrequency,
    reminderTimes: reminderTimes ?? this.reminderTimes,
    repeatAfter10Min: repeatAfter10Min ?? this.repeatAfter10Min,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    doseThreshold: doseThreshold ?? this.doseThreshold,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
    dosesRemaining: dosesRemaining.present
        ? dosesRemaining.value
        : this.dosesRemaining,
    isActive: isActive ?? this.isActive,
    isPaused: isPaused ?? this.isPaused,
  );
  Therapy copyWithCompanion(TherapiesCompanion data) {
    return Therapy(
      id: data.id.present ? data.id.value : this.id,
      drugName: data.drugName.present ? data.drugName.value : this.drugName,
      drugDosage: data.drugDosage.present
          ? data.drugDosage.value
          : this.drugDosage,
      doseAmount: data.doseAmount.present
          ? data.doseAmount.value
          : this.doseAmount,
      doseUnit: data.doseUnit.present ? data.doseUnit.value : this.doseUnit,
      takingFrequency: data.takingFrequency.present
          ? data.takingFrequency.value
          : this.takingFrequency,
      reminderTimes: data.reminderTimes.present
          ? data.reminderTimes.value
          : this.reminderTimes,
      repeatAfter10Min: data.repeatAfter10Min.present
          ? data.repeatAfter10Min.value
          : this.repeatAfter10Min,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      doseThreshold: data.doseThreshold.present
          ? data.doseThreshold.value
          : this.doseThreshold,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      dosesRemaining: data.dosesRemaining.present
          ? data.dosesRemaining.value
          : this.dosesRemaining,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isPaused: data.isPaused.present ? data.isPaused.value : this.isPaused,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Therapy(')
          ..write('id: $id, ')
          ..write('drugName: $drugName, ')
          ..write('drugDosage: $drugDosage, ')
          ..write('doseAmount: $doseAmount, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('takingFrequency: $takingFrequency, ')
          ..write('reminderTimes: $reminderTimes, ')
          ..write('repeatAfter10Min: $repeatAfter10Min, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('doseThreshold: $doseThreshold, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('dosesRemaining: $dosesRemaining, ')
          ..write('isActive: $isActive, ')
          ..write('isPaused: $isPaused')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    drugName,
    drugDosage,
    doseAmount,
    doseUnit,
    takingFrequency,
    reminderTimes,
    repeatAfter10Min,
    startDate,
    endDate,
    doseThreshold,
    expiryDate,
    dosesRemaining,
    isActive,
    isPaused,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Therapy &&
          other.id == this.id &&
          other.drugName == this.drugName &&
          other.drugDosage == this.drugDosage &&
          other.doseAmount == this.doseAmount &&
          other.doseUnit == this.doseUnit &&
          other.takingFrequency == this.takingFrequency &&
          other.reminderTimes == this.reminderTimes &&
          other.repeatAfter10Min == this.repeatAfter10Min &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.doseThreshold == this.doseThreshold &&
          other.expiryDate == this.expiryDate &&
          other.dosesRemaining == this.dosesRemaining &&
          other.isActive == this.isActive &&
          other.isPaused == this.isPaused);
}

class TherapiesCompanion extends UpdateCompanion<Therapy> {
  final Value<int> id;
  final Value<String> drugName;
  final Value<String> drugDosage;
  final Value<String> doseAmount;
  final Value<String> doseUnit;
  final Value<TakingFrequency> takingFrequency;
  final Value<List<String>> reminderTimes;
  final Value<bool> repeatAfter10Min;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<int> doseThreshold;
  final Value<DateTime?> expiryDate;
  final Value<int?> dosesRemaining;
  final Value<bool> isActive;
  final Value<bool> isPaused;
  const TherapiesCompanion({
    this.id = const Value.absent(),
    this.drugName = const Value.absent(),
    this.drugDosage = const Value.absent(),
    this.doseAmount = const Value.absent(),
    this.doseUnit = const Value.absent(),
    this.takingFrequency = const Value.absent(),
    this.reminderTimes = const Value.absent(),
    this.repeatAfter10Min = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.doseThreshold = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.dosesRemaining = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isPaused = const Value.absent(),
  });
  TherapiesCompanion.insert({
    this.id = const Value.absent(),
    required String drugName,
    required String drugDosage,
    this.doseAmount = const Value.absent(),
    this.doseUnit = const Value.absent(),
    required TakingFrequency takingFrequency,
    required List<String> reminderTimes,
    required bool repeatAfter10Min,
    required DateTime startDate,
    required DateTime endDate,
    required int doseThreshold,
    this.expiryDate = const Value.absent(),
    this.dosesRemaining = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isPaused = const Value.absent(),
  }) : drugName = Value(drugName),
       drugDosage = Value(drugDosage),
       takingFrequency = Value(takingFrequency),
       reminderTimes = Value(reminderTimes),
       repeatAfter10Min = Value(repeatAfter10Min),
       startDate = Value(startDate),
       endDate = Value(endDate),
       doseThreshold = Value(doseThreshold);
  static Insertable<Therapy> custom({
    Expression<int>? id,
    Expression<String>? drugName,
    Expression<String>? drugDosage,
    Expression<String>? doseAmount,
    Expression<String>? doseUnit,
    Expression<String>? takingFrequency,
    Expression<String>? reminderTimes,
    Expression<bool>? repeatAfter10Min,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? doseThreshold,
    Expression<DateTime>? expiryDate,
    Expression<int>? dosesRemaining,
    Expression<bool>? isActive,
    Expression<bool>? isPaused,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (drugName != null) 'drug_name': drugName,
      if (drugDosage != null) 'drug_dosage': drugDosage,
      if (doseAmount != null) 'dose_amount': doseAmount,
      if (doseUnit != null) 'dose_unit': doseUnit,
      if (takingFrequency != null) 'taking_frequency': takingFrequency,
      if (reminderTimes != null) 'reminder_times': reminderTimes,
      if (repeatAfter10Min != null) 'repeat_after10_min': repeatAfter10Min,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (doseThreshold != null) 'dose_threshold': doseThreshold,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (dosesRemaining != null) 'doses_remaining': dosesRemaining,
      if (isActive != null) 'is_active': isActive,
      if (isPaused != null) 'is_paused': isPaused,
    });
  }

  TherapiesCompanion copyWith({
    Value<int>? id,
    Value<String>? drugName,
    Value<String>? drugDosage,
    Value<String>? doseAmount,
    Value<String>? doseUnit,
    Value<TakingFrequency>? takingFrequency,
    Value<List<String>>? reminderTimes,
    Value<bool>? repeatAfter10Min,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<int>? doseThreshold,
    Value<DateTime?>? expiryDate,
    Value<int?>? dosesRemaining,
    Value<bool>? isActive,
    Value<bool>? isPaused,
  }) {
    return TherapiesCompanion(
      id: id ?? this.id,
      drugName: drugName ?? this.drugName,
      drugDosage: drugDosage ?? this.drugDosage,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      takingFrequency: takingFrequency ?? this.takingFrequency,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      repeatAfter10Min: repeatAfter10Min ?? this.repeatAfter10Min,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      doseThreshold: doseThreshold ?? this.doseThreshold,
      expiryDate: expiryDate ?? this.expiryDate,
      dosesRemaining: dosesRemaining ?? this.dosesRemaining,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (drugName.present) {
      map['drug_name'] = Variable<String>(drugName.value);
    }
    if (drugDosage.present) {
      map['drug_dosage'] = Variable<String>(drugDosage.value);
    }
    if (doseAmount.present) {
      map['dose_amount'] = Variable<String>(doseAmount.value);
    }
    if (doseUnit.present) {
      map['dose_unit'] = Variable<String>(doseUnit.value);
    }
    if (takingFrequency.present) {
      map['taking_frequency'] = Variable<String>(
        $TherapiesTable.$convertertakingFrequency.toSql(takingFrequency.value),
      );
    }
    if (reminderTimes.present) {
      map['reminder_times'] = Variable<String>(
        $TherapiesTable.$converterreminderTimes.toSql(reminderTimes.value),
      );
    }
    if (repeatAfter10Min.present) {
      map['repeat_after10_min'] = Variable<bool>(repeatAfter10Min.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (doseThreshold.present) {
      map['dose_threshold'] = Variable<int>(doseThreshold.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (dosesRemaining.present) {
      map['doses_remaining'] = Variable<int>(dosesRemaining.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isPaused.present) {
      map['is_paused'] = Variable<bool>(isPaused.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TherapiesCompanion(')
          ..write('id: $id, ')
          ..write('drugName: $drugName, ')
          ..write('drugDosage: $drugDosage, ')
          ..write('doseAmount: $doseAmount, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('takingFrequency: $takingFrequency, ')
          ..write('reminderTimes: $reminderTimes, ')
          ..write('repeatAfter10Min: $repeatAfter10Min, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('doseThreshold: $doseThreshold, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('dosesRemaining: $dosesRemaining, ')
          ..write('isActive: $isActive, ')
          ..write('isPaused: $isPaused')
          ..write(')'))
        .toString();
  }
}

class $MedicationLogsTable extends MedicationLogs
    with TableInfo<$MedicationLogsTable, MedicationLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _therapyIdMeta = const VerificationMeta(
    'therapyId',
  );
  @override
  late final GeneratedColumn<int> therapyId = GeneratedColumn<int>(
    'therapy_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES therapies (id)',
    ),
  );
  static const VerificationMeta _scheduledDoseTimeMeta = const VerificationMeta(
    'scheduledDoseTime',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDoseTime =
      GeneratedColumn<DateTime>(
        'scheduled_dose_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actualTakenTimeMeta = const VerificationMeta(
    'actualTakenTime',
  );
  @override
  late final GeneratedColumn<DateTime> actualTakenTime =
      GeneratedColumn<DateTime>(
        'actual_taken_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    therapyId,
    scheduledDoseTime,
    actualTakenTime,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('therapy_id')) {
      context.handle(
        _therapyIdMeta,
        therapyId.isAcceptableOrUnknown(data['therapy_id']!, _therapyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_therapyIdMeta);
    }
    if (data.containsKey('scheduled_dose_time')) {
      context.handle(
        _scheduledDoseTimeMeta,
        scheduledDoseTime.isAcceptableOrUnknown(
          data['scheduled_dose_time']!,
          _scheduledDoseTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDoseTimeMeta);
    }
    if (data.containsKey('actual_taken_time')) {
      context.handle(
        _actualTakenTimeMeta,
        actualTakenTime.isAcceptableOrUnknown(
          data['actual_taken_time']!,
          _actualTakenTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualTakenTimeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      therapyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}therapy_id'],
      )!,
      scheduledDoseTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_dose_time'],
      )!,
      actualTakenTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_taken_time'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $MedicationLogsTable createAlias(String alias) {
    return $MedicationLogsTable(attachedDatabase, alias);
  }
}

class MedicationLog extends DataClass implements Insertable<MedicationLog> {
  final int id;
  final int therapyId;
  final DateTime scheduledDoseTime;
  final DateTime actualTakenTime;
  final String status;
  const MedicationLog({
    required this.id,
    required this.therapyId,
    required this.scheduledDoseTime,
    required this.actualTakenTime,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['therapy_id'] = Variable<int>(therapyId);
    map['scheduled_dose_time'] = Variable<DateTime>(scheduledDoseTime);
    map['actual_taken_time'] = Variable<DateTime>(actualTakenTime);
    map['status'] = Variable<String>(status);
    return map;
  }

  MedicationLogsCompanion toCompanion(bool nullToAbsent) {
    return MedicationLogsCompanion(
      id: Value(id),
      therapyId: Value(therapyId),
      scheduledDoseTime: Value(scheduledDoseTime),
      actualTakenTime: Value(actualTakenTime),
      status: Value(status),
    );
  }

  factory MedicationLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationLog(
      id: serializer.fromJson<int>(json['id']),
      therapyId: serializer.fromJson<int>(json['therapyId']),
      scheduledDoseTime: serializer.fromJson<DateTime>(
        json['scheduledDoseTime'],
      ),
      actualTakenTime: serializer.fromJson<DateTime>(json['actualTakenTime']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'therapyId': serializer.toJson<int>(therapyId),
      'scheduledDoseTime': serializer.toJson<DateTime>(scheduledDoseTime),
      'actualTakenTime': serializer.toJson<DateTime>(actualTakenTime),
      'status': serializer.toJson<String>(status),
    };
  }

  MedicationLog copyWith({
    int? id,
    int? therapyId,
    DateTime? scheduledDoseTime,
    DateTime? actualTakenTime,
    String? status,
  }) => MedicationLog(
    id: id ?? this.id,
    therapyId: therapyId ?? this.therapyId,
    scheduledDoseTime: scheduledDoseTime ?? this.scheduledDoseTime,
    actualTakenTime: actualTakenTime ?? this.actualTakenTime,
    status: status ?? this.status,
  );
  MedicationLog copyWithCompanion(MedicationLogsCompanion data) {
    return MedicationLog(
      id: data.id.present ? data.id.value : this.id,
      therapyId: data.therapyId.present ? data.therapyId.value : this.therapyId,
      scheduledDoseTime: data.scheduledDoseTime.present
          ? data.scheduledDoseTime.value
          : this.scheduledDoseTime,
      actualTakenTime: data.actualTakenTime.present
          ? data.actualTakenTime.value
          : this.actualTakenTime,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationLog(')
          ..write('id: $id, ')
          ..write('therapyId: $therapyId, ')
          ..write('scheduledDoseTime: $scheduledDoseTime, ')
          ..write('actualTakenTime: $actualTakenTime, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, therapyId, scheduledDoseTime, actualTakenTime, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationLog &&
          other.id == this.id &&
          other.therapyId == this.therapyId &&
          other.scheduledDoseTime == this.scheduledDoseTime &&
          other.actualTakenTime == this.actualTakenTime &&
          other.status == this.status);
}

class MedicationLogsCompanion extends UpdateCompanion<MedicationLog> {
  final Value<int> id;
  final Value<int> therapyId;
  final Value<DateTime> scheduledDoseTime;
  final Value<DateTime> actualTakenTime;
  final Value<String> status;
  const MedicationLogsCompanion({
    this.id = const Value.absent(),
    this.therapyId = const Value.absent(),
    this.scheduledDoseTime = const Value.absent(),
    this.actualTakenTime = const Value.absent(),
    this.status = const Value.absent(),
  });
  MedicationLogsCompanion.insert({
    this.id = const Value.absent(),
    required int therapyId,
    required DateTime scheduledDoseTime,
    required DateTime actualTakenTime,
    required String status,
  }) : therapyId = Value(therapyId),
       scheduledDoseTime = Value(scheduledDoseTime),
       actualTakenTime = Value(actualTakenTime),
       status = Value(status);
  static Insertable<MedicationLog> custom({
    Expression<int>? id,
    Expression<int>? therapyId,
    Expression<DateTime>? scheduledDoseTime,
    Expression<DateTime>? actualTakenTime,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (therapyId != null) 'therapy_id': therapyId,
      if (scheduledDoseTime != null) 'scheduled_dose_time': scheduledDoseTime,
      if (actualTakenTime != null) 'actual_taken_time': actualTakenTime,
      if (status != null) 'status': status,
    });
  }

  MedicationLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? therapyId,
    Value<DateTime>? scheduledDoseTime,
    Value<DateTime>? actualTakenTime,
    Value<String>? status,
  }) {
    return MedicationLogsCompanion(
      id: id ?? this.id,
      therapyId: therapyId ?? this.therapyId,
      scheduledDoseTime: scheduledDoseTime ?? this.scheduledDoseTime,
      actualTakenTime: actualTakenTime ?? this.actualTakenTime,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (therapyId.present) {
      map['therapy_id'] = Variable<int>(therapyId.value);
    }
    if (scheduledDoseTime.present) {
      map['scheduled_dose_time'] = Variable<DateTime>(scheduledDoseTime.value);
    }
    if (actualTakenTime.present) {
      map['actual_taken_time'] = Variable<DateTime>(actualTakenTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationLogsCompanion(')
          ..write('id: $id, ')
          ..write('therapyId: $therapyId, ')
          ..write('scheduledDoseTime: $scheduledDoseTime, ')
          ..write('actualTakenTime: $actualTakenTime, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TherapiesTable therapies = $TherapiesTable(this);
  late final $MedicationLogsTable medicationLogs = $MedicationLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    therapies,
    medicationLogs,
  ];
}

typedef $$TherapiesTableCreateCompanionBuilder =
    TherapiesCompanion Function({
      Value<int> id,
      required String drugName,
      required String drugDosage,
      Value<String> doseAmount,
      Value<String> doseUnit,
      required TakingFrequency takingFrequency,
      required List<String> reminderTimes,
      required bool repeatAfter10Min,
      required DateTime startDate,
      required DateTime endDate,
      required int doseThreshold,
      Value<DateTime?> expiryDate,
      Value<int?> dosesRemaining,
      Value<bool> isActive,
      Value<bool> isPaused,
    });
typedef $$TherapiesTableUpdateCompanionBuilder =
    TherapiesCompanion Function({
      Value<int> id,
      Value<String> drugName,
      Value<String> drugDosage,
      Value<String> doseAmount,
      Value<String> doseUnit,
      Value<TakingFrequency> takingFrequency,
      Value<List<String>> reminderTimes,
      Value<bool> repeatAfter10Min,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<int> doseThreshold,
      Value<DateTime?> expiryDate,
      Value<int?> dosesRemaining,
      Value<bool> isActive,
      Value<bool> isPaused,
    });

final class $$TherapiesTableReferences
    extends BaseReferences<_$AppDatabase, $TherapiesTable, Therapy> {
  $$TherapiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MedicationLogsTable, List<MedicationLog>>
  _medicationLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicationLogs,
    aliasName: $_aliasNameGenerator(
      db.therapies.id,
      db.medicationLogs.therapyId,
    ),
  );

  $$MedicationLogsTableProcessedTableManager get medicationLogsRefs {
    final manager = $$MedicationLogsTableTableManager(
      $_db,
      $_db.medicationLogs,
    ).filter((f) => f.therapyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicationLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TherapiesTableFilterComposer
    extends Composer<_$AppDatabase, $TherapiesTable> {
  $$TherapiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drugName => $composableBuilder(
    column: $table.drugName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drugDosage => $composableBuilder(
    column: $table.drugDosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseAmount => $composableBuilder(
    column: $table.doseAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TakingFrequency, TakingFrequency, String>
  get takingFrequency => $composableBuilder(
    column: $table.takingFrequency,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get reminderTimes => $composableBuilder(
    column: $table.reminderTimes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get repeatAfter10Min => $composableBuilder(
    column: $table.repeatAfter10Min,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get doseThreshold => $composableBuilder(
    column: $table.doseThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dosesRemaining => $composableBuilder(
    column: $table.dosesRemaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> medicationLogsRefs(
    Expression<bool> Function($$MedicationLogsTableFilterComposer f) f,
  ) {
    final $$MedicationLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationLogs,
      getReferencedColumn: (t) => t.therapyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationLogsTableFilterComposer(
            $db: $db,
            $table: $db.medicationLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TherapiesTableOrderingComposer
    extends Composer<_$AppDatabase, $TherapiesTable> {
  $$TherapiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drugName => $composableBuilder(
    column: $table.drugName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drugDosage => $composableBuilder(
    column: $table.drugDosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseAmount => $composableBuilder(
    column: $table.doseAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get takingFrequency => $composableBuilder(
    column: $table.takingFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTimes => $composableBuilder(
    column: $table.reminderTimes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get repeatAfter10Min => $composableBuilder(
    column: $table.repeatAfter10Min,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get doseThreshold => $composableBuilder(
    column: $table.doseThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dosesRemaining => $composableBuilder(
    column: $table.dosesRemaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TherapiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TherapiesTable> {
  $$TherapiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get drugName =>
      $composableBuilder(column: $table.drugName, builder: (column) => column);

  GeneratedColumn<String> get drugDosage => $composableBuilder(
    column: $table.drugDosage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doseAmount => $composableBuilder(
    column: $table.doseAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doseUnit =>
      $composableBuilder(column: $table.doseUnit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TakingFrequency, String>
  get takingFrequency => $composableBuilder(
    column: $table.takingFrequency,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get reminderTimes =>
      $composableBuilder(
        column: $table.reminderTimes,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get repeatAfter10Min => $composableBuilder(
    column: $table.repeatAfter10Min,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get doseThreshold => $composableBuilder(
    column: $table.doseThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dosesRemaining => $composableBuilder(
    column: $table.dosesRemaining,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);

  Expression<T> medicationLogsRefs<T extends Object>(
    Expression<T> Function($$MedicationLogsTableAnnotationComposer a) f,
  ) {
    final $$MedicationLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationLogs,
      getReferencedColumn: (t) => t.therapyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.medicationLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TherapiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TherapiesTable,
          Therapy,
          $$TherapiesTableFilterComposer,
          $$TherapiesTableOrderingComposer,
          $$TherapiesTableAnnotationComposer,
          $$TherapiesTableCreateCompanionBuilder,
          $$TherapiesTableUpdateCompanionBuilder,
          (Therapy, $$TherapiesTableReferences),
          Therapy,
          PrefetchHooks Function({bool medicationLogsRefs})
        > {
  $$TherapiesTableTableManager(_$AppDatabase db, $TherapiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TherapiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TherapiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TherapiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> drugName = const Value.absent(),
                Value<String> drugDosage = const Value.absent(),
                Value<String> doseAmount = const Value.absent(),
                Value<String> doseUnit = const Value.absent(),
                Value<TakingFrequency> takingFrequency = const Value.absent(),
                Value<List<String>> reminderTimes = const Value.absent(),
                Value<bool> repeatAfter10Min = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<int> doseThreshold = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<int?> dosesRemaining = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
              }) => TherapiesCompanion(
                id: id,
                drugName: drugName,
                drugDosage: drugDosage,
                doseAmount: doseAmount,
                doseUnit: doseUnit,
                takingFrequency: takingFrequency,
                reminderTimes: reminderTimes,
                repeatAfter10Min: repeatAfter10Min,
                startDate: startDate,
                endDate: endDate,
                doseThreshold: doseThreshold,
                expiryDate: expiryDate,
                dosesRemaining: dosesRemaining,
                isActive: isActive,
                isPaused: isPaused,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String drugName,
                required String drugDosage,
                Value<String> doseAmount = const Value.absent(),
                Value<String> doseUnit = const Value.absent(),
                required TakingFrequency takingFrequency,
                required List<String> reminderTimes,
                required bool repeatAfter10Min,
                required DateTime startDate,
                required DateTime endDate,
                required int doseThreshold,
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<int?> dosesRemaining = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
              }) => TherapiesCompanion.insert(
                id: id,
                drugName: drugName,
                drugDosage: drugDosage,
                doseAmount: doseAmount,
                doseUnit: doseUnit,
                takingFrequency: takingFrequency,
                reminderTimes: reminderTimes,
                repeatAfter10Min: repeatAfter10Min,
                startDate: startDate,
                endDate: endDate,
                doseThreshold: doseThreshold,
                expiryDate: expiryDate,
                dosesRemaining: dosesRemaining,
                isActive: isActive,
                isPaused: isPaused,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TherapiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (medicationLogsRefs) db.medicationLogs,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (medicationLogsRefs)
                    await $_getPrefetchedData<
                      Therapy,
                      $TherapiesTable,
                      MedicationLog
                    >(
                      currentTable: table,
                      referencedTable: $$TherapiesTableReferences
                          ._medicationLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TherapiesTableReferences(
                            db,
                            table,
                            p0,
                          ).medicationLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.therapyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TherapiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TherapiesTable,
      Therapy,
      $$TherapiesTableFilterComposer,
      $$TherapiesTableOrderingComposer,
      $$TherapiesTableAnnotationComposer,
      $$TherapiesTableCreateCompanionBuilder,
      $$TherapiesTableUpdateCompanionBuilder,
      (Therapy, $$TherapiesTableReferences),
      Therapy,
      PrefetchHooks Function({bool medicationLogsRefs})
    >;
typedef $$MedicationLogsTableCreateCompanionBuilder =
    MedicationLogsCompanion Function({
      Value<int> id,
      required int therapyId,
      required DateTime scheduledDoseTime,
      required DateTime actualTakenTime,
      required String status,
    });
typedef $$MedicationLogsTableUpdateCompanionBuilder =
    MedicationLogsCompanion Function({
      Value<int> id,
      Value<int> therapyId,
      Value<DateTime> scheduledDoseTime,
      Value<DateTime> actualTakenTime,
      Value<String> status,
    });

final class $$MedicationLogsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationLogsTable, MedicationLog> {
  $$MedicationLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TherapiesTable _therapyIdTable(_$AppDatabase db) =>
      db.therapies.createAlias(
        $_aliasNameGenerator(db.medicationLogs.therapyId, db.therapies.id),
      );

  $$TherapiesTableProcessedTableManager get therapyId {
    final $_column = $_itemColumn<int>('therapy_id')!;

    final manager = $$TherapiesTableTableManager(
      $_db,
      $_db.therapies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_therapyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MedicationLogsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationLogsTable> {
  $$MedicationLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDoseTime => $composableBuilder(
    column: $table.scheduledDoseTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualTakenTime => $composableBuilder(
    column: $table.actualTakenTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$TherapiesTableFilterComposer get therapyId {
    final $$TherapiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.therapyId,
      referencedTable: $db.therapies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TherapiesTableFilterComposer(
            $db: $db,
            $table: $db.therapies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationLogsTable> {
  $$MedicationLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDoseTime => $composableBuilder(
    column: $table.scheduledDoseTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualTakenTime => $composableBuilder(
    column: $table.actualTakenTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$TherapiesTableOrderingComposer get therapyId {
    final $$TherapiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.therapyId,
      referencedTable: $db.therapies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TherapiesTableOrderingComposer(
            $db: $db,
            $table: $db.therapies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationLogsTable> {
  $$MedicationLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDoseTime => $composableBuilder(
    column: $table.scheduledDoseTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get actualTakenTime => $composableBuilder(
    column: $table.actualTakenTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$TherapiesTableAnnotationComposer get therapyId {
    final $$TherapiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.therapyId,
      referencedTable: $db.therapies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TherapiesTableAnnotationComposer(
            $db: $db,
            $table: $db.therapies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationLogsTable,
          MedicationLog,
          $$MedicationLogsTableFilterComposer,
          $$MedicationLogsTableOrderingComposer,
          $$MedicationLogsTableAnnotationComposer,
          $$MedicationLogsTableCreateCompanionBuilder,
          $$MedicationLogsTableUpdateCompanionBuilder,
          (MedicationLog, $$MedicationLogsTableReferences),
          MedicationLog,
          PrefetchHooks Function({bool therapyId})
        > {
  $$MedicationLogsTableTableManager(
    _$AppDatabase db,
    $MedicationLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> therapyId = const Value.absent(),
                Value<DateTime> scheduledDoseTime = const Value.absent(),
                Value<DateTime> actualTakenTime = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => MedicationLogsCompanion(
                id: id,
                therapyId: therapyId,
                scheduledDoseTime: scheduledDoseTime,
                actualTakenTime: actualTakenTime,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int therapyId,
                required DateTime scheduledDoseTime,
                required DateTime actualTakenTime,
                required String status,
              }) => MedicationLogsCompanion.insert(
                id: id,
                therapyId: therapyId,
                scheduledDoseTime: scheduledDoseTime,
                actualTakenTime: actualTakenTime,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({therapyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (therapyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.therapyId,
                                referencedTable: $$MedicationLogsTableReferences
                                    ._therapyIdTable(db),
                                referencedColumn:
                                    $$MedicationLogsTableReferences
                                        ._therapyIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MedicationLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationLogsTable,
      MedicationLog,
      $$MedicationLogsTableFilterComposer,
      $$MedicationLogsTableOrderingComposer,
      $$MedicationLogsTableAnnotationComposer,
      $$MedicationLogsTableCreateCompanionBuilder,
      $$MedicationLogsTableUpdateCompanionBuilder,
      (MedicationLog, $$MedicationLogsTableReferences),
      MedicationLog,
      PrefetchHooks Function({bool therapyId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TherapiesTableTableManager get therapies =>
      $$TherapiesTableTableManager(_db, _db.therapies);
  $$MedicationLogsTableTableManager get medicationLogs =>
      $$MedicationLogsTableTableManager(_db, _db.medicationLogs);
}
