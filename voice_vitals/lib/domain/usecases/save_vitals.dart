import '../../core/logger.dart';
import '../entities/vital_record.dart';
import '../repositories/vitals_repository.dart';

/// Use case: Save a confirmed vital record to storage.
class SaveVitalsUseCase {
  final VitalsRepository _repository;

  const SaveVitalsUseCase({required VitalsRepository repository})
      : _repository = repository;

  /// Save the record. Returns true on success.
  Future<bool> execute(VitalRecord record) async {
    try {
      await _repository.saveRecord(record);
      VitalsLogger.logInfo('Vitals saved: $record');
      return true;
    } catch (e, stack) {
      VitalsLogger.logError('Failed to save vitals', e, stack);
      return false;
    }
  }
}
