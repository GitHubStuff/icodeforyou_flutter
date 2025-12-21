// icodeforyou_flutter/packages/since_when/lib/src/sql/create/_create_operations.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/data/_since_when_record_mapper.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:since_when/src/utils/_timestamp_generator.dart';
import 'package:sqflite/sqflite.dart';

/// Handles CRUD Create operations for SinceWhen records.
///
/// This class is internal and should not be exported publicly.
abstract final class CreateOperations {
  /// Creates a new record in the database.
  ///
  /// If [parentTimeStamp] is provided:
  /// - Validates the parent exists (sets to null if not found)
  /// - Calculates sequenceNumber as max(siblings) + 1
  ///
  /// If [parentTimeStamp] is null:
  /// - sequenceNumber defaults to 0
  ///
  /// Returns [Right] with created [SinceWhenRecord] on success.
  /// Returns [Left] with appropriate [SinceWhenFailure] on error.
  static Future<Either<SinceWhenFailure, SinceWhenRecord>> createRecord(
    Database db, {
    required String metaData,
    required String dataString,
    required String category,
    required List<String> tags,
    String? parentTimeStamp,
  }) async {
    try {
      // Generate unique timestamp
      final timestampResult = await TimestampGenerator.generateUniqueTimestamp(
        db,
      );

      return timestampResult.fold(
        Left.new,
        (createdTimeStamp) async {
          // Validate parent and calculate sequence number
          final validatedParent = await _validateParent(db, parentTimeStamp);
          final sequenceNumber = await _calculateSequenceNumber(
            db,
            validatedParent,
          );

          // All timestamps start the same on creation
          final nowUtc = createdTimeStamp;

          // Insert the record
          final insertValues = SinceWhenRecordMapper.toInsertValuesFromParams(
            createdTimeStamp: createdTimeStamp,
            parentTimeStamp: validatedParent,
            reviewedTimeStamp: nowUtc,
            editedTimeStamp: nowUtc,
            metaTimeStamp: null,
            metaData: metaData,
            sequenceNumber: sequenceNumber,
            dataString: dataString,
            category: category,
          );

          final recordId = await db.rawInsert(
            SqlStatements.insertRecord,
            insertValues,
          );

          // Insert tags
          await _insertTags(db, createdTimeStamp, tags);

          // Build and return the record
          final record = SinceWhenRecord(
            id: recordId,
            createdTimeStamp: createdTimeStamp,
            parentTimeStamp: validatedParent,
            reviewedTimeStamp: nowUtc,
            editedTimeStamp: nowUtc,
            metaData: metaData,
            sequenceNumber: sequenceNumber,
            dataString: dataString,
            category: category,
            tags: tags,
          );

          return Right(record);
        },
      );
    } on Object catch (e) {
      return Left(UnexpectedDatabaseError('Failed to create record', e));
    }
  }

  /// Validates that the parent record exists.
  ///
  /// Returns the parentTimeStamp if valid, null otherwise.
  static Future<String?> _validateParent(
    Database db,
    String? parentTimeStamp,
  ) async {
    if (parentTimeStamp == null) {
      return null;
    }

    final result = await db.rawQuery(
      SqlStatements.existsByCreatedTimeStamp,
      [parentTimeStamp],
    );

    return result.isNotEmpty ? parentTimeStamp : null;
  }

  /// Calculates the sequence number for a new child record.
  ///
  /// Returns max(sequenceNumber) + 1 for siblings, or 1 if no siblings.
  /// Returns 0 if no parent (root record).
  static Future<int> _calculateSequenceNumber(
    Database db,
    String? parentTimeStamp,
  ) async {
    if (parentTimeStamp == null) {
      return 0;
    }

    final result = await db.rawQuery(
      SqlStatements.maxSequenceNumberForParent,
      [parentTimeStamp],
    );

    if (result.isEmpty || result.first['maxSeq'] == null) {
      return 1;
    }

    final maxSeq = result.first['maxSeq']! as int;
    return maxSeq + 1;
  }

  /// Inserts tags for a record into the junction table.
  static Future<void> _insertTags(
    Database db,
    String createdTimeStamp,
    List<String> tags,
  ) async {
    for (final tag in tags) {
      await db.rawInsert(
        SqlStatements.insertTag,
        [createdTimeStamp, tag],
      );
    }
  }
}
