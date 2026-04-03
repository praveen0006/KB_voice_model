import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/logger.dart';
import '../../domain/entities/vital_record.dart';
import '../../domain/repositories/vitals_repository.dart';
import '../models/vital_record_model.dart';

/// JSON file-based implementation of [VitalsRepository].
///
/// Stores records in an append-only JSON array file
/// in the app's documents directory.
class VitalsRepositoryImpl implements VitalsRepository {
  static const String _fileName = 'vitals_records.json';

  File? _cachedFile;

  /// Get the storage file path.
  Future<File> get _file async {
    if (_cachedFile != null) return _cachedFile!;
    final dir = await getApplicationDocumentsDirectory();
    _cachedFile = File('${dir.path}/$_fileName');
    return _cachedFile!;
  }

  @override
  Future<void> saveRecord(VitalRecord record) async {
    try {
      final file = await _file;
      final records = await _readRecords(file);
      final model = VitalRecordModel.fromEntity(record);
      records.add(model.toJson());
      await file.writeAsString(jsonEncode(records));
      VitalsLogger.logInfo('Record saved successfully');
    } catch (e, stack) {
      VitalsLogger.logError('Failed to save record', e, stack);
      rethrow;
    }
  }

  @override
  Future<List<VitalRecord>> getAllRecords() async {
    try {
      final file = await _file;
      final records = await _readRecords(file);
      final models = records
          .map((json) =>
              VitalRecordModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort newest first
      models.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return models.map((m) => m.toEntity()).toList();
    } catch (e, stack) {
      VitalsLogger.logError('Failed to read records', e, stack);
      return [];
    }
  }

  @override
  Future<String> exportToCsv() async {
    final file = await _file;
    final records = await _readRecords(file);

    final buffer = StringBuffer();
    buffer.writeln(VitalRecordModel.csvHeader);

    for (final json in records) {
      final model =
          VitalRecordModel.fromJson(json as Map<String, dynamic>);
      buffer.writeln(model.toCsvRow());
    }

    return buffer.toString();
  }

  @override
  Future<void> clearAll() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        await file.writeAsString(jsonEncode([]));
      }
      VitalsLogger.logInfo('All records cleared');
    } catch (e, stack) {
      VitalsLogger.logError('Failed to clear records', e, stack);
      rethrow;
    }
  }

  /// Read existing records from file, returns empty list if file doesn't exist.
  Future<List<dynamic>> _readRecords(File file) async {
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];

    try {
      return jsonDecode(content) as List<dynamic>;
    } catch (e) {
      VitalsLogger.logError('Corrupt JSON file, resetting', e);
      return [];
    }
  }
}
