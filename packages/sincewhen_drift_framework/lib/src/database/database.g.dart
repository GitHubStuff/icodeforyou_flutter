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
  static const VerificationMeta _createdTimestampMeta = const VerificationMeta(
    'createdTimestamp',
  );
  @override
  late final GeneratedColumn<int> createdTimestamp = GeneratedColumn<int>(
    'createdTimestamp',
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
    'colorArgb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdTimestamp, tag, colorArgb];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'glossary';
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
    if (data.containsKey('createdTimestamp')) {
      context.handle(
        _createdTimestampMeta,
        createdTimestamp.isAcceptableOrUnknown(
          data['createdTimestamp']!,
          _createdTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdTimestampMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('colorArgb')) {
      context.handle(
        _colorArgbMeta,
        colorArgb.isAcceptableOrUnknown(data['colorArgb']!, _colorArgbMeta),
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
      createdTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}createdTimestamp'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      colorArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}colorArgb'],
      )!,
    );
  }

  @override
  $GlossaryItemsTable createAlias(String alias) {
    return $GlossaryItemsTable(attachedDatabase, alias);
  }
}

class GlossaryItemsCompanion extends UpdateCompanion<GlossaryItem> {
  final Value<int> id;
  final Value<int> createdTimestamp;
  final Value<String> tag;
  final Value<int> colorArgb;
  const GlossaryItemsCompanion({
    this.id = const Value.absent(),
    this.createdTimestamp = const Value.absent(),
    this.tag = const Value.absent(),
    this.colorArgb = const Value.absent(),
  });
  GlossaryItemsCompanion.insert({
    this.id = const Value.absent(),
    required int createdTimestamp,
    required String tag,
    required int colorArgb,
  }) : createdTimestamp = Value(createdTimestamp),
       tag = Value(tag),
       colorArgb = Value(colorArgb);
  static Insertable<GlossaryItem> custom({
    Expression<int>? id,
    Expression<int>? createdTimestamp,
    Expression<String>? tag,
    Expression<int>? colorArgb,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdTimestamp != null) 'createdTimestamp': createdTimestamp,
      if (tag != null) 'tag': tag,
      if (colorArgb != null) 'colorArgb': colorArgb,
    });
  }

  GlossaryItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? createdTimestamp,
    Value<String>? tag,
    Value<int>? colorArgb,
  }) {
    return GlossaryItemsCompanion(
      id: id ?? this.id,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
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
    if (createdTimestamp.present) {
      map['createdTimestamp'] = Variable<int>(createdTimestamp.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (colorArgb.present) {
      map['colorArgb'] = Variable<int>(colorArgb.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GlossaryItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdTimestamp: $createdTimestamp, ')
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
  static const VerificationMeta _createdTimestampMeta = const VerificationMeta(
    'createdTimestamp',
  );
  @override
  late final GeneratedColumn<int> createdTimestamp = GeneratedColumn<int>(
    'createdTimestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _reviewedTimestampMeta = const VerificationMeta(
    'reviewedTimestamp',
  );
  @override
  late final GeneratedColumn<int> reviewedTimestamp = GeneratedColumn<int>(
    'reviewedTimestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editedTimestampMeta = const VerificationMeta(
    'editedTimestamp',
  );
  @override
  late final GeneratedColumn<int> editedTimestamp = GeneratedColumn<int>(
    'editedTimestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentTimestampMeta = const VerificationMeta(
    'parentTimestamp',
  );
  @override
  late final GeneratedColumn<int> parentTimestamp = GeneratedColumn<int>(
    'parentTimestamp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTimestampMeta = const VerificationMeta(
    'eventTimestamp',
  );
  @override
  late final GeneratedColumn<int> eventTimestamp = GeneratedColumn<int>(
    'eventTimestamp',
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
  static const VerificationMeta _tldrMeta = const VerificationMeta('tldr');
  @override
  late final GeneratedColumn<String> tldr = GeneratedColumn<String>(
    'tldr',
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
    createdTimestamp,
    reviewedTimestamp,
    editedTimestamp,
    parentTimestamp,
    eventTimestamp,
    sequenceNumber,
    metaData,
    tldr,
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
    if (data.containsKey('createdTimestamp')) {
      context.handle(
        _createdTimestampMeta,
        createdTimestamp.isAcceptableOrUnknown(
          data['createdTimestamp']!,
          _createdTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdTimestampMeta);
    }
    if (data.containsKey('reviewedTimestamp')) {
      context.handle(
        _reviewedTimestampMeta,
        reviewedTimestamp.isAcceptableOrUnknown(
          data['reviewedTimestamp']!,
          _reviewedTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewedTimestampMeta);
    }
    if (data.containsKey('editedTimestamp')) {
      context.handle(
        _editedTimestampMeta,
        editedTimestamp.isAcceptableOrUnknown(
          data['editedTimestamp']!,
          _editedTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_editedTimestampMeta);
    }
    if (data.containsKey('parentTimestamp')) {
      context.handle(
        _parentTimestampMeta,
        parentTimestamp.isAcceptableOrUnknown(
          data['parentTimestamp']!,
          _parentTimestampMeta,
        ),
      );
    }
    if (data.containsKey('eventTimestamp')) {
      context.handle(
        _eventTimestampMeta,
        eventTimestamp.isAcceptableOrUnknown(
          data['eventTimestamp']!,
          _eventTimestampMeta,
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
    if (data.containsKey('tldr')) {
      context.handle(
        _tldrMeta,
        tldr.isAcceptableOrUnknown(data['tldr']!, _tldrMeta),
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
      createdTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}createdTimestamp'],
      )!,
      reviewedTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviewedTimestamp'],
      )!,
      editedTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}editedTimestamp'],
      )!,
      sequenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequenceNumber'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      parentTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parentTimestamp'],
      ),
      eventTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eventTimestamp'],
      ),
      metaData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metaData'],
      ),
      tldr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tldr'],
      ),
    );
  }

  @override
  $SinceWhenItemsTable createAlias(String alias) {
    return $SinceWhenItemsTable(attachedDatabase, alias);
  }
}

class SinceWhenItemsCompanion extends UpdateCompanion<SinceWhenItem> {
  final Value<int> id;
  final Value<int> createdTimestamp;
  final Value<int> reviewedTimestamp;
  final Value<int> editedTimestamp;
  final Value<int?> parentTimestamp;
  final Value<int?> eventTimestamp;
  final Value<int> sequenceNumber;
  final Value<String?> metaData;
  final Value<String?> tldr;
  final Value<String> content;
  const SinceWhenItemsCompanion({
    this.id = const Value.absent(),
    this.createdTimestamp = const Value.absent(),
    this.reviewedTimestamp = const Value.absent(),
    this.editedTimestamp = const Value.absent(),
    this.parentTimestamp = const Value.absent(),
    this.eventTimestamp = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.metaData = const Value.absent(),
    this.tldr = const Value.absent(),
    this.content = const Value.absent(),
  });
  SinceWhenItemsCompanion.insert({
    this.id = const Value.absent(),
    required int createdTimestamp,
    required int reviewedTimestamp,
    required int editedTimestamp,
    this.parentTimestamp = const Value.absent(),
    this.eventTimestamp = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.metaData = const Value.absent(),
    this.tldr = const Value.absent(),
    required String content,
  }) : createdTimestamp = Value(createdTimestamp),
       reviewedTimestamp = Value(reviewedTimestamp),
       editedTimestamp = Value(editedTimestamp),
       content = Value(content);
  static Insertable<SinceWhenItem> custom({
    Expression<int>? id,
    Expression<int>? createdTimestamp,
    Expression<int>? reviewedTimestamp,
    Expression<int>? editedTimestamp,
    Expression<int>? parentTimestamp,
    Expression<int>? eventTimestamp,
    Expression<int>? sequenceNumber,
    Expression<String>? metaData,
    Expression<String>? tldr,
    Expression<String>? content,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdTimestamp != null) 'createdTimestamp': createdTimestamp,
      if (reviewedTimestamp != null) 'reviewedTimestamp': reviewedTimestamp,
      if (editedTimestamp != null) 'editedTimestamp': editedTimestamp,
      if (parentTimestamp != null) 'parentTimestamp': parentTimestamp,
      if (eventTimestamp != null) 'eventTimestamp': eventTimestamp,
      if (sequenceNumber != null) 'sequenceNumber': sequenceNumber,
      if (metaData != null) 'metaData': metaData,
      if (tldr != null) 'tldr': tldr,
      if (content != null) 'content': content,
    });
  }

  SinceWhenItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? createdTimestamp,
    Value<int>? reviewedTimestamp,
    Value<int>? editedTimestamp,
    Value<int?>? parentTimestamp,
    Value<int?>? eventTimestamp,
    Value<int>? sequenceNumber,
    Value<String?>? metaData,
    Value<String?>? tldr,
    Value<String>? content,
  }) {
    return SinceWhenItemsCompanion(
      id: id ?? this.id,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      reviewedTimestamp: reviewedTimestamp ?? this.reviewedTimestamp,
      editedTimestamp: editedTimestamp ?? this.editedTimestamp,
      parentTimestamp: parentTimestamp ?? this.parentTimestamp,
      eventTimestamp: eventTimestamp ?? this.eventTimestamp,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      metaData: metaData ?? this.metaData,
      tldr: tldr ?? this.tldr,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdTimestamp.present) {
      map['createdTimestamp'] = Variable<int>(createdTimestamp.value);
    }
    if (reviewedTimestamp.present) {
      map['reviewedTimestamp'] = Variable<int>(reviewedTimestamp.value);
    }
    if (editedTimestamp.present) {
      map['editedTimestamp'] = Variable<int>(editedTimestamp.value);
    }
    if (parentTimestamp.present) {
      map['parentTimestamp'] = Variable<int>(parentTimestamp.value);
    }
    if (eventTimestamp.present) {
      map['eventTimestamp'] = Variable<int>(eventTimestamp.value);
    }
    if (sequenceNumber.present) {
      map['sequenceNumber'] = Variable<int>(sequenceNumber.value);
    }
    if (metaData.present) {
      map['metaData'] = Variable<String>(metaData.value);
    }
    if (tldr.present) {
      map['tldr'] = Variable<String>(tldr.value);
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
          ..write('createdTimestamp: $createdTimestamp, ')
          ..write('reviewedTimestamp: $reviewedTimestamp, ')
          ..write('editedTimestamp: $editedTimestamp, ')
          ..write('parentTimestamp: $parentTimestamp, ')
          ..write('eventTimestamp: $eventTimestamp, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('metaData: $metaData, ')
          ..write('tldr: $tldr, ')
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
      'REFERENCES sinceWhen (createdTimestamp) ON DELETE CASCADE',
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
      'REFERENCES glossary (createdTimestamp) ON DELETE CASCADE',
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
  late final Index idxSinceWhenParent = Index(
    'idx_since_when_parent',
    'CREATE INDEX idx_since_when_parent ON sinceWhen (parentTimestamp)',
  );
  late final Index idxSinceWhenEvent = Index(
    'idx_since_when_event',
    'CREATE INDEX idx_since_when_event ON sinceWhen (eventTimestamp)',
  );
  late final Index idxSinceWhenEdited = Index(
    'idx_since_when_edited',
    'CREATE INDEX idx_since_when_edited ON sinceWhen (editedTimestamp)',
  );
  late final Index idxSinceWhenReviewed = Index(
    'idx_since_when_reviewed',
    'CREATE INDEX idx_since_when_reviewed ON sinceWhen (reviewedTimestamp)',
  );
  late final Index idxTagsGlossary = Index(
    'idx_tags_glossary',
    'CREATE INDEX idx_tags_glossary ON tags (glossary_timestamp)',
  );
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
    idxSinceWhenParent,
    idxSinceWhenEvent,
    idxSinceWhenEdited,
    idxSinceWhenReviewed,
    idxTagsGlossary,
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
        'glossary',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tags', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$GlossaryItemsTableCreateCompanionBuilder =
    GlossaryItemsCompanion Function({
      Value<int> id,
      required int createdTimestamp,
      required String tag,
      required int colorArgb,
    });
typedef $$GlossaryItemsTableUpdateCompanionBuilder =
    GlossaryItemsCompanion Function({
      Value<int> id,
      Value<int> createdTimestamp,
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
    aliasName: 'glossary__createdTimestamp__tags__glossary_timestamp',
  );

  $$TagItemsTableProcessedTableManager get tagItemsRefs {
    final manager = $$TagItemsTableTableManager($_db, $_db.tagItems).filter(
      (f) => f.glossaryTimestamp.createdTimestamp.sqlEquals(
        $_itemColumn<int>('createdTimestamp')!,
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

  ColumnFilters<int> get createdTimestamp => $composableBuilder(
    column: $table.createdTimestamp,
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
      getCurrentColumn: (t) => t.createdTimestamp,
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

  ColumnOrderings<int> get createdTimestamp => $composableBuilder(
    column: $table.createdTimestamp,
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

  GeneratedColumn<int> get createdTimestamp => $composableBuilder(
    column: $table.createdTimestamp,
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
      getCurrentColumn: (t) => t.createdTimestamp,
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
                Value<int> createdTimestamp = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<int> colorArgb = const Value.absent(),
              }) => GlossaryItemsCompanion(
                id: id,
                createdTimestamp: createdTimestamp,
                tag: tag,
                colorArgb: colorArgb,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdTimestamp,
                required String tag,
                required int colorArgb,
              }) => GlossaryItemsCompanion.insert(
                id: id,
                createdTimestamp: createdTimestamp,
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
                            (e) => e.glossaryTimestamp == item.createdTimestamp,
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
      required int createdTimestamp,
      required int reviewedTimestamp,
      required int editedTimestamp,
      Value<int?> parentTimestamp,
      Value<int?> eventTimestamp,
      Value<int> sequenceNumber,
      Value<String?> metaData,
      Value<String?> tldr,
      required String content,
    });
typedef $$SinceWhenItemsTableUpdateCompanionBuilder =
    SinceWhenItemsCompanion Function({
      Value<int> id,
      Value<int> createdTimestamp,
      Value<int> reviewedTimestamp,
      Value<int> editedTimestamp,
      Value<int?> parentTimestamp,
      Value<int?> eventTimestamp,
      Value<int> sequenceNumber,
      Value<String?> metaData,
      Value<String?> tldr,
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
    aliasName: 'sinceWhen__createdTimestamp__tags__record_timestamp',
  );

  $$TagItemsTableProcessedTableManager get tagItemsRefs {
    final manager = $$TagItemsTableTableManager($_db, $_db.tagItems).filter(
      (f) => f.recordTimestamp.createdTimestamp.sqlEquals(
        $_itemColumn<int>('createdTimestamp')!,
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

  ColumnFilters<int> get createdTimestamp => $composableBuilder(
    column: $table.createdTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewedTimestamp => $composableBuilder(
    column: $table.reviewedTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get editedTimestamp => $composableBuilder(
    column: $table.editedTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentTimestamp => $composableBuilder(
    column: $table.parentTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventTimestamp => $composableBuilder(
    column: $table.eventTimestamp,
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

  ColumnFilters<String> get tldr => $composableBuilder(
    column: $table.tldr,
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
      getCurrentColumn: (t) => t.createdTimestamp,
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

  ColumnOrderings<int> get createdTimestamp => $composableBuilder(
    column: $table.createdTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewedTimestamp => $composableBuilder(
    column: $table.reviewedTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get editedTimestamp => $composableBuilder(
    column: $table.editedTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentTimestamp => $composableBuilder(
    column: $table.parentTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventTimestamp => $composableBuilder(
    column: $table.eventTimestamp,
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

  ColumnOrderings<String> get tldr => $composableBuilder(
    column: $table.tldr,
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

  GeneratedColumn<int> get createdTimestamp => $composableBuilder(
    column: $table.createdTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewedTimestamp => $composableBuilder(
    column: $table.reviewedTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get editedTimestamp => $composableBuilder(
    column: $table.editedTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parentTimestamp => $composableBuilder(
    column: $table.parentTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eventTimestamp => $composableBuilder(
    column: $table.eventTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metaData =>
      $composableBuilder(column: $table.metaData, builder: (column) => column);

  GeneratedColumn<String> get tldr =>
      $composableBuilder(column: $table.tldr, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  Expression<T> tagItemsRefs<T extends Object>(
    Expression<T> Function($$TagItemsTableAnnotationComposer a) f,
  ) {
    final $$TagItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdTimestamp,
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
                Value<int> createdTimestamp = const Value.absent(),
                Value<int> reviewedTimestamp = const Value.absent(),
                Value<int> editedTimestamp = const Value.absent(),
                Value<int?> parentTimestamp = const Value.absent(),
                Value<int?> eventTimestamp = const Value.absent(),
                Value<int> sequenceNumber = const Value.absent(),
                Value<String?> metaData = const Value.absent(),
                Value<String?> tldr = const Value.absent(),
                Value<String> content = const Value.absent(),
              }) => SinceWhenItemsCompanion(
                id: id,
                createdTimestamp: createdTimestamp,
                reviewedTimestamp: reviewedTimestamp,
                editedTimestamp: editedTimestamp,
                parentTimestamp: parentTimestamp,
                eventTimestamp: eventTimestamp,
                sequenceNumber: sequenceNumber,
                metaData: metaData,
                tldr: tldr,
                content: content,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdTimestamp,
                required int reviewedTimestamp,
                required int editedTimestamp,
                Value<int?> parentTimestamp = const Value.absent(),
                Value<int?> eventTimestamp = const Value.absent(),
                Value<int> sequenceNumber = const Value.absent(),
                Value<String?> metaData = const Value.absent(),
                Value<String?> tldr = const Value.absent(),
                required String content,
              }) => SinceWhenItemsCompanion.insert(
                id: id,
                createdTimestamp: createdTimestamp,
                reviewedTimestamp: reviewedTimestamp,
                editedTimestamp: editedTimestamp,
                parentTimestamp: parentTimestamp,
                eventTimestamp: eventTimestamp,
                sequenceNumber: sequenceNumber,
                metaData: metaData,
                tldr: tldr,
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
                            (e) => e.recordTimestamp == item.createdTimestamp,
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
        'tags__record_timestamp__sinceWhen__createdTimestamp',
      );

  $$SinceWhenItemsTableProcessedTableManager get recordTimestamp {
    final $_column = $_itemColumn<int>('record_timestamp')!;

    final manager = $$SinceWhenItemsTableTableManager(
      $_db,
      $_db.sinceWhenItems,
    ).filter((f) => f.createdTimestamp.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recordTimestampTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GlossaryItemsTable _glossaryTimestampTable(_$SinceWhenDatabase db) =>
      db.glossaryItems.createAlias(
        'tags__glossary_timestamp__glossary__createdTimestamp',
      );

  $$GlossaryItemsTableProcessedTableManager get glossaryTimestamp {
    final $_column = $_itemColumn<int>('glossary_timestamp')!;

    final manager = $$GlossaryItemsTableTableManager(
      $_db,
      $_db.glossaryItems,
    ).filter((f) => f.createdTimestamp.sqlEquals($_column));
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
      getReferencedColumn: (t) => t.createdTimestamp,
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
      getReferencedColumn: (t) => t.createdTimestamp,
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
      getReferencedColumn: (t) => t.createdTimestamp,
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
      getReferencedColumn: (t) => t.createdTimestamp,
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
      getReferencedColumn: (t) => t.createdTimestamp,
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
      getReferencedColumn: (t) => t.createdTimestamp,
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
                                        .createdTimestamp,
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
                                        .createdTimestamp,
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
