import '../entities/vital_record.dart';

/// Abstract repository interface for vitals storage.
///
/// Decouples domain logic from storage implementation.
/// Current implementation: JSON file. Future: SQLite.
abstract class VitalsRepository {
  /// Save a vital record.
  Future<void> saveRecord(VitalRecord record);

  /// Get all saved records, ordered by timestamp (newest first).
  Future<List<VitalRecord>> getAllRecords();

  /// Export all records as CSV string.
  Future<String> exportToCsv();

  /// Delete all records.
  Future<void> clearAll();
}
