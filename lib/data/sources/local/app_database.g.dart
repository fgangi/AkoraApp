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
  @override
  late final GeneratedColumnWithTypeConverter<TakingFrequency, String>
  takingFrequency = GeneratedColumn<String>(
    'taking_frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<TakingFrequency>($TherapiesTable.$convertertakingFrequency);
  static const VerificationMeta _reminderHourMeta = const VerificationMeta(
    'reminderHour',
  );
  @override
  late final GeneratedColumn<int> reminderHour = GeneratedColumn<int>(
    'reminder_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderMinuteMeta = const VerificationMeta(
    'reminderMinute',
  );
  @override
  late final GeneratedColumn<int> reminderMinute = GeneratedColumn<int>(
    'reminder_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
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
  @override
  late final GeneratedColumnWithTypeConverter<NotificationSound, String>
  notificationSound =
      GeneratedColumn<String>(
        'notification_sound',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<NotificationSound>(
        $TherapiesTable.$converternotificationSound,
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
    takingFrequency,
    reminderHour,
    reminderMinute,
    repeatAfter10Min,
    startDate,
    endDate,
    doseThreshold,
    expiryDate,
    notificationSound,
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
    if (data.containsKey('reminder_hour')) {
      context.handle(
        _reminderHourMeta,
        reminderHour.isAcceptableOrUnknown(
          data['reminder_hour']!,
          _reminderHourMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderHourMeta);
    }
    if (data.containsKey('reminder_minute')) {
      context.handle(
        _reminderMinuteMeta,
        reminderMinute.isAcceptableOrUnknown(
          data['reminder_minute']!,
          _reminderMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderMinuteMeta);
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
      takingFrequency: $TherapiesTable.$convertertakingFrequency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}taking_frequency'],
        )!,
      ),
      reminderHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_hour'],
      )!,
      reminderMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minute'],
      )!,
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
      notificationSound: $TherapiesTable.$converternotificationSound.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}notification_sound'],
        )!,
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
  static TypeConverter<NotificationSound, String> $converternotificationSound =
      const NotificationSoundConverter();
}

class Therapy extends DataClass implements Insertable<Therapy> {
  final int id;
  final String drugName;
  final String drugDosage;
  final TakingFrequency takingFrequency;
  final int reminderHour;
  final int reminderMinute;
  final bool repeatAfter10Min;
  final DateTime startDate;
  final DateTime endDate;
  final int doseThreshold;
  final DateTime? expiryDate;
  final NotificationSound notificationSound;
  final bool isActive;
  final bool isPaused;
  const Therapy({
    required this.id,
    required this.drugName,
    required this.drugDosage,
    required this.takingFrequency,
    required this.reminderHour,
    required this.reminderMinute,
    required this.repeatAfter10Min,
    required this.startDate,
    required this.endDate,
    required this.doseThreshold,
    this.expiryDate,
    required this.notificationSound,
    required this.isActive,
    required this.isPaused,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['drug_name'] = Variable<String>(drugName);
    map['drug_dosage'] = Variable<String>(drugDosage);
    {
      map['taking_frequency'] = Variable<String>(
        $TherapiesTable.$convertertakingFrequency.toSql(takingFrequency),
      );
    }
    map['reminder_hour'] = Variable<int>(reminderHour);
    map['reminder_minute'] = Variable<int>(reminderMinute);
    map['repeat_after10_min'] = Variable<bool>(repeatAfter10Min);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['dose_threshold'] = Variable<int>(doseThreshold);
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    {
      map['notification_sound'] = Variable<String>(
        $TherapiesTable.$converternotificationSound.toSql(notificationSound),
      );
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
      takingFrequency: Value(takingFrequency),
      reminderHour: Value(reminderHour),
      reminderMinute: Value(reminderMinute),
      repeatAfter10Min: Value(repeatAfter10Min),
      startDate: Value(startDate),
      endDate: Value(endDate),
      doseThreshold: Value(doseThreshold),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      notificationSound: Value(notificationSound),
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
      takingFrequency: serializer.fromJson<TakingFrequency>(
        json['takingFrequency'],
      ),
      reminderHour: serializer.fromJson<int>(json['reminderHour']),
      reminderMinute: serializer.fromJson<int>(json['reminderMinute']),
      repeatAfter10Min: serializer.fromJson<bool>(json['repeatAfter10Min']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      doseThreshold: serializer.fromJson<int>(json['doseThreshold']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      notificationSound: serializer.fromJson<NotificationSound>(
        json['notificationSound'],
      ),
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
      'takingFrequency': serializer.toJson<TakingFrequency>(takingFrequency),
      'reminderHour': serializer.toJson<int>(reminderHour),
      'reminderMinute': serializer.toJson<int>(reminderMinute),
      'repeatAfter10Min': serializer.toJson<bool>(repeatAfter10Min),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'doseThreshold': serializer.toJson<int>(doseThreshold),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'notificationSound': serializer.toJson<NotificationSound>(
        notificationSound,
      ),
      'isActive': serializer.toJson<bool>(isActive),
      'isPaused': serializer.toJson<bool>(isPaused),
    };
  }

  Therapy copyWith({
    int? id,
    String? drugName,
    String? drugDosage,
    TakingFrequency? takingFrequency,
    int? reminderHour,
    int? reminderMinute,
    bool? repeatAfter10Min,
    DateTime? startDate,
    DateTime? endDate,
    int? doseThreshold,
    Value<DateTime?> expiryDate = const Value.absent(),
    NotificationSound? notificationSound,
    bool? isActive,
    bool? isPaused,
  }) => Therapy(
    id: id ?? this.id,
    drugName: drugName ?? this.drugName,
    drugDosage: drugDosage ?? this.drugDosage,
    takingFrequency: takingFrequency ?? this.takingFrequency,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    repeatAfter10Min: repeatAfter10Min ?? this.repeatAfter10Min,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    doseThreshold: doseThreshold ?? this.doseThreshold,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
    notificationSound: notificationSound ?? this.notificationSound,
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
      takingFrequency: data.takingFrequency.present
          ? data.takingFrequency.value
          : this.takingFrequency,
      reminderHour: data.reminderHour.present
          ? data.reminderHour.value
          : this.reminderHour,
      reminderMinute: data.reminderMinute.present
          ? data.reminderMinute.value
          : this.reminderMinute,
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
      notificationSound: data.notificationSound.present
          ? data.notificationSound.value
          : this.notificationSound,
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
          ..write('takingFrequency: $takingFrequency, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('repeatAfter10Min: $repeatAfter10Min, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('doseThreshold: $doseThreshold, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('notificationSound: $notificationSound, ')
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
    takingFrequency,
    reminderHour,
    reminderMinute,
    repeatAfter10Min,
    startDate,
    endDate,
    doseThreshold,
    expiryDate,
    notificationSound,
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
          other.takingFrequency == this.takingFrequency &&
          other.reminderHour == this.reminderHour &&
          other.reminderMinute == this.reminderMinute &&
          other.repeatAfter10Min == this.repeatAfter10Min &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.doseThreshold == this.doseThreshold &&
          other.expiryDate == this.expiryDate &&
          other.notificationSound == this.notificationSound &&
          other.isActive == this.isActive &&
          other.isPaused == this.isPaused);
}

class TherapiesCompanion extends UpdateCompanion<Therapy> {
  final Value<int> id;
  final Value<String> drugName;
  final Value<String> drugDosage;
  final Value<TakingFrequency> takingFrequency;
  final Value<int> reminderHour;
  final Value<int> reminderMinute;
  final Value<bool> repeatAfter10Min;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<int> doseThreshold;
  final Value<DateTime?> expiryDate;
  final Value<NotificationSound> notificationSound;
  final Value<bool> isActive;
  final Value<bool> isPaused;
  const TherapiesCompanion({
    this.id = const Value.absent(),
    this.drugName = const Value.absent(),
    this.drugDosage = const Value.absent(),
    this.takingFrequency = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.repeatAfter10Min = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.doseThreshold = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.notificationSound = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isPaused = const Value.absent(),
  });
  TherapiesCompanion.insert({
    this.id = const Value.absent(),
    required String drugName,
    required String drugDosage,
    required TakingFrequency takingFrequency,
    required int reminderHour,
    required int reminderMinute,
    required bool repeatAfter10Min,
    required DateTime startDate,
    required DateTime endDate,
    required int doseThreshold,
    this.expiryDate = const Value.absent(),
    required NotificationSound notificationSound,
    this.isActive = const Value.absent(),
    this.isPaused = const Value.absent(),
  }) : drugName = Value(drugName),
       drugDosage = Value(drugDosage),
       takingFrequency = Value(takingFrequency),
       reminderHour = Value(reminderHour),
       reminderMinute = Value(reminderMinute),
       repeatAfter10Min = Value(repeatAfter10Min),
       startDate = Value(startDate),
       endDate = Value(endDate),
       doseThreshold = Value(doseThreshold),
       notificationSound = Value(notificationSound);
  static Insertable<Therapy> custom({
    Expression<int>? id,
    Expression<String>? drugName,
    Expression<String>? drugDosage,
    Expression<String>? takingFrequency,
    Expression<int>? reminderHour,
    Expression<int>? reminderMinute,
    Expression<bool>? repeatAfter10Min,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? doseThreshold,
    Expression<DateTime>? expiryDate,
    Expression<String>? notificationSound,
    Expression<bool>? isActive,
    Expression<bool>? isPaused,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (drugName != null) 'drug_name': drugName,
      if (drugDosage != null) 'drug_dosage': drugDosage,
      if (takingFrequency != null) 'taking_frequency': takingFrequency,
      if (reminderHour != null) 'reminder_hour': reminderHour,
      if (reminderMinute != null) 'reminder_minute': reminderMinute,
      if (repeatAfter10Min != null) 'repeat_after10_min': repeatAfter10Min,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (doseThreshold != null) 'dose_threshold': doseThreshold,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (notificationSound != null) 'notification_sound': notificationSound,
      if (isActive != null) 'is_active': isActive,
      if (isPaused != null) 'is_paused': isPaused,
    });
  }

  TherapiesCompanion copyWith({
    Value<int>? id,
    Value<String>? drugName,
    Value<String>? drugDosage,
    Value<TakingFrequency>? takingFrequency,
    Value<int>? reminderHour,
    Value<int>? reminderMinute,
    Value<bool>? repeatAfter10Min,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<int>? doseThreshold,
    Value<DateTime?>? expiryDate,
    Value<NotificationSound>? notificationSound,
    Value<bool>? isActive,
    Value<bool>? isPaused,
  }) {
    return TherapiesCompanion(
      id: id ?? this.id,
      drugName: drugName ?? this.drugName,
      drugDosage: drugDosage ?? this.drugDosage,
      takingFrequency: takingFrequency ?? this.takingFrequency,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      repeatAfter10Min: repeatAfter10Min ?? this.repeatAfter10Min,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      doseThreshold: doseThreshold ?? this.doseThreshold,
      expiryDate: expiryDate ?? this.expiryDate,
      notificationSound: notificationSound ?? this.notificationSound,
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
    if (takingFrequency.present) {
      map['taking_frequency'] = Variable<String>(
        $TherapiesTable.$convertertakingFrequency.toSql(takingFrequency.value),
      );
    }
    if (reminderHour.present) {
      map['reminder_hour'] = Variable<int>(reminderHour.value);
    }
    if (reminderMinute.present) {
      map['reminder_minute'] = Variable<int>(reminderMinute.value);
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
    if (notificationSound.present) {
      map['notification_sound'] = Variable<String>(
        $TherapiesTable.$converternotificationSound.toSql(
          notificationSound.value,
        ),
      );
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
          ..write('takingFrequency: $takingFrequency, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('repeatAfter10Min: $repeatAfter10Min, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('doseThreshold: $doseThreshold, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('notificationSound: $notificationSound, ')
          ..write('isActive: $isActive, ')
          ..write('isPaused: $isPaused')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TherapiesTable therapies = $TherapiesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [therapies];
}

typedef $$TherapiesTableCreateCompanionBuilder =
    TherapiesCompanion Function({
      Value<int> id,
      required String drugName,
      required String drugDosage,
      required TakingFrequency takingFrequency,
      required int reminderHour,
      required int reminderMinute,
      required bool repeatAfter10Min,
      required DateTime startDate,
      required DateTime endDate,
      required int doseThreshold,
      Value<DateTime?> expiryDate,
      required NotificationSound notificationSound,
      Value<bool> isActive,
      Value<bool> isPaused,
    });
typedef $$TherapiesTableUpdateCompanionBuilder =
    TherapiesCompanion Function({
      Value<int> id,
      Value<String> drugName,
      Value<String> drugDosage,
      Value<TakingFrequency> takingFrequency,
      Value<int> reminderHour,
      Value<int> reminderMinute,
      Value<bool> repeatAfter10Min,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<int> doseThreshold,
      Value<DateTime?> expiryDate,
      Value<NotificationSound> notificationSound,
      Value<bool> isActive,
      Value<bool> isPaused,
    });

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

  ColumnWithTypeConverterFilters<TakingFrequency, TakingFrequency, String>
  get takingFrequency => $composableBuilder(
    column: $table.takingFrequency,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnFilters(column),
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

  ColumnWithTypeConverterFilters<NotificationSound, NotificationSound, String>
  get notificationSound => $composableBuilder(
    column: $table.notificationSound,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<String> get takingFrequency => $composableBuilder(
    column: $table.takingFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
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

  ColumnOrderings<String> get notificationSound => $composableBuilder(
    column: $table.notificationSound,
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

  GeneratedColumnWithTypeConverter<TakingFrequency, String>
  get takingFrequency => $composableBuilder(
    column: $table.takingFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
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

  GeneratedColumnWithTypeConverter<NotificationSound, String>
  get notificationSound => $composableBuilder(
    column: $table.notificationSound,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);
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
          (Therapy, BaseReferences<_$AppDatabase, $TherapiesTable, Therapy>),
          Therapy,
          PrefetchHooks Function()
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
                Value<TakingFrequency> takingFrequency = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
                Value<int> reminderMinute = const Value.absent(),
                Value<bool> repeatAfter10Min = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<int> doseThreshold = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<NotificationSound> notificationSound =
                    const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
              }) => TherapiesCompanion(
                id: id,
                drugName: drugName,
                drugDosage: drugDosage,
                takingFrequency: takingFrequency,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                repeatAfter10Min: repeatAfter10Min,
                startDate: startDate,
                endDate: endDate,
                doseThreshold: doseThreshold,
                expiryDate: expiryDate,
                notificationSound: notificationSound,
                isActive: isActive,
                isPaused: isPaused,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String drugName,
                required String drugDosage,
                required TakingFrequency takingFrequency,
                required int reminderHour,
                required int reminderMinute,
                required bool repeatAfter10Min,
                required DateTime startDate,
                required DateTime endDate,
                required int doseThreshold,
                Value<DateTime?> expiryDate = const Value.absent(),
                required NotificationSound notificationSound,
                Value<bool> isActive = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
              }) => TherapiesCompanion.insert(
                id: id,
                drugName: drugName,
                drugDosage: drugDosage,
                takingFrequency: takingFrequency,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                repeatAfter10Min: repeatAfter10Min,
                startDate: startDate,
                endDate: endDate,
                doseThreshold: doseThreshold,
                expiryDate: expiryDate,
                notificationSound: notificationSound,
                isActive: isActive,
                isPaused: isPaused,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (Therapy, BaseReferences<_$AppDatabase, $TherapiesTable, Therapy>),
      Therapy,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TherapiesTableTableManager get therapies =>
      $$TherapiesTableTableManager(_db, _db.therapies);
}
