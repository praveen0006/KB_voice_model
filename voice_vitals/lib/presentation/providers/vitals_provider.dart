import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vital_record.dart';
import '../../domain/usecases/parse_vitals.dart';
import '../../domain/usecases/save_vitals.dart';
import '../../domain/repositories/vitals_repository.dart';
import '../../data/repositories/vitals_repository_impl.dart';
import '../../core/logger.dart';
import 'speech_provider.dart';

/// State for the vitals processing pipeline.
class VitalsState {
  final ParseVitalsResult? parseResult;
  final bool isSaving;
  final bool savedSuccessfully;
  final String? saveError;
  final List<VitalRecord> history;
  final String debugInfo;

  const VitalsState({
    this.parseResult,
    this.isSaving = false,
    this.savedSuccessfully = false,
    this.saveError,
    this.history = const [],
    this.debugInfo = '',
  });

  VitalsState copyWith({
    ParseVitalsResult? parseResult,
    bool? isSaving,
    bool? savedSuccessfully,
    String? saveError,
    List<VitalRecord>? history,
    bool clearParseResult = false,
    String? debugInfo,
  }) {
    return VitalsState(
      parseResult: clearParseResult ? null : (parseResult ?? this.parseResult),
      isSaving: isSaving ?? this.isSaving,
      savedSuccessfully: savedSuccessfully ?? this.savedSuccessfully,
      saveError: saveError,
      history: history ?? this.history,
      debugInfo: debugInfo ?? this.debugInfo,
    );
  }
}

/// Manages the vitals processing pipeline: parse → validate → confirm → save.
class VitalsNotifier extends StateNotifier<VitalsState> {
  final ParseVitalsUseCase _parseUseCase;
  final SaveVitalsUseCase _saveUseCase;
  final VitalsRepository _repository;

  VitalsNotifier({
    required VitalsRepository repository,
    ParseVitalsUseCase? parseUseCase,
    SaveVitalsUseCase? saveUseCase,
  })  : _repository = repository,
        _parseUseCase = parseUseCase ?? const ParseVitalsUseCase(),
        _saveUseCase =
            saveUseCase ?? SaveVitalsUseCase(repository: repository),
        super(const VitalsState()) {
    _loadHistory();
  }

  /// Parse a transcript and update state with results.
  void parseTranscript(String transcript) {
    if (transcript.trim().isEmpty) return;

    final result = _parseUseCase.execute(transcript);

    // Build debug info
    final parsed = result.parsed;
    final debugLines = StringBuffer();
    debugLines.writeln('RAW: "$transcript"');
    debugLines.writeln('PARSED → BP: ${parsed.systolic}/${parsed.diastolic} | HR: ${parsed.heartRate} | Temp: ${parsed.temperature} | SpO2: ${parsed.spo2} | RR: ${parsed.respirationRate}');

    state = state.copyWith(
      parseResult: result,
      savedSuccessfully: false,
      saveError: null,
      debugInfo: debugLines.toString(),
    );
  }

  /// Confirm and save the currently parsed vitals.
  Future<void> confirmAndSave() async {
    final result = state.parseResult;
    if (result == null || !result.hasData) return;

    final record = result.toRecord();
    if (record == null) return;

    state = state.copyWith(isSaving: true, saveError: null);

    final success = await _saveUseCase.execute(record);

    if (success) {
      await _loadHistory();
      state = state.copyWith(
        isSaving: false,
        savedSuccessfully: true,
        clearParseResult: true,
      );
    } else {
      state = state.copyWith(
        isSaving: false,
        saveError: 'Failed to save. Please try again.',
      );
    }
  }

  /// Reset for a new recording attempt.
  void retry() {
    state = state.copyWith(
      clearParseResult: true,
      savedSuccessfully: false,
      saveError: null,
    );
  }

  /// Export records to CSV.
  Future<String> exportCsv() async {
    return await _repository.exportToCsv();
  }

  /// Load history from storage.
  Future<void> _loadHistory() async {
    final records = await _repository.getAllRecords();
    state = state.copyWith(history: records);
  }

  /// Refresh history from storage.
  Future<void> refreshHistory() async {
    await _loadHistory();
  }
}

/// Repository provider.
final vitalsRepositoryProvider = Provider<VitalsRepository>((ref) {
  return VitalsRepositoryImpl();
});

/// Vitals state provider.
final vitalsProvider =
    StateNotifierProvider<VitalsNotifier, VitalsState>((ref) {
  final repository = ref.watch(vitalsRepositoryProvider);
  return VitalsNotifier(repository: repository);
});
