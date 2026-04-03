import '../entities/vital_record.dart';
import '../../data/parsers/vitals_parser.dart';
import '../../data/validators/vitals_validator.dart';

/// Result of the parse + validate pipeline.
class ParseVitalsResult {
  final ParsedVitals parsed;
  final ValidationResult validation;

  const ParseVitalsResult({
    required this.parsed,
    required this.validation,
  });

  bool get isValid => validation.isValid && parsed.hasAnyData;
  bool get hasData => parsed.hasAnyData;

  /// Convert to a VitalRecord if valid.
  VitalRecord? toRecord() {
    if (!parsed.hasAnyData) return null;
    return VitalRecord(
      timestamp: DateTime.now(),
      bloodPressure: parsed.hasBloodPressure
          ? BloodPressure(
              systolic: parsed.systolic!,
              diastolic: parsed.diastolic!,
            )
          : null,
      heartRate: parsed.heartRate,
      temperature: parsed.temperature,
      spo2: parsed.spo2,
      respirationRate: parsed.respirationRate,
    );
  }
}

/// Use case: Parse a speech transcript into validated vitals.
class ParseVitalsUseCase {
  final VitalsParser _parser;
  final VitalsValidator _validator;

  const ParseVitalsUseCase({
    VitalsParser parser = const VitalsParser(),
    VitalsValidator validator = const VitalsValidator(),
  })  : _parser = parser,
        _validator = validator;

  /// Execute the parse + validate pipeline.
  ParseVitalsResult execute(String transcript) {
    final parsed = _parser.parse(transcript);
    final validation = _validator.validate(
      systolic: parsed.systolic,
      diastolic: parsed.diastolic,
      heartRate: parsed.heartRate,
      temperature: parsed.temperature,
      spo2: parsed.spo2,
      respirationRate: parsed.respirationRate,
    );
    return ParseVitalsResult(parsed: parsed, validation: validation);
  }
}
