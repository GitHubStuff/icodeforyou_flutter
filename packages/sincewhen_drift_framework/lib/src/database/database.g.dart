// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $GlossaryItemsTable extends GlossaryItems
    with TableInfo<$GlossaryItemsTable, GlossaryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GlossaryItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createdTimeStampMeta = const VerificationMeta(
    'createdTimeStamp',
  );
  @override
  late final GeneratedColumn<int> createdTimeStamp = GeneratedColumn<int>(
    'createdTimeStamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    check: () => tag.isNotValue(''),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colorArgbMeta = const VerificationMeta(
    'colorArgb',
  );
  @override
  late final GeneratedColumn<int> colorArgb = GeneratedColumn<int>(
    'color_argb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdTimeStamp, tag, colorArgb];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tagGlossary';
  @override
  VerificationContext validateIntegrity(
    Insertable<GlossaryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('createdTimeStamp')) {
      context.handle(
        _createdTimeStampMeta,
        createdTimeStamp.isAcceptableOrUnknown(
          data['createdTimeStamp']!,
          _createdTimeStampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdTimeStampMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('color_argb')) {
      context.handle(
        _colorArgbMeta,
        colorArgb.isAcceptableOrUnknown(data['color_argb']!, _colorArgbMeta),
      );
    } else if (isInserting) {
      context.missing(_colorArgbMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GlossaryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GlossaryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdTimeStamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}createdTimeStamp'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      colorArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_argb'],
      )!,
    );
  }

  @override
  $GlossaryItemsTable createAlias(String alias) {
    return $GlossaryItemsTable(attachedDatabase, alias);
  }
}

class GlossaryItem extends DataClass implements Insertable<GlossaryItem> {
  /// Auto-incrementing primary key.
  final int id;

  /// `createdTimeStamp INTEGER NOT NULL UNIQUE`.
  ///
  /// Explicitly named to preserve the camelCase column name from the raw
  /// SQL schema, since drift would otherwise emit `created_time_stamp`.
  final int createdTimeStamp;

  /// `tag TEXT NOT NULL UNIQUE CHECK(tag != '')`.
  ///
  /// The self-reference inside `check()` is the documented drift pattern:
  /// the generated table class overrides this getter, so it is never
  /// executed at runtime — drift's builder only reads it statically to
  /// emit the CHECK clause. The recursion the analyzer flags cannot occur.
  final String tag;

  /// `color_argb INTEGER NOT NULL UNIQUE`.
  ///
  /// Packed ARGB color value, suitable for `Color(colorArgb)` on the
  /// Flutter side. Drift derives the column name from the getter.
  final int colorArgb;
  const GlossaryItem({
    required this.id,
    required this.createdTimeStamp,
    required this.tag,
    required this.colorArgb,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['createdTimeStamp'] = Variable<int>(createdTimeStamp);
    map['tag'] = Variable<String>(tag);
    map['color_argb'] = Variable<int>(colorArgb);
    return map;
  }

  GlossaryItemsCompanion toCompanion(bool nullToAbsent) {
    return GlossaryItemsCompanion(
      id: Value(id),
      createdTimeStamp: Value(createdTimeStamp),
      tag: Value(tag),
      colorArgb: Value(colorArgb),
    );
  }

  factory GlossaryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GlossaryItem(
      id: serializer.fromJson<int>(json['id']),
      createdTimeStamp: serializer.fromJson<int>(json['createdTimeStamp']),
      tag: serializer.fromJson<String>(json['tag']),
      colorArgb: serializer.fromJson<int>(json['colorArgb']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdTimeStamp': serializer.toJson<int>(createdTimeStamp),
      'tag': serializer.toJson<String>(tag),
      'colorArgb': serializer.toJson<int>(colorArgb),
    };
  }

  GlossaryItem copyWith({
    int? id,
    int? createdTimeStamp,
    String? tag,
    int? colorArgb,
  }) => GlossaryItem(
    id: id ?? this.id,
    createdTimeStamp: createdTimeStamp ?? this.createdTimeStamp,
    tag: tag ?? this.tag,
    colorArgb: colorArgb ?? this.colorArgb,
  );
  GlossaryItem copyWithCompanion(GlossaryItemsCompanion data) {
    return GlossaryItem(
      id: data.id.present ? data.id.value : this.id,
      createdTimeStamp: data.createdTimeStamp.present
          ? data.createdTimeStamp.value
          : this.createdTimeStamp,
      tag: data.tag.present ? data.tag.value : this.tag,
      colorArgb: data.colorArgb.present ? data.colorArgb.value : this.colorArgb,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GlossaryItem(')
          ..write('id: $id, ')
          ..write('createdTimeStamp: $createdTimeStamp, ')
          ..write('tag: $tag, ')
          ..write('colorArgb: $colorArgb')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdTimeStamp, tag, colorArgb);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GlossaryItem &&
          other.id == this.id &&
          other.createdTimeStamp == this.createdTimeStamp &&
          other.tag == this.tag &&
          other.colorArgb == this.colorArgb);
}

class GlossaryItemsCompanion extends UpdateCompanion<GlossaryItem> {
  final Value<int> id;
  final Value<int> createdTimeStamp;
  final Value<String> tag;
  final Value<int> colorArgb;
  const GlossaryItemsCompanion({
    this.id = const Value.absent(),
    this.createdTimeStamp = const Value.absent(),
    this.tag = const Value.absent(),
    this.colorArgb = const Value.absent(),
  });
  GlossaryItemsCompanion.insert({
    this.id = const Value.absent(),
    required int createdTimeStamp,
    required String tag,
    required int colorArgb,
  }) : createdTimeStamp = Value(createdTimeStamp),
       tag = Value(tag),
       colorArgb = Value(colorArgb);
  static Insertable<GlossaryItem> custom({
    Expression<int>? id,
    Expression<int>? createdTimeStamp,
    Expression<String>? tag,
    Expression<int>? colorArgb,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdTimeStamp != null) 'createdTimeStamp': createdTimeStamp,
      if (tag != null) 'tag': tag,
      if (colorArgb != null) 'color_argb': colorArgb,
    });
  }

  GlossaryItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? createdTimeStamp,
    Value<String>? tag,
    Value<int>? colorArgb,
  }) {
    return GlossaryItemsCompanion(
      id: id ?? this.id,
      createdTimeStamp: createdTimeStamp ?? this.createdTimeStamp,
      tag: tag ?? this.tag,
      colorArgb: colorArgb ?? this.colorArgb,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdTimeStamp.present) {
      map['createdTimeStamp'] = Variable<int>(createdTimeStamp.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (colorArgb.present) {
      map['color_argb'] = Variable<int>(colorArgb.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GlossaryItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdTimeStamp: $createdTimeStamp, ')
          ..write('tag: $tag, ')
          ..write('colorArgb: $colorArgb')
          ..write(')'))
        .toString();
  }
}

class $SinceWhenItemsTable extends SinceWhenItems
    with TableInfo<$SinceWhenItemsTable, SinceWhenItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SinceWhenItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createdTimeStampMeta = const VerificationMeta(
    'createdTimeStamp',
  );
  @override
  late final GeneratedColumn<int> createdTimeStamp = GeneratedColumn<int>(
    'createdTimeStamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _reviewedTimeStampMeta = const VerificationMeta(
    'reviewedTimeStamp',
  );
  @override
  late final GeneratedColumn<int> reviewedTimeStamp = GeneratedColumn<int>(
    'reviewedTimeStamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editedTimeStampMeta = const VerificationMeta(
    'editedTimeStamp',
  );
  @override
  late final GeneratedColumn<int> editedTimeStamp = GeneratedColumn<int>(
    'editedTimeStamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentTimeStampMeta = const VerificationMeta(
    'parentTimeStamp',
  );
  @override
  late final GeneratedColumn<int> parentTimeStamp = GeneratedColumn<int>(
    'parentTimeStamp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTimeStampMeta = const VerificationMeta(
    'eventTimeStamp',
  );
  @override
  late final GeneratedColumn<int> eventTimeStamp = GeneratedColumn<int>(
    'eventTimeStamp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sequenceNumberMeta = const VerificationMeta(
    'sequenceNumber',
  );
  @override
  late final GeneratedColumn<int> sequenceNumber = GeneratedColumn<int>(
    'sequenceNumber',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _metaDataMeta = const VerificationMeta(
    'metaData',
  );
  @override
  late final GeneratedColumn<String> metaData = GeneratedColumn<String>(
    'metaData',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdTimeStamp,
    reviewedTimeStamp,
    editedTimeStamp,
    parentTimeStamp,
    eventTimeStamp,
    sequenceNumber,
    metaData,
    content,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sinceWhen';
  @override
  VerificationContext validateIntegrity(
    Insertable<SinceWhenItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('createdTimeStamp')) {
      context.handle(
        _createdTimeStampMeta,
        createdTimeStamp.isAcceptableOrUnknown(
          data['createdTimeStamp']!,
          _createdTimeStampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdTimeStampMeta);
    }
    if (data.containsKey('reviewedTimeStamp')) {
      context.handle(
        _reviewedTimeStampMeta,
        reviewedTimeStamp.isAcceptableOrUnknown(
          data['reviewedTimeStamp']!,
          _reviewedTimeStampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewedTimeStampMeta);
    }
    if (data.containsKey('editedTimeStamp')) {
      context.handle(
        _editedTimeStampMeta,
        editedTimeStamp.isAcceptableOrUnknown(
          data['editedTimeStamp']!,
          _editedTimeStampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_editedTimeStampMeta);
    }
    if (data.containsKey('parentTimeStamp')) {
      context.handle(
        _parentTimeStampMeta,
        parentTimeStamp.isAcceptableOrUnknown(
          data['parentTimeStamp']!,
          _parentTimeStampMeta,
        ),
      );
    }
    if (data.containsKey('eventTimeStamp')) {
      context.handle(
        _eventTimeStampMeta,
        eventTimeStamp.isAcceptableOrUnknown(
          data['eventTimeStamp']!,
          _eventTimeStampMeta,
        ),
      );
    }
    if (data.containsKey('sequenceNumber')) {
      context.handle(
        _sequenceNumberMeta,
        sequenceNumber.isAcceptableOrUnknown(
          data['sequenceNumber']!,
          _sequenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('metaData')) {
      context.handle(
        _metaDataMeta,
        metaData.isAcceptableOrUnknown(data['metaData']!, _metaDataMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SinceWhenItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SinceWhenItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdTimeStamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}createdTimeStamp'],
      )!,
      reviewedTimeStamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviewedTimeStamp'],
      )!,
      editedTimeStamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}editedTimeStamp'],
      )!,
      parentTimeStamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parentTimeStamp'],
      ),
      eventTimeStamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eventTimeStamp'],
      ),
      sequenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequenceNumber'],
      )!,
      metaData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metaData'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $SinceWhenItemsTable createAlias(String alias) {
    return $SinceWhenItemsTable(attachedDatabase, alias);
  }
}

class SinceWhenItem extends DataClass implements Insertable<SinceWhenItem> {
  /// Auto-incrementing primary key.
  final int id;

  /// `createdTimeStamp INTEGER NOT NULL UNIQUE`.
  ///
  /// Explicitly named to preserve the camelCase column name from the raw
  /// SQL schema. This is the foreign key target for `SinceWhenTags`, so
  /// the `unique()` constraint is required — SQLite rejects foreign keys
  /// that reference non-uniquely-constrained columns.
  final int createdTimeStamp;

  /// `reviewedTimeStamp INTEGER NOT NULL`.
  final int reviewedTimeStamp;

  /// `editedTimeStamp INTEGER NOT NULL`.
  final int editedTimeStamp;

  /// `parentTimeStamp INTEGER` (nullable).
  final int? parentTimeStamp;

  /// `eventTimeStamp INTEGER` (nullable).
  final int? eventTimeStamp;

  /// `sequenceNumber INTEGER NOT NULL DEFAULT 0`.
  final int sequenceNumber;

  /// `metaData TEXT` (nullable).
  final String? metaData;

  /// `content TEXT NOT NULL`.
  final String content;
  const SinceWhenItem({
    required this.id,
    required this.createdTimeStamp,
    required this.reviewedTimeStamp,
    required this.editedTimeStamp,
    this.parentTimeStamp,
    this.eventTimeStamp,
    required this.sequenceNumber,
    this.metaData,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['createdTimeStamp'] = Variable<int>(createdTimeStamp);
    map['reviewedTimeStamp'] = Variable<int>(reviewedTimeStamp);
    map['editedTimeStamp'] = Variable<int>(editedTimeStamp);
    if (!nullToAbsent || parentTimeStamp != null) {
      map['parentTimeStamp'] = Variable<int>(parentTimeStamp);
    }
    if (!nullToAbsent || eventTimeStamp != null) {
      map['eventTimeStamp'] = Variable<int>(eventTimeStamp);
    }
    map['sequenceNumber'] = Variable<int>(sequenceNumber);
    if (!nullToAbsent || metaData != null) {
      map['metaData'] = Variable<String>(metaData);
    }
    map['content'] = Variable<String>(content);
    return map;
  }

  SinceWhenItemsCompanion toCompanion(bool nullToAbsent) {
    return SinceWhenItemsCompanion(
      id: Value(id),
      createdTimeStamp: Value(createdTimeStamp),
      reviewedTimeStamp: Value(reviewedTimeStamp),
      editedTimeStamp: Value(editedTimeStamp),
      parentTimeStamp: parentTimeStamp == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTimeStamp),
      eventTimeStamp: eventTimeStamp == null && nullToAbsent
          ? const Value.absent()
          : Value(eventTimeStamp),
      sequenceNumber: Value(sequenceNumber),
      metaData: metaData == null && nullToAbsent
          ? const Value.absent()
          : Value(metaData),
      content: Value(content),
    );
  }

  factory SinceWhenItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SinceWhenItem(
      id: serializer.fromJson<int>(json['id']),
      createdTimeStamp: serializer.fromJson<int>(json['createdTimeStamp']),
      reviewedTimeStamp: serializer.fromJson<int>(json['reviewedTimeStamp']),
      editedTimeStamp: serializer.fromJson<int>(json['editedTimeStamp']),
      parentTimeStamp: serializer.fromJson<int?>(json['parentTimeStamp']),
      eventTimeStamp: serializer.fromJson<int?>(json['eventTimeStamp']),
      sequenceNumber: serializer.fromJson<int>(json['sequenceNumber']),
      metaData: serializer.fromJson<String?>(json['metaData']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdTimeStamp': serializer.toJson<int>(createdTimeStamp),
      'reviewedTimeStamp': serializer.toJson<int>(reviewedTimeStamp),
      'editedTimeStamp': serializer.toJson<int>(editedTimeStamp),
      'parentTimeStamp': serializer.toJson<int?>(parentTimeStamp),
      'eventTimeStamp': serializer.toJson<int?>(eventTimeStamp),
      'sequenceNumber': serializer.toJson<int>(sequenceNumber),
      'metaData': serializer.toJson<String?>(metaData),
      'content': serializer.toJson<String>(content),
    };
  }

  SinceWhenItem copyWith({
    int? id,
    int? createdTimeStamp,
    int? reviewedTimeStamp,
    int? editedTimeStamp,
    Value<int?> parentTimeStamp = const Value.absent(),
    Value<int?> eventTimeStamp = const Value.absent(),
    int? sequenceNumber,
    Value<String?> metaData = const Value.absent(),
    String? content,
  }) => SinceWhenItem(
    id: id ?? this.id,
    createdTimeStamp: createdTimeStamp ?? this.createdTimeStamp,
    reviewedTimeStamp: reviewedTimeStamp ?? this.reviewedTimeStamp,
    editedTimeStamp: editedTimeStamp ?? this.editedTimeStamp,
    parentTimeStamp: parentTimeStamp.present
        ? parentTimeStamp.value
        : this.parentTimeStamp,
    eventTimeStamp: eventTimeStamp.present
        ? eventTimeStamp.value
        : this.eventTimeStamp,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    metaData: metaData.present ? metaData.value : this.metaData,
    content: content ?? this.content,
  );
  SinceWhenItem copyWithCompanion(SinceWhenItemsCompanion data) {
    return SinceWhenItem(
      id: data.id.present ? data.id.value : this.id,
      createdTimeStamp: data.createdTimeStamp.present
          ? data.createdTimeStamp.value
          : this.createdTimeStamp,
      reviewedTimeStamp: data.reviewedTimeStamp.present
          ? data.reviewedTimeStamp.value
          : this.reviewedTimeStamp,
      editedTimeStamp: data.editedTimeStamp.present
          ? data.editedTimeStamp.value
          : this.editedTimeStamp,
      parentTimeStamp: data.parentTimeStamp.present
          ? data.parentTimeStamp.value
          : this.parentTimeStamp,
      eventTimeStamp: data.eventTimeStamp.present
          ? data.eventTimeStamp.value
          : this.eventTimeStamp,
      sequenceNumber: data.sequenceNumber.present
          ? data.sequenceNumber.value
          : this.sequenceNumber,
      metaData: data.metaData.present ? data.metaData.value : this.metaData,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SinceWhenItem(')
          ..write('id: $id, ')
          ..write('createdTimeStamp: $createdTimeStamp, ')
          ..write('reviewedTimeStamp: $reviewedTimeStamp, ')
          ..write('editedTimeStamp: $editedTimeStamp, ')
          ..write('parentTimeStamp: $parentTimeStamp, ')
          ..write('eventTimeStamp: $eventTimeStamp, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('metaData: $metaData, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdTimeStamp,
    reviewedTimeStamp,
    editedTimeStamp,
    parentTimeStamp,
    eventTimeStamp,
    sequenceNumber,
    metaData,
    content,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SinceWhenItem &&
          other.id == this.id &&
          other.createdTimeStamp == this.createdTimeStamp &&
          other.reviewedTimeStamp == this.reviewedTimeStamp &&
          other.editedTimeStamp == this.editedTimeStamp &&
          other.parentTimeStamp == this.parentTimeStamp &&
          other.eventTimeStamp == this.eventTimeStamp &&
          other.sequenceNumber == this.sequenceNumber &&
          other.metaData == this.metaData &&
          other.content == this.content);
}

class SinceWhenItemsCompanion extends UpdateCompanion<SinceWhenItem> {
  final Value<int> id;
  final Value<int> createdTimeStamp;
  final Value<int> reviewedTimeStamp;
  final Value<int> editedTimeStamp;
  final Value<int?> parentTimeStamp;
  final Value<int?> eventTimeStamp;
  final Value<int> sequenceNumber;
  final Value<String?> metaData;
  final Value<String> content;
  const SinceWhenItemsCompanion({
    this.id = const Value.absent(),
    this.createdTimeStamp = const Value.absent(),
    this.reviewedTimeStamp = const Value.absent(),
    this.editedTimeStamp = const Value.absent(),
    this.parentTimeStamp = const Value.absent(),
    this.eventTimeStamp = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.metaData = const Value.absent(),
    this.content = const Value.absent(),
  });
  SinceWhenItemsCompanion.insert({
    this.id = const Value.absent(),
    required int createdTimeStamp,
    required int reviewedTimeStamp,
    required int editedTimeStamp,
    this.parentTimeStamp = const Value.absent(),
    this.eventTimeStamp = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.metaData = const Value.absent(),
    required String content,
  }) : createdTimeStamp = Value(createdTimeStamp),
       reviewedTimeStamp = Value(reviewedTimeStamp),
       editedTimeStamp = Value(editedTimeStamp),
       content = Value(content);
  static Insertable<SinceWhenItem> custom({
    Expression<int>? id,
    Expression<int>? createdTimeStamp,
    Expression<int>? reviewedTimeStamp,
    Expression<int>? editedTimeStamp,
    Expression<int>? parentTimeStamp,
    Expression<int>? eventTimeStamp,
    Expression<int>? sequenceNumber,
    Expression<String>? metaData,
    Expression<String>? content,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdTimeStamp != null) 'createdTimeStamp': createdTimeStamp,
      if (reviewedTimeStamp != null) 'reviewedTimeStamp': reviewedTimeStamp,
      if (editedTimeStamp != null) 'editedTimeStamp': editedTimeStamp,
      if (parentTimeStamp != null) 'parentTimeStamp': parentTimeStamp,
      if (eventTimeStamp != null) 'eventTimeStamp': eventTimeStamp,
      if (sequenceNumber != null) 'sequenceNumber': sequenceNumber,
      if (metaData != null) 'metaData': metaData,
      if (content != null) 'content': content,
    });
  }

  SinceWhenItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? createdTimeStamp,
    Value<int>? reviewedTimeStamp,
    Value<int>? editedTimeStamp,
    Value<int?>? parentTimeStamp,
    Value<int?>? eventTimeStamp,
    Value<int>? sequenceNumber,
    Value<String?>? metaData,
    Value<String>? content,
  }) {
    return SinceWhenItemsCompanion(
      id: id ?? this.id,
      createdTimeStamp: createdTimeStamp ?? this.createdTimeStamp,
      reviewedTimeStamp: reviewedTimeStamp ?? this.reviewedTimeStamp,
      editedTimeStamp: editedTimeStamp ?? this.editedTimeStamp,
      parentTimeStamp: parentTimeStamp ?? this.parentTimeStamp,
      eventTimeStamp: eventTimeStamp ?? this.eventTimeStamp,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      metaData: metaData ?? this.metaData,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdTimeStamp.present) {
      map['createdTimeStamp'] = Variable<int>(createdTimeStamp.value);
    }
    if (reviewedTimeStamp.present) {
      map['reviewedTimeStamp'] = Variable<int>(reviewedTimeStamp.value);
    }
    if (editedTimeStamp.present) {
      map['editedTimeStamp'] = Variable<int>(editedTimeStamp.value);
    }
    if (parentTimeStamp.present) {
      map['parentTimeStamp'] = Variable<int>(parentTimeStamp.value);
    }
    if (eventTimeStamp.present) {
      map['eventTimeStamp'] = Variable<int>(eventTimeStamp.value);
    }
    if (sequenceNumber.present) {
      map['sequenceNumber'] = Variable<int>(sequenceNumber.value);
    }
    if (metaData.present) {
      map['metaData'] = Variable<String>(metaData.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SinceWhenItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdTimeStamp: $createdTimeStamp, ')
          ..write('reviewedTimeStamp: $reviewedTimeStamp, ')
          ..write('editedTimeStamp: $editedTimeStamp, ')
          ..write('parentTimeStamp: $parentTimeStamp, ')
          ..write('eventTimeStamp: $eventTimeStamp, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('metaData: $metaData, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }
}

class $TagItemsTable extends TagItems with TableInfo<$TagItemsTable, TagItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _recordTimestampMeta = const VerificationMeta(
    'recordTimestamp',
  );
  @override
  late final GeneratedColumn<int> recordTimestamp = GeneratedColumn<int>(
    'record_timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sinceWhen (createdTimeStamp) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _glossaryTimestampMeta = const VerificationMeta(
    'glossaryTimestamp',
  );
  @override
  late final GeneratedColumn<int> glossaryTimestamp = GeneratedColumn<int>(
    'glossary_timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tagGlossary (createdTimeStamp) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordTimestamp,
    glossaryTimestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('record_timestamp')) {
      context.handle(
        _recordTimestampMeta,
        recordTimestamp.isAcceptableOrUnknown(
          data['record_timestamp']!,
          _recordTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordTimestampMeta);
    }
    if (data.containsKey('glossary_timestamp')) {
      context.handle(
        _glossaryTimestampMeta,
        glossaryTimestamp.isAcceptableOrUnknown(
          data['glossary_timestamp']!,
          _glossaryTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_glossaryTimestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {recordTimestamp, glossaryTimestamp},
  ];
  @override
  TagItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}record_timestamp'],
      )!,
      glossaryTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}glossary_timestamp'],
      )!,
    );
  }

  @override
  $TagItemsTable createAlias(String alias) {
    return $TagItemsTable(attachedDatabase, alias);
  }
}

class TagItem extends DataClass implements Insertable<TagItem> {
  /// Auto-incrementing primary key.
  final int id;

  /// `record_timestamp INTEGER NOT NULL` referencing
  /// `SinceWhenItems.createdTimeStamp` with `ON DELETE CASCADE`.
  final int recordTimestamp;

  /// `glossary_timestamp INTEGER NOT NULL` referencing
  /// `GlossaryItems.createdTimeStamp` with `ON DELETE CASCADE`.
  final int glossaryTimestamp;
  const TagItem({
    required this.id,
    required this.recordTimestamp,
    required this.glossaryTimestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['record_timestamp'] = Variable<int>(recordTimestamp);
    map['glossary_timestamp'] = Variable<int>(glossaryTimestamp);
    return map;
  }

  TagItemsCompanion toCompanion(bool nullToAbsent) {
    return TagItemsCompanion(
      id: Value(id),
      recordTimestamp: Value(recordTimestamp),
      glossaryTimestamp: Value(glossaryTimestamp),
    );
  }

  factory TagItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagItem(
      id: serializer.fromJson<int>(json['id']),
      recordTimestamp: serializer.fromJson<int>(json['recordTimestamp']),
      glossaryTimestamp: serializer.fromJson<int>(json['glossaryTimestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordTimestamp': serializer.toJson<int>(recordTimestamp),
      'glossaryTimestamp': serializer.toJson<int>(glossaryTimestamp),
    };
  }

  TagItem copyWith({int? id, int? recordTimestamp, int? glossaryTimestamp}) =>
      TagItem(
        id: id ?? this.id,
        recordTimestamp: recordTimestamp ?? this.recordTimestamp,
        glossaryTimestamp: glossaryTimestamp ?? this.glossaryTimestamp,
      );
  TagItem copyWithCompanion(TagItemsCompanion data) {
    return TagItem(
      id: data.id.present ? data.id.value : this.id,
      recordTimestamp: data.recordTimestamp.present
          ? data.recordTimestamp.value
          : this.recordTimestamp,
      glossaryTimestamp: data.glossaryTimestamp.present
          ? data.glossaryTimestamp.value
          : this.glossaryTimestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagItem(')
          ..write('id: $id, ')
          ..write('recordTimestamp: $recordTimestamp, ')
          ..write('glossaryTimestamp: $glossaryTimestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recordTimestamp, glossaryTimestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagItem &&
          other.id == this.id &&
          other.recordTimestamp == this.recordTimestamp &&
          other.glossaryTimestamp == this.glossaryTimestamp);
}

class TagItemsCompanion extends UpdateCompanion<TagItem> {
  final Value<int> id;
  final Value<int> recordTimestamp;
  final Value<int> glossaryTimestamp;
  const TagItemsCompanion({
    this.id = const Value.absent(),
    this.recordTimestamp = const Value.absent(),
    this.glossaryTimestamp = const Value.absent(),
  });
  TagItemsCompanion.insert({
    this.id = const Value.absent(),
    required int recordTimestamp,
    required int glossaryTimestamp,
  }) : recordTimestamp = Value(recordTimestamp),
       glossaryTimestamp = Value(glossaryTimestamp);
  static Insertable<TagItem> custom({
    Expression<int>? id,
    Expression<int>? recordTimestamp,
    Expression<int>? glossaryTimestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordTimestamp != null) 'record_timestamp': recordTimestamp,
      if (glossaryTimestamp != null) 'glossary_timestamp': glossaryTimestamp,
    });
  }

  TagItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? recordTimestamp,
    Value<int>? glossaryTimestamp,
  }) {
    return TagItemsCompanion(
      id: id ?? this.id,
      recordTimestamp: recordTimestamp ?? this.recordTimestamp,
      glossaryTimestamp: glossaryTimestamp ?? this.glossaryTimestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordTimestamp.present) {
      map['record_timestamp'] = Variable<int>(recordTimestamp.value);
    }
    if (glossaryTimestamp.present) {
      map['glossary_timestamp'] = Variable<int>(glossaryTimestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagItemsCompanion(')
          ..write('id: $id, ')
          ..write('recordTimestamp: $recordTimestamp, ')
          ..write('glossaryTimestamp: $glossaryTimestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$SinceWhenDatabase extends GeneratedDatabase {
  _$SinceWhenDatabase(QueryExecutor e) : super(e);
  $SinceWhenDatabaseManager get managers => $SinceWhenDatabaseManager(this);
  late final $GlossaryItemsTable glossaryItems = $GlossaryItemsTable(this);
  late final $SinceWhenItemsTable sinceWhenItems = $SinceWhenItemsTable(this);
  late final $TagItemsTable tagItems = $TagItemsTable(this);
  late final GlossaryItemsDao glossaryItemsDao = GlossaryItemsDao(
    this as SinceWhenDatabase,
  );
  late final SinceWhenItemsDao sinceWhenItemsDao = SinceWhenItemsDao(
    this as SinceWhenDatabase,
  );
  late final TagItemsDao tagItemsDao = TagItemsDao(this as SinceWhenDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    glossaryItems,
    sinceWhenItems,
    tagItems,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sinceWhen',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tagGlossary',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tags', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$GlossaryItemsTableCreateCompanionBuilder =
    GlossaryItemsCompanion Function({
      Value<int> id,
      required int createdTimeStamp,
      required String tag,
      required int colorArgb,
    });
typedef $$GlossaryItemsTableUpdateCompanionBuilder =
    GlossaryItemsCompanion Function({
      Value<int> id,
      Value<int> createdTimeStamp,
      Value<String> tag,
      Value<int> colorArgb,
    });

final class $$GlossaryItemsTableReferences
    extends
        BaseReferences<_$SinceWhenDatabase, $GlossaryItemsTable, GlossaryItem> {
  $$GlossaryItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TagItemsTable, List<TagItem>> _tagItemsRefsTable(
    _$SinceWhenDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tagItems,
    aliasName: 'tagGlossary__createdTimeStamp__tags__glossary_timestamp',
  );

  $$TagItemsTableProcessedTableManager get tagItemsRefs {
    final manager = $$TagItemsTableTableManager($_db, $_db.tagItems).filter(
      (f) => f.glossaryTimestamp.createdTimeStamp.sqlEquals(
        $_itemColumn<int>('createdTimeStamp')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_tagItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GlossaryItemsTableFilterComposer
    extends Composer<_$SinceWhenDatabase, $GlossaryItemsTable> {
  $$GlossaryItemsTableFilterComposer({
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

  ColumnFilters<int> get createdTimeStamp => $composableBuilder(
    column: $table.createdTimeStamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tagItemsRefs(
    Expression<bool> Function($$TagItemsTableFilterComposer f) f,
  ) {
    final $$TagItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdTimeStamp,
      referencedTable: $db.tagItems,
      getReferencedColumn: (t) => t.glossaryTimestamp,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagItemsTableFilterComposer(
            $db: $db,
            $table: $db.tagItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GlossaryItemsTableOrderingComposer
    extends Composer<_$SinceWhenDatabase, $GlossaryItemsTable> {
  $$GlossaryItemsTableOrderingComposer({
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

  ColumnOrderings<int> get createdTimeStamp => $composableBuilder(
    column: $table.createdTimeStamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GlossaryItemsTableAnnotationComposer
    extends Composer<_$SinceWhenDatabase, $GlossaryItemsTable> {
  $$GlossaryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdTimeStamp => $composableBuilder(
    column: $table.createdTimeStamp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<int> get colorArgb =>
      $composableBuilder(column: $table.colorArgb, builder: (column) => column);

  Expression<T> tagItemsRefs<T extends Object>(
    Expression<T> Function($$TagItemsTableAnnotationComposer a) f,
  ) {
    final $$TagItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdTimeStamp,
      referencedTable: $db.tagItems,
      getReferencedColumn: (t) => t.glossaryTimestamp,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.tagItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GlossaryItemsTableTableManager
    extends
        RootTableManager<
          _$SinceWhenDatabase,
          $GlossaryItemsTable,
          GlossaryItem,
          $$GlossaryItemsTableFilterComposer,
          $$GlossaryItemsTableOrderingComposer,
          $$GlossaryItemsTableAnnotationComposer,
          $$GlossaryItemsTableCreateCompanionBuilder,
          $$GlossaryItemsTableUpdateCompanionBuilder,
          (GlossaryItem, $$GlossaryItemsTableReferences),
          GlossaryItem,
          PrefetchHooks Function({bool tagItemsRefs})
        > {
  $$GlossaryItemsTableTableManager(
    _$SinceWhenDatabase db,
    $GlossaryItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GlossaryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GlossaryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GlossaryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> createdTimeStamp = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<int> colorArgb = const Value.absent(),
              }) => GlossaryItemsCompanion(
                id: id,
                createdTimeStamp: createdTimeStamp,
                tag: tag,
                colorArgb: colorArgb,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdTimeStamp,
                required String tag,
                required int colorArgb,
              }) => GlossaryItemsCompanion.insert(
                id: id,
                createdTimeStamp: createdTimeStamp,
                tag: tag,
                colorArgb: colorArgb,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GlossaryItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tagItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tagItemsRefs) db.tagItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tagItemsRefs)
                    await $_getPrefetchedData<
                      GlossaryItem,
                      $GlossaryItemsTable,
                      TagItem
                    >(
                      currentTable: table,
                      referencedTable: $$GlossaryItemsTableReferences
                          ._tagItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GlossaryItemsTableReferences(
                            db,
                            table,
                            p0,
                          ).tagItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.glossaryTimestamp == item.createdTimeStamp,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GlossaryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$SinceWhenDatabase,
      $GlossaryItemsTable,
      GlossaryItem,
      $$GlossaryItemsTableFilterComposer,
      $$GlossaryItemsTableOrderingComposer,
      $$GlossaryItemsTableAnnotationComposer,
      $$GlossaryItemsTableCreateCompanionBuilder,
      $$GlossaryItemsTableUpdateCompanionBuilder,
      (GlossaryItem, $$GlossaryItemsTableReferences),
      GlossaryItem,
      PrefetchHooks Function({bool tagItemsRefs})
    >;
typedef $$SinceWhenItemsTableCreateCompanionBuilder =
    SinceWhenItemsCompanion Function({
      Value<int> id,
      required int createdTimeStamp,
      required int reviewedTimeStamp,
      required int editedTimeStamp,
      Value<int?> parentTimeStamp,
      Value<int?> eventTimeStamp,
      Value<int> sequenceNumber,
      Value<String?> metaData,
      required String content,
    });
typedef $$SinceWhenItemsTableUpdateCompanionBuilder =
    SinceWhenItemsCompanion Function({
      Value<int> id,
      Value<int> createdTimeStamp,
      Value<int> reviewedTimeStamp,
      Value<int> editedTimeStamp,
      Value<int?> parentTimeStamp,
      Value<int?> eventTimeStamp,
      Value<int> sequenceNumber,
      Value<String?> metaData,
      Value<String> content,
    });

final class $$SinceWhenItemsTableReferences
    extends
        BaseReferences<
          _$SinceWhenDatabase,
          $SinceWhenItemsTable,
          SinceWhenItem
        > {
  $$SinceWhenItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TagItemsTable, List<TagItem>> _tagItemsRefsTable(
    _$SinceWhenDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tagItems,
    aliasName: 'sinceWhen__createdTimeStamp__tags__record_timestamp',
  );

  $$TagItemsTableProcessedTableManager get tagItemsRefs {
    final manager = $$TagItemsTableTableManager($_db, $_db.tagItems).filter(
      (f) => f.recordTimestamp.createdTimeStamp.sqlEquals(
        $_itemColumn<int>('createdTimeStamp')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_tagItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SinceWhenItemsTableFilterComposer
    extends Composer<_$SinceWhenDatabase, $SinceWhenItemsTable> {
  $$SinceWhenItemsTableFilterComposer({
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

  ColumnFilters<int> get createdTimeStamp => $composableBuilder(
    column: $table.createdTimeStamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewedTimeStamp => $composableBuilder(
    column: $table.reviewedTimeStamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get editedTimeStamp => $composableBuilder(
    column: $table.editedTimeStamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentTimeStamp => $composableBuilder(
    column: $table.parentTimeStamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventTimeStamp => $composableBuilder(
    column: $table.eventTimeStamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metaData => $composableBuilder(
    column: $table.metaData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tagItemsRefs(
    Expression<bool> Function($$TagItemsTableFilterComposer f) f,
  ) {
    final $$TagItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdTimeStamp,
      referencedTable: $db.tagItems,
      getReferencedColumn: (t) => t.recordTimestamp,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagItemsTableFilterComposer(
            $db: $db,
            $table: $db.tagItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SinceWhenItemsTableOrderingComposer
    extends Composer<_$SinceWhenDatabase, $SinceWhenItemsTable> {
  $$SinceWhenItemsTableOrderingComposer({
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

  ColumnOrderings<int> get createdTimeStamp => $composableBuilder(
    column: $table.createdTimeStamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewedTimeStamp => $composableBuilder(
    column: $table.reviewedTimeStamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get editedTimeStamp => $composableBuilder(
    column: $table.editedTimeStamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentTimeStamp => $composableBuilder(
    column: $table.parentTimeStamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventTimeStamp => $composableBuilder(
    column: $table.eventTimeStamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metaData => $composableBuilder(
    column: $table.metaData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SinceWhenItemsTableAnnotationComposer
    extends Composer<_$SinceWhenDatabase, $SinceWhenItemsTable> {
  $$SinceWhenItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdTimeStamp => $composableBuilder(
    column: $table.createdTimeStamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewedTimeStamp => $composableBuilder(
    column: $table.reviewedTimeStamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get editedTimeStamp => $composableBuilder(
    column: $table.editedTimeStamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parentTimeStamp => $composableBuilder(
    column: $table.parentTimeStamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eventTimeStamp => $composableBuilder(
    column: $table.eventTimeStamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metaData =>
      $composableBuilder(column: $table.metaData, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  Expression<T> tagItemsRefs<T extends Object>(
    Expression<T> Function($$TagItemsTableAnnotationComposer a) f,
  ) {
    final $$TagItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdTimeStamp,
      referencedTable: $db.tagItems,
      getReferencedColumn: (t) => t.recordTimestamp,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.tagItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SinceWhenItemsTableTableManager
    extends
        RootTableManager<
          _$SinceWhenDatabase,
          $SinceWhenItemsTable,
          SinceWhenItem,
          $$SinceWhenItemsTableFilterComposer,
          $$SinceWhenItemsTableOrderingComposer,
          $$SinceWhenItemsTableAnnotationComposer,
          $$SinceWhenItemsTableCreateCompanionBuilder,
          $$SinceWhenItemsTableUpdateCompanionBuilder,
          (SinceWhenItem, $$SinceWhenItemsTableReferences),
          SinceWhenItem,
          PrefetchHooks Function({bool tagItemsRefs})
        > {
  $$SinceWhenItemsTableTableManager(
    _$SinceWhenDatabase db,
    $SinceWhenItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SinceWhenItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SinceWhenItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SinceWhenItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> createdTimeStamp = const Value.absent(),
                Value<int> reviewedTimeStamp = const Value.absent(),
                Value<int> editedTimeStamp = const Value.absent(),
                Value<int?> parentTimeStamp = const Value.absent(),
                Value<int?> eventTimeStamp = const Value.absent(),
                Value<int> sequenceNumber = const Value.absent(),
                Value<String?> metaData = const Value.absent(),
                Value<String> content = const Value.absent(),
              }) => SinceWhenItemsCompanion(
                id: id,
                createdTimeStamp: createdTimeStamp,
                reviewedTimeStamp: reviewedTimeStamp,
                editedTimeStamp: editedTimeStamp,
                parentTimeStamp: parentTimeStamp,
                eventTimeStamp: eventTimeStamp,
                sequenceNumber: sequenceNumber,
                metaData: metaData,
                content: content,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdTimeStamp,
                required int reviewedTimeStamp,
                required int editedTimeStamp,
                Value<int?> parentTimeStamp = const Value.absent(),
                Value<int?> eventTimeStamp = const Value.absent(),
                Value<int> sequenceNumber = const Value.absent(),
                Value<String?> metaData = const Value.absent(),
                required String content,
              }) => SinceWhenItemsCompanion.insert(
                id: id,
                createdTimeStamp: createdTimeStamp,
                reviewedTimeStamp: reviewedTimeStamp,
                editedTimeStamp: editedTimeStamp,
                parentTimeStamp: parentTimeStamp,
                eventTimeStamp: eventTimeStamp,
                sequenceNumber: sequenceNumber,
                metaData: metaData,
                content: content,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SinceWhenItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tagItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tagItemsRefs) db.tagItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tagItemsRefs)
                    await $_getPrefetchedData<
                      SinceWhenItem,
                      $SinceWhenItemsTable,
                      TagItem
                    >(
                      currentTable: table,
                      referencedTable: $$SinceWhenItemsTableReferences
                          ._tagItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SinceWhenItemsTableReferences(
                            db,
                            table,
                            p0,
                          ).tagItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.recordTimestamp == item.createdTimeStamp,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SinceWhenItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$SinceWhenDatabase,
      $SinceWhenItemsTable,
      SinceWhenItem,
      $$SinceWhenItemsTableFilterComposer,
      $$SinceWhenItemsTableOrderingComposer,
      $$SinceWhenItemsTableAnnotationComposer,
      $$SinceWhenItemsTableCreateCompanionBuilder,
      $$SinceWhenItemsTableUpdateCompanionBuilder,
      (SinceWhenItem, $$SinceWhenItemsTableReferences),
      SinceWhenItem,
      PrefetchHooks Function({bool tagItemsRefs})
    >;
typedef $$TagItemsTableCreateCompanionBuilder =
    TagItemsCompanion Function({
      Value<int> id,
      required int recordTimestamp,
      required int glossaryTimestamp,
    });
typedef $$TagItemsTableUpdateCompanionBuilder =
    TagItemsCompanion Function({
      Value<int> id,
      Value<int> recordTimestamp,
      Value<int> glossaryTimestamp,
    });

final class $$TagItemsTableReferences
    extends BaseReferences<_$SinceWhenDatabase, $TagItemsTable, TagItem> {
  $$TagItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SinceWhenItemsTable _recordTimestampTable(_$SinceWhenDatabase db) =>
      db.sinceWhenItems.createAlias(
        'tags__record_timestamp__sinceWhen__createdTimeStamp',
      );

  $$SinceWhenItemsTableProcessedTableManager get recordTimestamp {
    final $_column = $_itemColumn<int>('record_timestamp')!;

    final manager = $$SinceWhenItemsTableTableManager(
      $_db,
      $_db.sinceWhenItems,
    ).filter((f) => f.createdTimeStamp.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recordTimestampTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GlossaryItemsTable _glossaryTimestampTable(_$SinceWhenDatabase db) =>
      db.glossaryItems.createAlias(
        'tags__glossary_timestamp__tagGlossary__createdTimeStamp',
      );

  $$GlossaryItemsTableProcessedTableManager get glossaryTimestamp {
    final $_column = $_itemColumn<int>('glossary_timestamp')!;

    final manager = $$GlossaryItemsTableTableManager(
      $_db,
      $_db.glossaryItems,
    ).filter((f) => f.createdTimeStamp.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_glossaryTimestampTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TagItemsTableFilterComposer
    extends Composer<_$SinceWhenDatabase, $TagItemsTable> {
  $$TagItemsTableFilterComposer({
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

  $$SinceWhenItemsTableFilterComposer get recordTimestamp {
    final $$SinceWhenItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordTimestamp,
      referencedTable: $db.sinceWhenItems,
      getReferencedColumn: (t) => t.createdTimeStamp,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SinceWhenItemsTableFilterComposer(
            $db: $db,
            $table: $db.sinceWhenItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GlossaryItemsTableFilterComposer get glossaryTimestamp {
    final $$GlossaryItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.glossaryTimestamp,
      referencedTable: $db.glossaryItems,
      getReferencedColumn: (t) => t.createdTimeStamp,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GlossaryItemsTableFilterComposer(
            $db: $db,
            $table: $db.glossaryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagItemsTableOrderingComposer
    extends Composer<_$SinceWhenDatabase, $TagItemsTable> {
  $$TagItemsTableOrderingComposer({
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

  $$SinceWhenItemsTableOrderingComposer get recordTimestamp {
    final $$SinceWhenItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordTimestamp,
      referencedTable: $db.sinceWhenItems,
      getReferencedColumn: (t) => t.createdTimeStamp,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SinceWhenItemsTableOrderingComposer(
            $db: $db,
            $table: $db.sinceWhenItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GlossaryItemsTableOrderingComposer get glossaryTimestamp {
    final $$GlossaryItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.glossaryTimestamp,
      referencedTable: $db.glossaryItems,
      getReferencedColumn: (t) => t.createdTimeStamp,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GlossaryItemsTableOrderingComposer(
            $db: $db,
            $table: $db.glossaryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagItemsTableAnnotationComposer
    extends Composer<_$SinceWhenDatabase, $TagItemsTable> {
  $$TagItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$SinceWhenItemsTableAnnotationComposer get recordTimestamp {
    final $$SinceWhenItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordTimestamp,
      referencedTable: $db.sinceWhenItems,
      getReferencedColumn: (t) => t.createdTimeStamp,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SinceWhenItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.sinceWhenItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GlossaryItemsTableAnnotationComposer get glossaryTimestamp {
    final $$GlossaryItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.glossaryTimestamp,
      referencedTable: $db.glossaryItems,
      getReferencedColumn: (t) => t.createdTimeStamp,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GlossaryItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.glossaryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagItemsTableTableManager
    extends
        RootTableManager<
          _$SinceWhenDatabase,
          $TagItemsTable,
          TagItem,
          $$TagItemsTableFilterComposer,
          $$TagItemsTableOrderingComposer,
          $$TagItemsTableAnnotationComposer,
          $$TagItemsTableCreateCompanionBuilder,
          $$TagItemsTableUpdateCompanionBuilder,
          (TagItem, $$TagItemsTableReferences),
          TagItem,
          PrefetchHooks Function({bool recordTimestamp, bool glossaryTimestamp})
        > {
  $$TagItemsTableTableManager(_$SinceWhenDatabase db, $TagItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recordTimestamp = const Value.absent(),
                Value<int> glossaryTimestamp = const Value.absent(),
              }) => TagItemsCompanion(
                id: id,
                recordTimestamp: recordTimestamp,
                glossaryTimestamp: glossaryTimestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recordTimestamp,
                required int glossaryTimestamp,
              }) => TagItemsCompanion.insert(
                id: id,
                recordTimestamp: recordTimestamp,
                glossaryTimestamp: glossaryTimestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TagItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({recordTimestamp = false, glossaryTimestamp = false}) {
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
                        if (recordTimestamp) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.recordTimestamp,
                                    referencedTable: $$TagItemsTableReferences
                                        ._recordTimestampTable(db),
                                    referencedColumn: $$TagItemsTableReferences
                                        ._recordTimestampTable(db)
                                        .createdTimeStamp,
                                  )
                                  as T;
                        }
                        if (glossaryTimestamp) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.glossaryTimestamp,
                                    referencedTable: $$TagItemsTableReferences
                                        ._glossaryTimestampTable(db),
                                    referencedColumn: $$TagItemsTableReferences
                                        ._glossaryTimestampTable(db)
                                        .createdTimeStamp,
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

typedef $$TagItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$SinceWhenDatabase,
      $TagItemsTable,
      TagItem,
      $$TagItemsTableFilterComposer,
      $$TagItemsTableOrderingComposer,
      $$TagItemsTableAnnotationComposer,
      $$TagItemsTableCreateCompanionBuilder,
      $$TagItemsTableUpdateCompanionBuilder,
      (TagItem, $$TagItemsTableReferences),
      TagItem,
      PrefetchHooks Function({bool recordTimestamp, bool glossaryTimestamp})
    >;

class $SinceWhenDatabaseManager {
  final _$SinceWhenDatabase _db;
  $SinceWhenDatabaseManager(this._db);
  $$GlossaryItemsTableTableManager get glossaryItems =>
      $$GlossaryItemsTableTableManager(_db, _db.glossaryItems);
  $$SinceWhenItemsTableTableManager get sinceWhenItems =>
      $$SinceWhenItemsTableTableManager(_db, _db.sinceWhenItems);
  $$TagItemsTableTableManager get tagItems =>
      $$TagItemsTableTableManager(_db, _db.tagItems);
}
