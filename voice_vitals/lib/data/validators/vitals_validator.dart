import '../../core/vital_ranges.dart';
import '../../core/logger.dart';

/// Represents a single field validation result.
class FieldValidation {
  final String fieldName;
  final bool isValid;
  final String? errorMessage;

  const FieldValidation({
    required this.fieldName,
    required this.isValid,
    this.errorMessage,
  });
}

/// Overall validation result for parsed vitals.
class ValidationResult {
  final List<FieldValidation> fieldResults;

  const ValidationResult({required this.fieldResults});

  bool get isValid => fieldResults.every((f) => f.isValid);

  List<FieldValidation> get errors =>
      fieldResults.where((f) => !f.isValid).toList();

  List<String> get errorMessages =>
      errors.map((e) => '${e.fieldName}: ${e.errorMessage}').toList();
}

/// Validates parsed vitals against clinically reasonable ranges.
class VitalsValidator {
  const VitalsValidator();

  /// Validate all extracted vitals.
  ValidationResult validate({
    int? systolic,
    int? diastolic,
    int? heartRate,
    double? temperature,
    int? spo2,
    int? respirationRate,
  }) {
    final results = <FieldValidation>[];

    if (systolic != null) {
      results.add(_validateInt(
        'Systolic BP', systolic,
        VitalRanges.systolicMin, VitalRanges.systolicMax,
      ));
    }

    if (diastolic != null) {
      results.add(_validateInt(
        'Diastolic BP', diastolic,
        VitalRanges.diastolicMin, VitalRanges.diastolicMax,
      ));
    }

    if (heartRate != null) {
      results.add(_validateInt(
        'Heart Rate', heartRate,
        VitalRanges.heartRateMin, VitalRanges.heartRateMax,
      ));
    }

    if (temperature != null) {
      if (temperature < VitalRanges.temperatureMin ||
          temperature > VitalRanges.temperatureMax) {
        VitalsLogger.logValidationError(
          'Temperature', temperature,
          'Out of range (${VitalRanges.temperatureMin}-${VitalRanges.temperatureMax})',
        );
        results.add(FieldValidation(
          fieldName: 'Temperature',
          isValid: false,
          errorMessage:
              'Value $temperature is out of range (${VitalRanges.temperatureMin}–${VitalRanges.temperatureMax}°F)',
        ));
      } else {
        results.add(const FieldValidation(
          fieldName: 'Temperature', isValid: true,
        ));
      }
    }

    if (spo2 != null) {
      results.add(_validateInt(
        'SpO2', spo2,
        VitalRanges.spo2Min, VitalRanges.spo2Max,
      ));
    }

    if (respirationRate != null) {
      results.add(_validateInt(
        'Respiration Rate', respirationRate,
        VitalRanges.respirationRateMin, VitalRanges.respirationRateMax,
      ));
    }

    return ValidationResult(fieldResults: results);
  }

  FieldValidation _validateInt(String name, int value, int min, int max) {
    if (value < min || value > max) {
      VitalsLogger.logValidationError(name, value, 'Out of range ($min-$max)');
      return FieldValidation(
        fieldName: name,
        isValid: false,
        errorMessage: 'Value $value is out of range ($min–$max)',
      );
    }
    return FieldValidation(fieldName: name, isValid: true);
  }
}
