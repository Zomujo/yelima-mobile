// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VitalHistoriesTable extends VitalHistories
    with TableInfo<$VitalHistoriesTable, VitalHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VitalHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vitalTypeMeta =
      const VerificationMeta('vitalType');
  @override
  late final GeneratedColumn<String> vitalType = GeneratedColumn<String>(
      'vital_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vitalNameMeta =
      const VerificationMeta('vitalName');
  @override
  late final GeneratedColumn<String> vitalName = GeneratedColumn<String>(
      'vital_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, vitalType, value, unit, severity, vitalName, recordedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vital_histories';
  @override
  VerificationContext validateIntegrity(Insertable<VitalHistory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vital_type')) {
      context.handle(_vitalTypeMeta,
          vitalType.isAcceptableOrUnknown(data['vital_type']!, _vitalTypeMeta));
    } else if (isInserting) {
      context.missing(_vitalTypeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('vital_name')) {
      context.handle(_vitalNameMeta,
          vitalName.isAcceptableOrUnknown(data['vital_name']!, _vitalNameMeta));
    } else if (isInserting) {
      context.missing(_vitalNameMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VitalHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VitalHistory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      vitalType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vital_type'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      vitalName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vital_name'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at']),
    );
  }

  @override
  $VitalHistoriesTable createAlias(String alias) {
    return $VitalHistoriesTable(attachedDatabase, alias);
  }
}

class VitalHistory extends DataClass implements Insertable<VitalHistory> {
  final String id;
  final String vitalType;
  final String value;
  final String unit;
  final String severity;
  final String vitalName;
  final DateTime? recordedAt;
  const VitalHistory(
      {required this.id,
      required this.vitalType,
      required this.value,
      required this.unit,
      required this.severity,
      required this.vitalName,
      this.recordedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vital_type'] = Variable<String>(vitalType);
    map['value'] = Variable<String>(value);
    map['unit'] = Variable<String>(unit);
    map['severity'] = Variable<String>(severity);
    map['vital_name'] = Variable<String>(vitalName);
    if (!nullToAbsent || recordedAt != null) {
      map['recorded_at'] = Variable<DateTime>(recordedAt);
    }
    return map;
  }

  VitalHistoriesCompanion toCompanion(bool nullToAbsent) {
    return VitalHistoriesCompanion(
      id: Value(id),
      vitalType: Value(vitalType),
      value: Value(value),
      unit: Value(unit),
      severity: Value(severity),
      vitalName: Value(vitalName),
      recordedAt: recordedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(recordedAt),
    );
  }

  factory VitalHistory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VitalHistory(
      id: serializer.fromJson<String>(json['id']),
      vitalType: serializer.fromJson<String>(json['vitalType']),
      value: serializer.fromJson<String>(json['value']),
      unit: serializer.fromJson<String>(json['unit']),
      severity: serializer.fromJson<String>(json['severity']),
      vitalName: serializer.fromJson<String>(json['vitalName']),
      recordedAt: serializer.fromJson<DateTime?>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vitalType': serializer.toJson<String>(vitalType),
      'value': serializer.toJson<String>(value),
      'unit': serializer.toJson<String>(unit),
      'severity': serializer.toJson<String>(severity),
      'vitalName': serializer.toJson<String>(vitalName),
      'recordedAt': serializer.toJson<DateTime?>(recordedAt),
    };
  }

  VitalHistory copyWith(
          {String? id,
          String? vitalType,
          String? value,
          String? unit,
          String? severity,
          String? vitalName,
          Value<DateTime?> recordedAt = const Value.absent()}) =>
      VitalHistory(
        id: id ?? this.id,
        vitalType: vitalType ?? this.vitalType,
        value: value ?? this.value,
        unit: unit ?? this.unit,
        severity: severity ?? this.severity,
        vitalName: vitalName ?? this.vitalName,
        recordedAt: recordedAt.present ? recordedAt.value : this.recordedAt,
      );
  VitalHistory copyWithCompanion(VitalHistoriesCompanion data) {
    return VitalHistory(
      id: data.id.present ? data.id.value : this.id,
      vitalType: data.vitalType.present ? data.vitalType.value : this.vitalType,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      severity: data.severity.present ? data.severity.value : this.severity,
      vitalName: data.vitalName.present ? data.vitalName.value : this.vitalName,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VitalHistory(')
          ..write('id: $id, ')
          ..write('vitalType: $vitalType, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('severity: $severity, ')
          ..write('vitalName: $vitalName, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vitalType, value, unit, severity, vitalName, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VitalHistory &&
          other.id == this.id &&
          other.vitalType == this.vitalType &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.severity == this.severity &&
          other.vitalName == this.vitalName &&
          other.recordedAt == this.recordedAt);
}

class VitalHistoriesCompanion extends UpdateCompanion<VitalHistory> {
  final Value<String> id;
  final Value<String> vitalType;
  final Value<String> value;
  final Value<String> unit;
  final Value<String> severity;
  final Value<String> vitalName;
  final Value<DateTime?> recordedAt;
  final Value<int> rowid;
  const VitalHistoriesCompanion({
    this.id = const Value.absent(),
    this.vitalType = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.severity = const Value.absent(),
    this.vitalName = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VitalHistoriesCompanion.insert({
    required String id,
    required String vitalType,
    required String value,
    required String unit,
    required String severity,
    required String vitalName,
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        vitalType = Value(vitalType),
        value = Value(value),
        unit = Value(unit),
        severity = Value(severity),
        vitalName = Value(vitalName);
  static Insertable<VitalHistory> custom({
    Expression<String>? id,
    Expression<String>? vitalType,
    Expression<String>? value,
    Expression<String>? unit,
    Expression<String>? severity,
    Expression<String>? vitalName,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vitalType != null) 'vital_type': vitalType,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (severity != null) 'severity': severity,
      if (vitalName != null) 'vital_name': vitalName,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VitalHistoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? vitalType,
      Value<String>? value,
      Value<String>? unit,
      Value<String>? severity,
      Value<String>? vitalName,
      Value<DateTime?>? recordedAt,
      Value<int>? rowid}) {
    return VitalHistoriesCompanion(
      id: id ?? this.id,
      vitalType: vitalType ?? this.vitalType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      severity: severity ?? this.severity,
      vitalName: vitalName ?? this.vitalName,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vitalType.present) {
      map['vital_type'] = Variable<String>(vitalType.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (vitalName.present) {
      map['vital_name'] = Variable<String>(vitalName.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VitalHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('vitalType: $vitalType, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('severity: $severity, ')
          ..write('vitalName: $vitalName, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiChatConversationsTable extends AiChatConversations
    with TableInfo<$AiChatConversationsTable, AiChatConversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiChatConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
      'sender', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _suggestionsJsonMeta =
      const VerificationMeta('suggestionsJson');
  @override
  late final GeneratedColumn<String> suggestionsJson = GeneratedColumn<String>(
      'suggestions_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localChatIdMeta =
      const VerificationMeta('localChatId');
  @override
  late final GeneratedColumn<String> localChatId = GeneratedColumn<String>(
      'local_chat_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioUrlMeta =
      const VerificationMeta('audioUrl');
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
      'audio_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sender,
        type,
        value,
        createdAt,
        status,
        suggestionsJson,
        localChatId,
        audioUrl
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_chat_conversations';
  @override
  VerificationContext validateIntegrity(Insertable<AiChatConversation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(_senderMeta,
          sender.isAcceptableOrUnknown(data['sender']!, _senderMeta));
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('suggestions_json')) {
      context.handle(
          _suggestionsJsonMeta,
          suggestionsJson.isAcceptableOrUnknown(
              data['suggestions_json']!, _suggestionsJsonMeta));
    }
    if (data.containsKey('local_chat_id')) {
      context.handle(
          _localChatIdMeta,
          localChatId.isAcceptableOrUnknown(
              data['local_chat_id']!, _localChatIdMeta));
    }
    if (data.containsKey('audio_url')) {
      context.handle(_audioUrlMeta,
          audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiChatConversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiChatConversation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      suggestionsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}suggestions_json']),
      localChatId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_chat_id']),
      audioUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_url']),
    );
  }

  @override
  $AiChatConversationsTable createAlias(String alias) {
    return $AiChatConversationsTable(attachedDatabase, alias);
  }
}

class AiChatConversation extends DataClass
    implements Insertable<AiChatConversation> {
  final String id;
  final String sender;
  final String type;
  final String value;
  final DateTime createdAt;
  final String status;
  final String? suggestionsJson;
  final String? localChatId;
  final String? audioUrl;
  const AiChatConversation(
      {required this.id,
      required this.sender,
      required this.type,
      required this.value,
      required this.createdAt,
      required this.status,
      this.suggestionsJson,
      this.localChatId,
      this.audioUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sender'] = Variable<String>(sender);
    map['type'] = Variable<String>(type);
    map['value'] = Variable<String>(value);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || suggestionsJson != null) {
      map['suggestions_json'] = Variable<String>(suggestionsJson);
    }
    if (!nullToAbsent || localChatId != null) {
      map['local_chat_id'] = Variable<String>(localChatId);
    }
    if (!nullToAbsent || audioUrl != null) {
      map['audio_url'] = Variable<String>(audioUrl);
    }
    return map;
  }

  AiChatConversationsCompanion toCompanion(bool nullToAbsent) {
    return AiChatConversationsCompanion(
      id: Value(id),
      sender: Value(sender),
      type: Value(type),
      value: Value(value),
      createdAt: Value(createdAt),
      status: Value(status),
      suggestionsJson: suggestionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestionsJson),
      localChatId: localChatId == null && nullToAbsent
          ? const Value.absent()
          : Value(localChatId),
      audioUrl: audioUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(audioUrl),
    );
  }

  factory AiChatConversation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiChatConversation(
      id: serializer.fromJson<String>(json['id']),
      sender: serializer.fromJson<String>(json['sender']),
      type: serializer.fromJson<String>(json['type']),
      value: serializer.fromJson<String>(json['value']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: serializer.fromJson<String>(json['status']),
      suggestionsJson: serializer.fromJson<String?>(json['suggestionsJson']),
      localChatId: serializer.fromJson<String?>(json['localChatId']),
      audioUrl: serializer.fromJson<String?>(json['audioUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sender': serializer.toJson<String>(sender),
      'type': serializer.toJson<String>(type),
      'value': serializer.toJson<String>(value),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<String>(status),
      'suggestionsJson': serializer.toJson<String?>(suggestionsJson),
      'localChatId': serializer.toJson<String?>(localChatId),
      'audioUrl': serializer.toJson<String?>(audioUrl),
    };
  }

  AiChatConversation copyWith(
          {String? id,
          String? sender,
          String? type,
          String? value,
          DateTime? createdAt,
          String? status,
          Value<String?> suggestionsJson = const Value.absent(),
          Value<String?> localChatId = const Value.absent(),
          Value<String?> audioUrl = const Value.absent()}) =>
      AiChatConversation(
        id: id ?? this.id,
        sender: sender ?? this.sender,
        type: type ?? this.type,
        value: value ?? this.value,
        createdAt: createdAt ?? this.createdAt,
        status: status ?? this.status,
        suggestionsJson: suggestionsJson.present
            ? suggestionsJson.value
            : this.suggestionsJson,
        localChatId: localChatId.present ? localChatId.value : this.localChatId,
        audioUrl: audioUrl.present ? audioUrl.value : this.audioUrl,
      );
  AiChatConversation copyWithCompanion(AiChatConversationsCompanion data) {
    return AiChatConversation(
      id: data.id.present ? data.id.value : this.id,
      sender: data.sender.present ? data.sender.value : this.sender,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
      suggestionsJson: data.suggestionsJson.present
          ? data.suggestionsJson.value
          : this.suggestionsJson,
      localChatId:
          data.localChatId.present ? data.localChatId.value : this.localChatId,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiChatConversation(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('suggestionsJson: $suggestionsJson, ')
          ..write('localChatId: $localChatId, ')
          ..write('audioUrl: $audioUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sender, type, value, createdAt, status,
      suggestionsJson, localChatId, audioUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiChatConversation &&
          other.id == this.id &&
          other.sender == this.sender &&
          other.type == this.type &&
          other.value == this.value &&
          other.createdAt == this.createdAt &&
          other.status == this.status &&
          other.suggestionsJson == this.suggestionsJson &&
          other.localChatId == this.localChatId &&
          other.audioUrl == this.audioUrl);
}

class AiChatConversationsCompanion extends UpdateCompanion<AiChatConversation> {
  final Value<String> id;
  final Value<String> sender;
  final Value<String> type;
  final Value<String> value;
  final Value<DateTime> createdAt;
  final Value<String> status;
  final Value<String?> suggestionsJson;
  final Value<String?> localChatId;
  final Value<String?> audioUrl;
  final Value<int> rowid;
  const AiChatConversationsCompanion({
    this.id = const Value.absent(),
    this.sender = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.suggestionsJson = const Value.absent(),
    this.localChatId = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiChatConversationsCompanion.insert({
    required String id,
    required String sender,
    required String type,
    required String value,
    required DateTime createdAt,
    required String status,
    this.suggestionsJson = const Value.absent(),
    this.localChatId = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sender = Value(sender),
        type = Value(type),
        value = Value(value),
        createdAt = Value(createdAt),
        status = Value(status);
  static Insertable<AiChatConversation> custom({
    Expression<String>? id,
    Expression<String>? sender,
    Expression<String>? type,
    Expression<String>? value,
    Expression<DateTime>? createdAt,
    Expression<String>? status,
    Expression<String>? suggestionsJson,
    Expression<String>? localChatId,
    Expression<String>? audioUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sender != null) 'sender': sender,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
      if (suggestionsJson != null) 'suggestions_json': suggestionsJson,
      if (localChatId != null) 'local_chat_id': localChatId,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiChatConversationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sender,
      Value<String>? type,
      Value<String>? value,
      Value<DateTime>? createdAt,
      Value<String>? status,
      Value<String?>? suggestionsJson,
      Value<String?>? localChatId,
      Value<String?>? audioUrl,
      Value<int>? rowid}) {
    return AiChatConversationsCompanion(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      suggestionsJson: suggestionsJson ?? this.suggestionsJson,
      localChatId: localChatId ?? this.localChatId,
      audioUrl: audioUrl ?? this.audioUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (suggestionsJson.present) {
      map['suggestions_json'] = Variable<String>(suggestionsJson.value);
    }
    if (localChatId.present) {
      map['local_chat_id'] = Variable<String>(localChatId.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiChatConversationsCompanion(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('suggestionsJson: $suggestionsJson, ')
          ..write('localChatId: $localChatId, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingDeletionsTable extends PendingDeletions
    with TableInfo<$PendingDeletionsTable, PendingDeletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingDeletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
      'message_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [messageId, source];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_deletions';
  @override
  VerificationContext validateIntegrity(Insertable<PendingDeletion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId, source};
  @override
  PendingDeletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingDeletion(
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_id'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
    );
  }

  @override
  $PendingDeletionsTable createAlias(String alias) {
    return $PendingDeletionsTable(attachedDatabase, alias);
  }
}

class PendingDeletion extends DataClass implements Insertable<PendingDeletion> {
  final String messageId;
  final String source;
  const PendingDeletion({required this.messageId, required this.source});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<String>(messageId);
    map['source'] = Variable<String>(source);
    return map;
  }

  PendingDeletionsCompanion toCompanion(bool nullToAbsent) {
    return PendingDeletionsCompanion(
      messageId: Value(messageId),
      source: Value(source),
    );
  }

  factory PendingDeletion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingDeletion(
      messageId: serializer.fromJson<String>(json['messageId']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<String>(messageId),
      'source': serializer.toJson<String>(source),
    };
  }

  PendingDeletion copyWith({String? messageId, String? source}) =>
      PendingDeletion(
        messageId: messageId ?? this.messageId,
        source: source ?? this.source,
      );
  PendingDeletion copyWithCompanion(PendingDeletionsCompanion data) {
    return PendingDeletion(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingDeletion(')
          ..write('messageId: $messageId, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(messageId, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingDeletion &&
          other.messageId == this.messageId &&
          other.source == this.source);
}

class PendingDeletionsCompanion extends UpdateCompanion<PendingDeletion> {
  final Value<String> messageId;
  final Value<String> source;
  final Value<int> rowid;
  const PendingDeletionsCompanion({
    this.messageId = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingDeletionsCompanion.insert({
    required String messageId,
    required String source,
    this.rowid = const Value.absent(),
  })  : messageId = Value(messageId),
        source = Value(source);
  static Insertable<PendingDeletion> custom({
    Expression<String>? messageId,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingDeletionsCompanion copyWith(
      {Value<String>? messageId, Value<String>? source, Value<int>? rowid}) {
    return PendingDeletionsCompanion(
      messageId: messageId ?? this.messageId,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingDeletionsCompanion(')
          ..write('messageId: $messageId, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _conditionsJsonMeta =
      const VerificationMeta('conditionsJson');
  @override
  late final GeneratedColumn<String> conditionsJson = GeneratedColumn<String>(
      'conditions_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _hasConsentedMeta =
      const VerificationMeta('hasConsented');
  @override
  late final GeneratedColumn<bool> hasConsented = GeneratedColumn<bool>(
      'has_consented', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_consented" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _registrationStatusMeta =
      const VerificationMeta('registrationStatus');
  @override
  late final GeneratedColumn<String> registrationStatus =
      GeneratedColumn<String>('registration_status', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('personalDetails'));
  static const VerificationMeta _modeOfRegistrationMeta =
      const VerificationMeta('modeOfRegistration');
  @override
  late final GeneratedColumn<String> modeOfRegistration =
      GeneratedColumn<String>('mode_of_registration', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        email,
        firstName,
        lastName,
        gender,
        dateOfBirth,
        conditionsJson,
        hasConsented,
        registrationStatus,
        modeOfRegistration,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    }
    if (data.containsKey('conditions_json')) {
      context.handle(
          _conditionsJsonMeta,
          conditionsJson.isAcceptableOrUnknown(
              data['conditions_json']!, _conditionsJsonMeta));
    }
    if (data.containsKey('has_consented')) {
      context.handle(
          _hasConsentedMeta,
          hasConsented.isAcceptableOrUnknown(
              data['has_consented']!, _hasConsentedMeta));
    }
    if (data.containsKey('registration_status')) {
      context.handle(
          _registrationStatusMeta,
          registrationStatus.isAcceptableOrUnknown(
              data['registration_status']!, _registrationStatusMeta));
    }
    if (data.containsKey('mode_of_registration')) {
      context.handle(
          _modeOfRegistrationMeta,
          modeOfRegistration.isAcceptableOrUnknown(
              data['mode_of_registration']!, _modeOfRegistrationMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name']),
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      dateOfBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth']),
      conditionsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conditions_json'])!,
      hasConsented: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_consented'])!,
      registrationStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}registration_status'])!,
      modeOfRegistration: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}mode_of_registration']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String conditionsJson;
  final bool hasConsented;
  final String registrationStatus;
  final String? modeOfRegistration;
  final DateTime? createdAt;
  const UserProfile(
      {required this.id,
      required this.email,
      this.firstName,
      this.lastName,
      this.gender,
      this.dateOfBirth,
      required this.conditionsJson,
      required this.hasConsented,
      required this.registrationStatus,
      this.modeOfRegistration,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    map['conditions_json'] = Variable<String>(conditionsJson);
    map['has_consented'] = Variable<bool>(hasConsented);
    map['registration_status'] = Variable<String>(registrationStatus);
    if (!nullToAbsent || modeOfRegistration != null) {
      map['mode_of_registration'] = Variable<String>(modeOfRegistration);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      email: Value(email),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      conditionsJson: Value(conditionsJson),
      hasConsented: Value(hasConsented),
      registrationStatus: Value(registrationStatus),
      modeOfRegistration: modeOfRegistration == null && nullToAbsent
          ? const Value.absent()
          : Value(modeOfRegistration),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      gender: serializer.fromJson<String?>(json['gender']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      conditionsJson: serializer.fromJson<String>(json['conditionsJson']),
      hasConsented: serializer.fromJson<bool>(json['hasConsented']),
      registrationStatus:
          serializer.fromJson<String>(json['registrationStatus']),
      modeOfRegistration:
          serializer.fromJson<String?>(json['modeOfRegistration']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'firstName': serializer.toJson<String?>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'gender': serializer.toJson<String?>(gender),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'conditionsJson': serializer.toJson<String>(conditionsJson),
      'hasConsented': serializer.toJson<bool>(hasConsented),
      'registrationStatus': serializer.toJson<String>(registrationStatus),
      'modeOfRegistration': serializer.toJson<String?>(modeOfRegistration),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  UserProfile copyWith(
          {String? id,
          String? email,
          Value<String?> firstName = const Value.absent(),
          Value<String?> lastName = const Value.absent(),
          Value<String?> gender = const Value.absent(),
          Value<DateTime?> dateOfBirth = const Value.absent(),
          String? conditionsJson,
          bool? hasConsented,
          String? registrationStatus,
          Value<String?> modeOfRegistration = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent()}) =>
      UserProfile(
        id: id ?? this.id,
        email: email ?? this.email,
        firstName: firstName.present ? firstName.value : this.firstName,
        lastName: lastName.present ? lastName.value : this.lastName,
        gender: gender.present ? gender.value : this.gender,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
        conditionsJson: conditionsJson ?? this.conditionsJson,
        hasConsented: hasConsented ?? this.hasConsented,
        registrationStatus: registrationStatus ?? this.registrationStatus,
        modeOfRegistration: modeOfRegistration.present
            ? modeOfRegistration.value
            : this.modeOfRegistration,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      gender: data.gender.present ? data.gender.value : this.gender,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      conditionsJson: data.conditionsJson.present
          ? data.conditionsJson.value
          : this.conditionsJson,
      hasConsented: data.hasConsented.present
          ? data.hasConsented.value
          : this.hasConsented,
      registrationStatus: data.registrationStatus.present
          ? data.registrationStatus.value
          : this.registrationStatus,
      modeOfRegistration: data.modeOfRegistration.present
          ? data.modeOfRegistration.value
          : this.modeOfRegistration,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('gender: $gender, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('hasConsented: $hasConsented, ')
          ..write('registrationStatus: $registrationStatus, ')
          ..write('modeOfRegistration: $modeOfRegistration, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      email,
      firstName,
      lastName,
      gender,
      dateOfBirth,
      conditionsJson,
      hasConsented,
      registrationStatus,
      modeOfRegistration,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.email == this.email &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.gender == this.gender &&
          other.dateOfBirth == this.dateOfBirth &&
          other.conditionsJson == this.conditionsJson &&
          other.hasConsented == this.hasConsented &&
          other.registrationStatus == this.registrationStatus &&
          other.modeOfRegistration == this.modeOfRegistration &&
          other.createdAt == this.createdAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String> email;
  final Value<String?> firstName;
  final Value<String?> lastName;
  final Value<String?> gender;
  final Value<DateTime?> dateOfBirth;
  final Value<String> conditionsJson;
  final Value<bool> hasConsented;
  final Value<String> registrationStatus;
  final Value<String?> modeOfRegistration;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.gender = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.conditionsJson = const Value.absent(),
    this.hasConsented = const Value.absent(),
    this.registrationStatus = const Value.absent(),
    this.modeOfRegistration = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String email,
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.gender = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.conditionsJson = const Value.absent(),
    this.hasConsented = const Value.absent(),
    this.registrationStatus = const Value.absent(),
    this.modeOfRegistration = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? gender,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? conditionsJson,
    Expression<bool>? hasConsented,
    Expression<String>? registrationStatus,
    Expression<String>? modeOfRegistration,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (conditionsJson != null) 'conditions_json': conditionsJson,
      if (hasConsented != null) 'has_consented': hasConsented,
      if (registrationStatus != null) 'registration_status': registrationStatus,
      if (modeOfRegistration != null)
        'mode_of_registration': modeOfRegistration,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String?>? firstName,
      Value<String?>? lastName,
      Value<String?>? gender,
      Value<DateTime?>? dateOfBirth,
      Value<String>? conditionsJson,
      Value<bool>? hasConsented,
      Value<String>? registrationStatus,
      Value<String?>? modeOfRegistration,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      conditionsJson: conditionsJson ?? this.conditionsJson,
      hasConsented: hasConsented ?? this.hasConsented,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      modeOfRegistration: modeOfRegistration ?? this.modeOfRegistration,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (conditionsJson.present) {
      map['conditions_json'] = Variable<String>(conditionsJson.value);
    }
    if (hasConsented.present) {
      map['has_consented'] = Variable<bool>(hasConsented.value);
    }
    if (registrationStatus.present) {
      map['registration_status'] = Variable<String>(registrationStatus.value);
    }
    if (modeOfRegistration.present) {
      map['mode_of_registration'] = Variable<String>(modeOfRegistration.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('gender: $gender, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('hasConsented: $hasConsented, ')
          ..write('registrationStatus: $registrationStatus, ')
          ..write('modeOfRegistration: $modeOfRegistration, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingMutationsTable extends PendingMutations
    with TableInfo<$PendingMutationsTable, PendingMutation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingMutationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, entityType, entityId, action, payloadJson, createdAt, retryCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_mutations';
  @override
  VerificationContext validateIntegrity(Insertable<PendingMutation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingMutation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingMutation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
    );
  }

  @override
  $PendingMutationsTable createAlias(String alias) {
    return $PendingMutationsTable(attachedDatabase, alias);
  }
}

class PendingMutation extends DataClass implements Insertable<PendingMutation> {
  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final String payloadJson;
  final DateTime createdAt;
  final int retryCount;
  const PendingMutation(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.action,
      required this.payloadJson,
      required this.createdAt,
      required this.retryCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  PendingMutationsCompanion toCompanion(bool nullToAbsent) {
    return PendingMutationsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory PendingMutation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingMutation(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  PendingMutation copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          String? action,
          String? payloadJson,
          DateTime? createdAt,
          int? retryCount}) =>
      PendingMutation(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        action: action ?? this.action,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
      );
  PendingMutation copyWithCompanion(PendingMutationsCompanion data) {
    return PendingMutation(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingMutation(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entityType, entityId, action, payloadJson, createdAt, retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingMutation &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class PendingMutationsCompanion extends UpdateCompanion<PendingMutation> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<int> rowid;
  const PendingMutationsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingMutationsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String action,
    required String payloadJson,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        action = Value(action),
        payloadJson = Value(payloadJson),
        createdAt = Value(createdAt);
  static Insertable<PendingMutation> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingMutationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? action,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<int>? rowid}) {
    return PendingMutationsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingMutationsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
      'dosage', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purposeMeta =
      const VerificationMeta('purpose');
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
      'purpose', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toBeTakenAtMeta =
      const VerificationMeta('toBeTakenAt');
  @override
  late final GeneratedColumn<DateTime> toBeTakenAt = GeneratedColumn<DateTime>(
      'to_be_taken_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _takenMeta = const VerificationMeta('taken');
  @override
  late final GeneratedColumn<bool> taken = GeneratedColumn<bool>(
      'taken', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("taken" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, dosage, purpose, toBeTakenAt, taken];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(Insertable<Medication> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(_dosageMeta,
          dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta));
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(_purposeMeta,
          purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta));
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('to_be_taken_at')) {
      context.handle(
          _toBeTakenAtMeta,
          toBeTakenAt.isAcceptableOrUnknown(
              data['to_be_taken_at']!, _toBeTakenAtMeta));
    } else if (isInserting) {
      context.missing(_toBeTakenAtMeta);
    }
    if (data.containsKey('taken')) {
      context.handle(
          _takenMeta, taken.isAcceptableOrUnknown(data['taken']!, _takenMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dosage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dosage'])!,
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose'])!,
      toBeTakenAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}to_be_taken_at'])!,
      taken: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}taken'])!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final String id;
  final String name;
  final String dosage;
  final String purpose;
  final DateTime toBeTakenAt;
  final bool taken;
  const Medication(
      {required this.id,
      required this.name,
      required this.dosage,
      required this.purpose,
      required this.toBeTakenAt,
      required this.taken});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['dosage'] = Variable<String>(dosage);
    map['purpose'] = Variable<String>(purpose);
    map['to_be_taken_at'] = Variable<DateTime>(toBeTakenAt);
    map['taken'] = Variable<bool>(taken);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      name: Value(name),
      dosage: Value(dosage),
      purpose: Value(purpose),
      toBeTakenAt: Value(toBeTakenAt),
      taken: Value(taken),
    );
  }

  factory Medication.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dosage: serializer.fromJson<String>(json['dosage']),
      purpose: serializer.fromJson<String>(json['purpose']),
      toBeTakenAt: serializer.fromJson<DateTime>(json['toBeTakenAt']),
      taken: serializer.fromJson<bool>(json['taken']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<String>(dosage),
      'purpose': serializer.toJson<String>(purpose),
      'toBeTakenAt': serializer.toJson<DateTime>(toBeTakenAt),
      'taken': serializer.toJson<bool>(taken),
    };
  }

  Medication copyWith(
          {String? id,
          String? name,
          String? dosage,
          String? purpose,
          DateTime? toBeTakenAt,
          bool? taken}) =>
      Medication(
        id: id ?? this.id,
        name: name ?? this.name,
        dosage: dosage ?? this.dosage,
        purpose: purpose ?? this.purpose,
        toBeTakenAt: toBeTakenAt ?? this.toBeTakenAt,
        taken: taken ?? this.taken,
      );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      toBeTakenAt:
          data.toBeTakenAt.present ? data.toBeTakenAt.value : this.toBeTakenAt,
      taken: data.taken.present ? data.taken.value : this.taken,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('purpose: $purpose, ')
          ..write('toBeTakenAt: $toBeTakenAt, ')
          ..write('taken: $taken')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, dosage, purpose, toBeTakenAt, taken);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.name == this.name &&
          other.dosage == this.dosage &&
          other.purpose == this.purpose &&
          other.toBeTakenAt == this.toBeTakenAt &&
          other.taken == this.taken);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> dosage;
  final Value<String> purpose;
  final Value<DateTime> toBeTakenAt;
  final Value<bool> taken;
  final Value<int> rowid;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.purpose = const Value.absent(),
    this.toBeTakenAt = const Value.absent(),
    this.taken = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationsCompanion.insert({
    required String id,
    required String name,
    required String dosage,
    required String purpose,
    required DateTime toBeTakenAt,
    this.taken = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        dosage = Value(dosage),
        purpose = Value(purpose),
        toBeTakenAt = Value(toBeTakenAt);
  static Insertable<Medication> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? dosage,
    Expression<String>? purpose,
    Expression<DateTime>? toBeTakenAt,
    Expression<bool>? taken,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (purpose != null) 'purpose': purpose,
      if (toBeTakenAt != null) 'to_be_taken_at': toBeTakenAt,
      if (taken != null) 'taken': taken,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? dosage,
      Value<String>? purpose,
      Value<DateTime>? toBeTakenAt,
      Value<bool>? taken,
      Value<int>? rowid}) {
    return MedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      purpose: purpose ?? this.purpose,
      toBeTakenAt: toBeTakenAt ?? this.toBeTakenAt,
      taken: taken ?? this.taken,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (toBeTakenAt.present) {
      map['to_be_taken_at'] = Variable<DateTime>(toBeTakenAt.value);
    }
    if (taken.present) {
      map['taken'] = Variable<bool>(taken.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('purpose: $purpose, ')
          ..write('toBeTakenAt: $toBeTakenAt, ')
          ..write('taken: $taken, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppointmentsTable extends Appointments
    with TableInfo<$AppointmentsTable, Appointment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appointmentDateMeta =
      const VerificationMeta('appointmentDate');
  @override
  late final GeneratedColumn<DateTime> appointmentDate =
      GeneratedColumn<DateTime>('appointment_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _hostPersonnelIdMeta =
      const VerificationMeta('hostPersonnelId');
  @override
  late final GeneratedColumn<String> hostPersonnelId = GeneratedColumn<String>(
      'host_personnel_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hostPersonnelUserNameMeta =
      const VerificationMeta('hostPersonnelUserName');
  @override
  late final GeneratedColumn<String> hostPersonnelUserName =
      GeneratedColumn<String>('host_personnel_user_name', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hostPersonnelFacilityNameMeta =
      const VerificationMeta('hostPersonnelFacilityName');
  @override
  late final GeneratedColumn<String> hostPersonnelFacilityName =
      GeneratedColumn<String>(
          'host_personnel_facility_name', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        appointmentDate,
        hostPersonnelId,
        hostPersonnelUserName,
        hostPersonnelFacilityName
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(Insertable<Appointment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('appointment_date')) {
      context.handle(
          _appointmentDateMeta,
          appointmentDate.isAcceptableOrUnknown(
              data['appointment_date']!, _appointmentDateMeta));
    } else if (isInserting) {
      context.missing(_appointmentDateMeta);
    }
    if (data.containsKey('host_personnel_id')) {
      context.handle(
          _hostPersonnelIdMeta,
          hostPersonnelId.isAcceptableOrUnknown(
              data['host_personnel_id']!, _hostPersonnelIdMeta));
    } else if (isInserting) {
      context.missing(_hostPersonnelIdMeta);
    }
    if (data.containsKey('host_personnel_user_name')) {
      context.handle(
          _hostPersonnelUserNameMeta,
          hostPersonnelUserName.isAcceptableOrUnknown(
              data['host_personnel_user_name']!, _hostPersonnelUserNameMeta));
    } else if (isInserting) {
      context.missing(_hostPersonnelUserNameMeta);
    }
    if (data.containsKey('host_personnel_facility_name')) {
      context.handle(
          _hostPersonnelFacilityNameMeta,
          hostPersonnelFacilityName.isAcceptableOrUnknown(
              data['host_personnel_facility_name']!,
              _hostPersonnelFacilityNameMeta));
    } else if (isInserting) {
      context.missing(_hostPersonnelFacilityNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Appointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appointment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      appointmentDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}appointment_date'])!,
      hostPersonnelId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}host_personnel_id'])!,
      hostPersonnelUserName: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}host_personnel_user_name'])!,
      hostPersonnelFacilityName: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}host_personnel_facility_name'])!,
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }
}

class Appointment extends DataClass implements Insertable<Appointment> {
  final String id;
  final String title;
  final DateTime appointmentDate;
  final String hostPersonnelId;
  final String hostPersonnelUserName;
  final String hostPersonnelFacilityName;
  const Appointment(
      {required this.id,
      required this.title,
      required this.appointmentDate,
      required this.hostPersonnelId,
      required this.hostPersonnelUserName,
      required this.hostPersonnelFacilityName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['appointment_date'] = Variable<DateTime>(appointmentDate);
    map['host_personnel_id'] = Variable<String>(hostPersonnelId);
    map['host_personnel_user_name'] = Variable<String>(hostPersonnelUserName);
    map['host_personnel_facility_name'] =
        Variable<String>(hostPersonnelFacilityName);
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      title: Value(title),
      appointmentDate: Value(appointmentDate),
      hostPersonnelId: Value(hostPersonnelId),
      hostPersonnelUserName: Value(hostPersonnelUserName),
      hostPersonnelFacilityName: Value(hostPersonnelFacilityName),
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appointment(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      appointmentDate: serializer.fromJson<DateTime>(json['appointmentDate']),
      hostPersonnelId: serializer.fromJson<String>(json['hostPersonnelId']),
      hostPersonnelUserName:
          serializer.fromJson<String>(json['hostPersonnelUserName']),
      hostPersonnelFacilityName:
          serializer.fromJson<String>(json['hostPersonnelFacilityName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'appointmentDate': serializer.toJson<DateTime>(appointmentDate),
      'hostPersonnelId': serializer.toJson<String>(hostPersonnelId),
      'hostPersonnelUserName': serializer.toJson<String>(hostPersonnelUserName),
      'hostPersonnelFacilityName':
          serializer.toJson<String>(hostPersonnelFacilityName),
    };
  }

  Appointment copyWith(
          {String? id,
          String? title,
          DateTime? appointmentDate,
          String? hostPersonnelId,
          String? hostPersonnelUserName,
          String? hostPersonnelFacilityName}) =>
      Appointment(
        id: id ?? this.id,
        title: title ?? this.title,
        appointmentDate: appointmentDate ?? this.appointmentDate,
        hostPersonnelId: hostPersonnelId ?? this.hostPersonnelId,
        hostPersonnelUserName:
            hostPersonnelUserName ?? this.hostPersonnelUserName,
        hostPersonnelFacilityName:
            hostPersonnelFacilityName ?? this.hostPersonnelFacilityName,
      );
  Appointment copyWithCompanion(AppointmentsCompanion data) {
    return Appointment(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      appointmentDate: data.appointmentDate.present
          ? data.appointmentDate.value
          : this.appointmentDate,
      hostPersonnelId: data.hostPersonnelId.present
          ? data.hostPersonnelId.value
          : this.hostPersonnelId,
      hostPersonnelUserName: data.hostPersonnelUserName.present
          ? data.hostPersonnelUserName.value
          : this.hostPersonnelUserName,
      hostPersonnelFacilityName: data.hostPersonnelFacilityName.present
          ? data.hostPersonnelFacilityName.value
          : this.hostPersonnelFacilityName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appointment(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('appointmentDate: $appointmentDate, ')
          ..write('hostPersonnelId: $hostPersonnelId, ')
          ..write('hostPersonnelUserName: $hostPersonnelUserName, ')
          ..write('hostPersonnelFacilityName: $hostPersonnelFacilityName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, appointmentDate, hostPersonnelId,
      hostPersonnelUserName, hostPersonnelFacilityName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appointment &&
          other.id == this.id &&
          other.title == this.title &&
          other.appointmentDate == this.appointmentDate &&
          other.hostPersonnelId == this.hostPersonnelId &&
          other.hostPersonnelUserName == this.hostPersonnelUserName &&
          other.hostPersonnelFacilityName == this.hostPersonnelFacilityName);
}

class AppointmentsCompanion extends UpdateCompanion<Appointment> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> appointmentDate;
  final Value<String> hostPersonnelId;
  final Value<String> hostPersonnelUserName;
  final Value<String> hostPersonnelFacilityName;
  final Value<int> rowid;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.appointmentDate = const Value.absent(),
    this.hostPersonnelId = const Value.absent(),
    this.hostPersonnelUserName = const Value.absent(),
    this.hostPersonnelFacilityName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    required String id,
    required String title,
    required DateTime appointmentDate,
    required String hostPersonnelId,
    required String hostPersonnelUserName,
    required String hostPersonnelFacilityName,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        appointmentDate = Value(appointmentDate),
        hostPersonnelId = Value(hostPersonnelId),
        hostPersonnelUserName = Value(hostPersonnelUserName),
        hostPersonnelFacilityName = Value(hostPersonnelFacilityName);
  static Insertable<Appointment> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? appointmentDate,
    Expression<String>? hostPersonnelId,
    Expression<String>? hostPersonnelUserName,
    Expression<String>? hostPersonnelFacilityName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (appointmentDate != null) 'appointment_date': appointmentDate,
      if (hostPersonnelId != null) 'host_personnel_id': hostPersonnelId,
      if (hostPersonnelUserName != null)
        'host_personnel_user_name': hostPersonnelUserName,
      if (hostPersonnelFacilityName != null)
        'host_personnel_facility_name': hostPersonnelFacilityName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppointmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<DateTime>? appointmentDate,
      Value<String>? hostPersonnelId,
      Value<String>? hostPersonnelUserName,
      Value<String>? hostPersonnelFacilityName,
      Value<int>? rowid}) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      hostPersonnelId: hostPersonnelId ?? this.hostPersonnelId,
      hostPersonnelUserName:
          hostPersonnelUserName ?? this.hostPersonnelUserName,
      hostPersonnelFacilityName:
          hostPersonnelFacilityName ?? this.hostPersonnelFacilityName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (appointmentDate.present) {
      map['appointment_date'] = Variable<DateTime>(appointmentDate.value);
    }
    if (hostPersonnelId.present) {
      map['host_personnel_id'] = Variable<String>(hostPersonnelId.value);
    }
    if (hostPersonnelUserName.present) {
      map['host_personnel_user_name'] =
          Variable<String>(hostPersonnelUserName.value);
    }
    if (hostPersonnelFacilityName.present) {
      map['host_personnel_facility_name'] =
          Variable<String>(hostPersonnelFacilityName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('appointmentDate: $appointmentDate, ')
          ..write('hostPersonnelId: $hostPersonnelId, ')
          ..write('hostPersonnelUserName: $hostPersonnelUserName, ')
          ..write('hostPersonnelFacilityName: $hostPersonnelFacilityName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VitalHistoriesTable vitalHistories = $VitalHistoriesTable(this);
  late final $AiChatConversationsTable aiChatConversations =
      $AiChatConversationsTable(this);
  late final $PendingDeletionsTable pendingDeletions =
      $PendingDeletionsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $PendingMutationsTable pendingMutations =
      $PendingMutationsTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  late final VitalsDao vitalsDao = VitalsDao(this as AppDatabase);
  late final AiChatDao aiChatDao = AiChatDao(this as AppDatabase);
  late final UserProfilesDao userProfilesDao =
      UserProfilesDao(this as AppDatabase);
  late final PendingMutationsDao pendingMutationsDao =
      PendingMutationsDao(this as AppDatabase);
  late final MedicationsDao medicationsDao =
      MedicationsDao(this as AppDatabase);
  late final AppointmentsDao appointmentsDao =
      AppointmentsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        vitalHistories,
        aiChatConversations,
        pendingDeletions,
        userProfiles,
        pendingMutations,
        medications,
        appointments
      ];
}

typedef $$VitalHistoriesTableCreateCompanionBuilder = VitalHistoriesCompanion
    Function({
  required String id,
  required String vitalType,
  required String value,
  required String unit,
  required String severity,
  required String vitalName,
  Value<DateTime?> recordedAt,
  Value<int> rowid,
});
typedef $$VitalHistoriesTableUpdateCompanionBuilder = VitalHistoriesCompanion
    Function({
  Value<String> id,
  Value<String> vitalType,
  Value<String> value,
  Value<String> unit,
  Value<String> severity,
  Value<String> vitalName,
  Value<DateTime?> recordedAt,
  Value<int> rowid,
});

class $$VitalHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $VitalHistoriesTable> {
  $$VitalHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vitalType => $composableBuilder(
      column: $table.vitalType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vitalName => $composableBuilder(
      column: $table.vitalName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));
}

class $$VitalHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $VitalHistoriesTable> {
  $$VitalHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vitalType => $composableBuilder(
      column: $table.vitalType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vitalName => $composableBuilder(
      column: $table.vitalName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));
}

class $$VitalHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VitalHistoriesTable> {
  $$VitalHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vitalType =>
      $composableBuilder(column: $table.vitalType, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get vitalName =>
      $composableBuilder(column: $table.vitalName, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);
}

class $$VitalHistoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VitalHistoriesTable,
    VitalHistory,
    $$VitalHistoriesTableFilterComposer,
    $$VitalHistoriesTableOrderingComposer,
    $$VitalHistoriesTableAnnotationComposer,
    $$VitalHistoriesTableCreateCompanionBuilder,
    $$VitalHistoriesTableUpdateCompanionBuilder,
    (
      VitalHistory,
      BaseReferences<_$AppDatabase, $VitalHistoriesTable, VitalHistory>
    ),
    VitalHistory,
    PrefetchHooks Function()> {
  $$VitalHistoriesTableTableManager(
      _$AppDatabase db, $VitalHistoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VitalHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VitalHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VitalHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> vitalType = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<String> vitalName = const Value.absent(),
            Value<DateTime?> recordedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VitalHistoriesCompanion(
            id: id,
            vitalType: vitalType,
            value: value,
            unit: unit,
            severity: severity,
            vitalName: vitalName,
            recordedAt: recordedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String vitalType,
            required String value,
            required String unit,
            required String severity,
            required String vitalName,
            Value<DateTime?> recordedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VitalHistoriesCompanion.insert(
            id: id,
            vitalType: vitalType,
            value: value,
            unit: unit,
            severity: severity,
            vitalName: vitalName,
            recordedAt: recordedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VitalHistoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VitalHistoriesTable,
    VitalHistory,
    $$VitalHistoriesTableFilterComposer,
    $$VitalHistoriesTableOrderingComposer,
    $$VitalHistoriesTableAnnotationComposer,
    $$VitalHistoriesTableCreateCompanionBuilder,
    $$VitalHistoriesTableUpdateCompanionBuilder,
    (
      VitalHistory,
      BaseReferences<_$AppDatabase, $VitalHistoriesTable, VitalHistory>
    ),
    VitalHistory,
    PrefetchHooks Function()>;
typedef $$AiChatConversationsTableCreateCompanionBuilder
    = AiChatConversationsCompanion Function({
  required String id,
  required String sender,
  required String type,
  required String value,
  required DateTime createdAt,
  required String status,
  Value<String?> suggestionsJson,
  Value<String?> localChatId,
  Value<String?> audioUrl,
  Value<int> rowid,
});
typedef $$AiChatConversationsTableUpdateCompanionBuilder
    = AiChatConversationsCompanion Function({
  Value<String> id,
  Value<String> sender,
  Value<String> type,
  Value<String> value,
  Value<DateTime> createdAt,
  Value<String> status,
  Value<String?> suggestionsJson,
  Value<String?> localChatId,
  Value<String?> audioUrl,
  Value<int> rowid,
});

class $$AiChatConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $AiChatConversationsTable> {
  $$AiChatConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sender => $composableBuilder(
      column: $table.sender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestionsJson => $composableBuilder(
      column: $table.suggestionsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localChatId => $composableBuilder(
      column: $table.localChatId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnFilters(column));
}

class $$AiChatConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiChatConversationsTable> {
  $$AiChatConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sender => $composableBuilder(
      column: $table.sender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestionsJson => $composableBuilder(
      column: $table.suggestionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localChatId => $composableBuilder(
      column: $table.localChatId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnOrderings(column));
}

class $$AiChatConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiChatConversationsTable> {
  $$AiChatConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get suggestionsJson => $composableBuilder(
      column: $table.suggestionsJson, builder: (column) => column);

  GeneratedColumn<String> get localChatId => $composableBuilder(
      column: $table.localChatId, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);
}

class $$AiChatConversationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiChatConversationsTable,
    AiChatConversation,
    $$AiChatConversationsTableFilterComposer,
    $$AiChatConversationsTableOrderingComposer,
    $$AiChatConversationsTableAnnotationComposer,
    $$AiChatConversationsTableCreateCompanionBuilder,
    $$AiChatConversationsTableUpdateCompanionBuilder,
    (
      AiChatConversation,
      BaseReferences<_$AppDatabase, $AiChatConversationsTable,
          AiChatConversation>
    ),
    AiChatConversation,
    PrefetchHooks Function()> {
  $$AiChatConversationsTableTableManager(
      _$AppDatabase db, $AiChatConversationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiChatConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiChatConversationsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiChatConversationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sender = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> suggestionsJson = const Value.absent(),
            Value<String?> localChatId = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AiChatConversationsCompanion(
            id: id,
            sender: sender,
            type: type,
            value: value,
            createdAt: createdAt,
            status: status,
            suggestionsJson: suggestionsJson,
            localChatId: localChatId,
            audioUrl: audioUrl,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sender,
            required String type,
            required String value,
            required DateTime createdAt,
            required String status,
            Value<String?> suggestionsJson = const Value.absent(),
            Value<String?> localChatId = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AiChatConversationsCompanion.insert(
            id: id,
            sender: sender,
            type: type,
            value: value,
            createdAt: createdAt,
            status: status,
            suggestionsJson: suggestionsJson,
            localChatId: localChatId,
            audioUrl: audioUrl,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AiChatConversationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AiChatConversationsTable,
    AiChatConversation,
    $$AiChatConversationsTableFilterComposer,
    $$AiChatConversationsTableOrderingComposer,
    $$AiChatConversationsTableAnnotationComposer,
    $$AiChatConversationsTableCreateCompanionBuilder,
    $$AiChatConversationsTableUpdateCompanionBuilder,
    (
      AiChatConversation,
      BaseReferences<_$AppDatabase, $AiChatConversationsTable,
          AiChatConversation>
    ),
    AiChatConversation,
    PrefetchHooks Function()>;
typedef $$PendingDeletionsTableCreateCompanionBuilder
    = PendingDeletionsCompanion Function({
  required String messageId,
  required String source,
  Value<int> rowid,
});
typedef $$PendingDeletionsTableUpdateCompanionBuilder
    = PendingDeletionsCompanion Function({
  Value<String> messageId,
  Value<String> source,
  Value<int> rowid,
});

class $$PendingDeletionsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingDeletionsTable> {
  $$PendingDeletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));
}

class $$PendingDeletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingDeletionsTable> {
  $$PendingDeletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));
}

class $$PendingDeletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingDeletionsTable> {
  $$PendingDeletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$PendingDeletionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingDeletionsTable,
    PendingDeletion,
    $$PendingDeletionsTableFilterComposer,
    $$PendingDeletionsTableOrderingComposer,
    $$PendingDeletionsTableAnnotationComposer,
    $$PendingDeletionsTableCreateCompanionBuilder,
    $$PendingDeletionsTableUpdateCompanionBuilder,
    (
      PendingDeletion,
      BaseReferences<_$AppDatabase, $PendingDeletionsTable, PendingDeletion>
    ),
    PendingDeletion,
    PrefetchHooks Function()> {
  $$PendingDeletionsTableTableManager(
      _$AppDatabase db, $PendingDeletionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingDeletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingDeletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingDeletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> messageId = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingDeletionsCompanion(
            messageId: messageId,
            source: source,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String messageId,
            required String source,
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingDeletionsCompanion.insert(
            messageId: messageId,
            source: source,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingDeletionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingDeletionsTable,
    PendingDeletion,
    $$PendingDeletionsTableFilterComposer,
    $$PendingDeletionsTableOrderingComposer,
    $$PendingDeletionsTableAnnotationComposer,
    $$PendingDeletionsTableCreateCompanionBuilder,
    $$PendingDeletionsTableUpdateCompanionBuilder,
    (
      PendingDeletion,
      BaseReferences<_$AppDatabase, $PendingDeletionsTable, PendingDeletion>
    ),
    PendingDeletion,
    PrefetchHooks Function()>;
typedef $$UserProfilesTableCreateCompanionBuilder = UserProfilesCompanion
    Function({
  required String id,
  required String email,
  Value<String?> firstName,
  Value<String?> lastName,
  Value<String?> gender,
  Value<DateTime?> dateOfBirth,
  Value<String> conditionsJson,
  Value<bool> hasConsented,
  Value<String> registrationStatus,
  Value<String?> modeOfRegistration,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$UserProfilesTableUpdateCompanionBuilder = UserProfilesCompanion
    Function({
  Value<String> id,
  Value<String> email,
  Value<String?> firstName,
  Value<String?> lastName,
  Value<String?> gender,
  Value<DateTime?> dateOfBirth,
  Value<String> conditionsJson,
  Value<bool> hasConsented,
  Value<String> registrationStatus,
  Value<String?> modeOfRegistration,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditionsJson => $composableBuilder(
      column: $table.conditionsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasConsented => $composableBuilder(
      column: $table.hasConsented, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get registrationStatus => $composableBuilder(
      column: $table.registrationStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modeOfRegistration => $composableBuilder(
      column: $table.modeOfRegistration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditionsJson => $composableBuilder(
      column: $table.conditionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasConsented => $composableBuilder(
      column: $table.hasConsented,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get registrationStatus => $composableBuilder(
      column: $table.registrationStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modeOfRegistration => $composableBuilder(
      column: $table.modeOfRegistration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<String> get conditionsJson => $composableBuilder(
      column: $table.conditionsJson, builder: (column) => column);

  GeneratedColumn<bool> get hasConsented => $composableBuilder(
      column: $table.hasConsented, builder: (column) => column);

  GeneratedColumn<String> get registrationStatus => $composableBuilder(
      column: $table.registrationStatus, builder: (column) => column);

  GeneratedColumn<String> get modeOfRegistration => $composableBuilder(
      column: $table.modeOfRegistration, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfile,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfile,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>
    ),
    UserProfile,
    PrefetchHooks Function()> {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String?> firstName = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<String> conditionsJson = const Value.absent(),
            Value<bool> hasConsented = const Value.absent(),
            Value<String> registrationStatus = const Value.absent(),
            Value<String?> modeOfRegistration = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesCompanion(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            dateOfBirth: dateOfBirth,
            conditionsJson: conditionsJson,
            hasConsented: hasConsented,
            registrationStatus: registrationStatus,
            modeOfRegistration: modeOfRegistration,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String email,
            Value<String?> firstName = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<String> conditionsJson = const Value.absent(),
            Value<bool> hasConsented = const Value.absent(),
            Value<String> registrationStatus = const Value.absent(),
            Value<String?> modeOfRegistration = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesCompanion.insert(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            dateOfBirth: dateOfBirth,
            conditionsJson: conditionsJson,
            hasConsented: hasConsented,
            registrationStatus: registrationStatus,
            modeOfRegistration: modeOfRegistration,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfile,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfile,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>
    ),
    UserProfile,
    PrefetchHooks Function()>;
typedef $$PendingMutationsTableCreateCompanionBuilder
    = PendingMutationsCompanion Function({
  required String id,
  required String entityType,
  required String entityId,
  required String action,
  required String payloadJson,
  required DateTime createdAt,
  Value<int> retryCount,
  Value<int> rowid,
});
typedef $$PendingMutationsTableUpdateCompanionBuilder
    = PendingMutationsCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> action,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<int> rowid,
});

class $$PendingMutationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));
}

class $$PendingMutationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));
}

class $$PendingMutationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);
}

class $$PendingMutationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingMutationsTable,
    PendingMutation,
    $$PendingMutationsTableFilterComposer,
    $$PendingMutationsTableOrderingComposer,
    $$PendingMutationsTableAnnotationComposer,
    $$PendingMutationsTableCreateCompanionBuilder,
    $$PendingMutationsTableUpdateCompanionBuilder,
    (
      PendingMutation,
      BaseReferences<_$AppDatabase, $PendingMutationsTable, PendingMutation>
    ),
    PendingMutation,
    PrefetchHooks Function()> {
  $$PendingMutationsTableTableManager(
      _$AppDatabase db, $PendingMutationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingMutationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingMutationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingMutationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingMutationsCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required String action,
            required String payloadJson,
            required DateTime createdAt,
            Value<int> retryCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingMutationsCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingMutationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingMutationsTable,
    PendingMutation,
    $$PendingMutationsTableFilterComposer,
    $$PendingMutationsTableOrderingComposer,
    $$PendingMutationsTableAnnotationComposer,
    $$PendingMutationsTableCreateCompanionBuilder,
    $$PendingMutationsTableUpdateCompanionBuilder,
    (
      PendingMutation,
      BaseReferences<_$AppDatabase, $PendingMutationsTable, PendingMutation>
    ),
    PendingMutation,
    PrefetchHooks Function()>;
typedef $$MedicationsTableCreateCompanionBuilder = MedicationsCompanion
    Function({
  required String id,
  required String name,
  required String dosage,
  required String purpose,
  required DateTime toBeTakenAt,
  Value<bool> taken,
  Value<int> rowid,
});
typedef $$MedicationsTableUpdateCompanionBuilder = MedicationsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> dosage,
  Value<String> purpose,
  Value<DateTime> toBeTakenAt,
  Value<bool> taken,
  Value<int> rowid,
});

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get toBeTakenAt => $composableBuilder(
      column: $table.toBeTakenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get taken => $composableBuilder(
      column: $table.taken, builder: (column) => ColumnFilters(column));
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get toBeTakenAt => $composableBuilder(
      column: $table.toBeTakenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get taken => $composableBuilder(
      column: $table.taken, builder: (column) => ColumnOrderings(column));
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<DateTime> get toBeTakenAt => $composableBuilder(
      column: $table.toBeTakenAt, builder: (column) => column);

  GeneratedColumn<bool> get taken =>
      $composableBuilder(column: $table.taken, builder: (column) => column);
}

class $$MedicationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicationsTable,
    Medication,
    $$MedicationsTableFilterComposer,
    $$MedicationsTableOrderingComposer,
    $$MedicationsTableAnnotationComposer,
    $$MedicationsTableCreateCompanionBuilder,
    $$MedicationsTableUpdateCompanionBuilder,
    (Medication, BaseReferences<_$AppDatabase, $MedicationsTable, Medication>),
    Medication,
    PrefetchHooks Function()> {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> dosage = const Value.absent(),
            Value<String> purpose = const Value.absent(),
            Value<DateTime> toBeTakenAt = const Value.absent(),
            Value<bool> taken = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationsCompanion(
            id: id,
            name: name,
            dosage: dosage,
            purpose: purpose,
            toBeTakenAt: toBeTakenAt,
            taken: taken,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String dosage,
            required String purpose,
            required DateTime toBeTakenAt,
            Value<bool> taken = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationsCompanion.insert(
            id: id,
            name: name,
            dosage: dosage,
            purpose: purpose,
            toBeTakenAt: toBeTakenAt,
            taken: taken,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MedicationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MedicationsTable,
    Medication,
    $$MedicationsTableFilterComposer,
    $$MedicationsTableOrderingComposer,
    $$MedicationsTableAnnotationComposer,
    $$MedicationsTableCreateCompanionBuilder,
    $$MedicationsTableUpdateCompanionBuilder,
    (Medication, BaseReferences<_$AppDatabase, $MedicationsTable, Medication>),
    Medication,
    PrefetchHooks Function()>;
typedef $$AppointmentsTableCreateCompanionBuilder = AppointmentsCompanion
    Function({
  required String id,
  required String title,
  required DateTime appointmentDate,
  required String hostPersonnelId,
  required String hostPersonnelUserName,
  required String hostPersonnelFacilityName,
  Value<int> rowid,
});
typedef $$AppointmentsTableUpdateCompanionBuilder = AppointmentsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<DateTime> appointmentDate,
  Value<String> hostPersonnelId,
  Value<String> hostPersonnelUserName,
  Value<String> hostPersonnelFacilityName,
  Value<int> rowid,
});

class $$AppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get appointmentDate => $composableBuilder(
      column: $table.appointmentDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hostPersonnelId => $composableBuilder(
      column: $table.hostPersonnelId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hostPersonnelUserName => $composableBuilder(
      column: $table.hostPersonnelUserName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hostPersonnelFacilityName => $composableBuilder(
      column: $table.hostPersonnelFacilityName,
      builder: (column) => ColumnFilters(column));
}

class $$AppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get appointmentDate => $composableBuilder(
      column: $table.appointmentDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hostPersonnelId => $composableBuilder(
      column: $table.hostPersonnelId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hostPersonnelUserName => $composableBuilder(
      column: $table.hostPersonnelUserName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hostPersonnelFacilityName => $composableBuilder(
      column: $table.hostPersonnelFacilityName,
      builder: (column) => ColumnOrderings(column));
}

class $$AppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get appointmentDate => $composableBuilder(
      column: $table.appointmentDate, builder: (column) => column);

  GeneratedColumn<String> get hostPersonnelId => $composableBuilder(
      column: $table.hostPersonnelId, builder: (column) => column);

  GeneratedColumn<String> get hostPersonnelUserName => $composableBuilder(
      column: $table.hostPersonnelUserName, builder: (column) => column);

  GeneratedColumn<String> get hostPersonnelFacilityName => $composableBuilder(
      column: $table.hostPersonnelFacilityName, builder: (column) => column);
}

class $$AppointmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppointmentsTable,
    Appointment,
    $$AppointmentsTableFilterComposer,
    $$AppointmentsTableOrderingComposer,
    $$AppointmentsTableAnnotationComposer,
    $$AppointmentsTableCreateCompanionBuilder,
    $$AppointmentsTableUpdateCompanionBuilder,
    (
      Appointment,
      BaseReferences<_$AppDatabase, $AppointmentsTable, Appointment>
    ),
    Appointment,
    PrefetchHooks Function()> {
  $$AppointmentsTableTableManager(_$AppDatabase db, $AppointmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> appointmentDate = const Value.absent(),
            Value<String> hostPersonnelId = const Value.absent(),
            Value<String> hostPersonnelUserName = const Value.absent(),
            Value<String> hostPersonnelFacilityName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppointmentsCompanion(
            id: id,
            title: title,
            appointmentDate: appointmentDate,
            hostPersonnelId: hostPersonnelId,
            hostPersonnelUserName: hostPersonnelUserName,
            hostPersonnelFacilityName: hostPersonnelFacilityName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required DateTime appointmentDate,
            required String hostPersonnelId,
            required String hostPersonnelUserName,
            required String hostPersonnelFacilityName,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppointmentsCompanion.insert(
            id: id,
            title: title,
            appointmentDate: appointmentDate,
            hostPersonnelId: hostPersonnelId,
            hostPersonnelUserName: hostPersonnelUserName,
            hostPersonnelFacilityName: hostPersonnelFacilityName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppointmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppointmentsTable,
    Appointment,
    $$AppointmentsTableFilterComposer,
    $$AppointmentsTableOrderingComposer,
    $$AppointmentsTableAnnotationComposer,
    $$AppointmentsTableCreateCompanionBuilder,
    $$AppointmentsTableUpdateCompanionBuilder,
    (
      Appointment,
      BaseReferences<_$AppDatabase, $AppointmentsTable, Appointment>
    ),
    Appointment,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VitalHistoriesTableTableManager get vitalHistories =>
      $$VitalHistoriesTableTableManager(_db, _db.vitalHistories);
  $$AiChatConversationsTableTableManager get aiChatConversations =>
      $$AiChatConversationsTableTableManager(_db, _db.aiChatConversations);
  $$PendingDeletionsTableTableManager get pendingDeletions =>
      $$PendingDeletionsTableTableManager(_db, _db.pendingDeletions);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$PendingMutationsTableTableManager get pendingMutations =>
      $$PendingMutationsTableTableManager(_db, _db.pendingMutations);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db, _db.appointments);
}
