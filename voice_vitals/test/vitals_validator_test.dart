import 'package:flutter_test/flutter_test.dart';
import 'package:voice_vitals/data/validators/vitals_validator.dart';

void main() {
  const validator = VitalsValidator();

  group('Systolic validation', () {
    test('valid systolic passes', () {
      final result = validator.validate(systolic: 120);
      expect(result.isValid, true);
    });

    test('systolic too low fails', () {
      final result = validator.validate(systolic: 50);
      expect(result.isValid, false);
      expect(result.errors.first.fieldName, 'Systolic BP');
    });

    test('systolic too high fails', () {
      final result = validator.validate(systolic: 250);
      expect(result.isValid, false);
    });

    test('systolic at min boundary passes', () {
      final result = validator.validate(systolic: 80);
      expect(result.isValid, true);
    });

    test('systolic at max boundary passes', () {
      final result = validator.validate(systolic: 200);
      expect(result.isValid, true);
    });
  });

  group('Diastolic validation', () {
    test('valid diastolic passes', () {
      final result = validator.validate(diastolic: 80);
      expect(result.isValid, true);
    });

    test('diastolic too low fails', () {
      final result = validator.validate(diastolic: 30);
      expect(result.isValid, false);
    });

    test('diastolic too high fails', () {
      final result = validator.validate(diastolic: 150);
      expect(result.isValid, false);
    });
  });

  group('Heart Rate validation', () {
    test('valid heart rate passes', () {
      final result = validator.validate(heartRate: 78);
      expect(result.isValid, true);
    });

    test('heart rate too low fails', () {
      final result = validator.validate(heartRate: 20);
      expect(result.isValid, false);
    });

    test('heart rate too high fails', () {
      final result = validator.validate(heartRate: 200);
      expect(result.isValid, false);
    });

    test('heart rate at min boundary passes', () {
      final result = validator.validate(heartRate: 40);
      expect(result.isValid, true);
    });

    test('heart rate at max boundary passes', () {
      final result = validator.validate(heartRate: 180);
      expect(result.isValid, true);
    });
  });

  group('Temperature validation', () {
    test('valid temperature passes', () {
      final result = validator.validate(temperature: 98.6);
      expect(result.isValid, true);
    });

    test('temperature too low fails', () {
      final result = validator.validate(temperature: 90.0);
      expect(result.isValid, false);
    });

    test('temperature too high fails', () {
      final result = validator.validate(temperature: 110.0);
      expect(result.isValid, false);
    });

    test('temperature at min boundary passes', () {
      final result = validator.validate(temperature: 95.0);
      expect(result.isValid, true);
    });

    test('temperature at max boundary passes', () {
      final result = validator.validate(temperature: 105.0);
      expect(result.isValid, true);
    });
  });

  group('SpO2 validation', () {
    test('valid spo2 passes', () {
      final result = validator.validate(spo2: 98);
      expect(result.isValid, true);
    });

    test('spo2 too low fails', () {
      final result = validator.validate(spo2: 50);
      expect(result.isValid, false);
      expect(result.errors.first.fieldName, 'SpO2');
    });

    test('spo2 too high fails', () {
      final result = validator.validate(spo2: 110);
      expect(result.isValid, false);
    });

    test('spo2 at min boundary passes', () {
      final result = validator.validate(spo2: 70);
      expect(result.isValid, true);
    });

    test('spo2 at max boundary (100) passes', () {
      final result = validator.validate(spo2: 100);
      expect(result.isValid, true);
    });
  });

  group('Respiration Rate validation', () {
    test('valid respiration rate passes', () {
      final result = validator.validate(respirationRate: 18);
      expect(result.isValid, true);
    });

    test('respiration rate too low fails', () {
      final result = validator.validate(respirationRate: 5);
      expect(result.isValid, false);
      expect(result.errors.first.fieldName, 'Respiration Rate');
    });

    test('respiration rate too high fails', () {
      final result = validator.validate(respirationRate: 50);
      expect(result.isValid, false);
    });

    test('respiration rate at min boundary passes', () {
      final result = validator.validate(respirationRate: 8);
      expect(result.isValid, true);
    });

    test('respiration rate at max boundary passes', () {
      final result = validator.validate(respirationRate: 40);
      expect(result.isValid, true);
    });
  });

  group('Combined validation', () {
    test('all valid values pass', () {
      final result = validator.validate(
        systolic: 120,
        diastolic: 80,
        heartRate: 78,
        temperature: 98.6,
        spo2: 98,
        respirationRate: 18,
      );
      expect(result.isValid, true);
      expect(result.errors, isEmpty);
    });

    test('one invalid fails overall', () {
      final result = validator.validate(
        systolic: 300,
        diastolic: 80,
        heartRate: 78,
      );
      expect(result.isValid, false);
      expect(result.errors.length, 1);
    });

    test('null values are not validated', () {
      final result = validator.validate(); // all null
      expect(result.isValid, true);
    });

    test('multiple invalid fields caught', () {
      final result = validator.validate(
        systolic: 300,
        diastolic: 10,
        spo2: 50,
        respirationRate: 5,
      );
      expect(result.isValid, false);
      expect(result.errors.length, 4);
    });
  });
}
