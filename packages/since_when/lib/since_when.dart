// lib/since_when.dart

// Constants (public)
export 'package:since_when/src/constants/database_constants.dart';

// Domain exports (public)
export 'package:since_when/src/domain/data_store_failure.dart';
export 'package:since_when/src/domain/since_when_failure.dart'
    hide
        ExportFailed,
        FileNotFound,
        ImportFailed,
        InvalidTagName,
        ParentNotFound,
        RecordNotFound,
        TagInUse,
        TagNameAlreadyExists,
        TagNotFound;
export 'package:since_when/src/domain/since_when_import_mode.dart';
export 'package:since_when/src/domain/since_when_record.dart';
export 'package:since_when/src/domain/table_info.dart';
export 'package:since_when/src/domain/tag_definition.dart';
export 'package:since_when/src/domain/tag_match_mode.dart';

// Database API — SQLite implementation (public)
export 'package:since_when/src/since_when_database.dart';

// Store interfaces (public)
export 'package:since_when/src/store/store.dart';
