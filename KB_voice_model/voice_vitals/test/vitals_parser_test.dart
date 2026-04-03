import 'package:flutter_test/flutter_test.dart';
import 'package:voice_vitals/data/parsers/vitals_parser.dart';

void main() {
  const parser = VitalsParser();

  group('Blood Pressure parsing', () {
    test('parses slash format: 120/80', () {
      final result = parser.parse('BP 120/80');
      expect(result.systolic, 120);
      expect(result.diastolic, 80);
    });

    test('parses "over" format: 120 over 80', () {
      final result = parser.parse('120 over 80');
      expect(result.systolic, 120);
      expect(result.diastolic, 80);
    });

    test('parses with BP prefix: bp 120 over 80', () {
      final result = parser.parse('bp 120 over 80');
      expect(result.systolic, 120);
      expect(result.diastolic, 80);
    });

    test('parses "blood pressure" prefix', () {
      final result = parser.parse('blood pressure 130 over 85');
      expect(result.systolic, 130);
      expect(result.diastolic, 85);
    });

    test('parses "by" format: 120 by 80', () {
      final result = parser.parse('bp 120 by 80');
      expect(result.systolic, 120);
      expect(result.diastolic, 80);
    });

    test('parses "on" format: 120 on 80', () {
      final result = parser.parse('120 on 80');
      expect(result.systolic, 120);
      expect(result.diastolic, 80);
    });

    test('parses with "is": BP is 120 over 80', () {
      final result = parser.parse('bp is 120 over 80');
      expect(result.systolic, 120);
      expect(result.diastolic, 80);
    });

    test('parses concatenated "12080" as 120/80', () {
      final result = parser.parse('bp 12080');
      expect(result.systolic, 120);
      expect(result.diastolic, 80);
    });

    test('parses concatenated "13085" as 130/85', () {
      final result = parser.parse('blood pressure 13085');
      expect(result.systolic, 130);
      expect(result.diastolic, 85);
    });

    test('parses concatenated "9060" as 90/60', () {
      final result = parser.parse('bp 9060');
      expect(result.systolic, 90);
      expect(result.diastolic, 60);
    });

    test('parses "bp X Y" two separate numbers', () {
      final result = parser.parse('bp 140 90');
      expect(result.systolic, 140);
      expect(result.diastolic, 90);
    });

    test('handles "be pee" speech artifact', () {
      final result = parser.parse('be pee 120 over 80');
      expect(result.systolic, 120);
      expect(result.diastolic, 80);
    });

    test('handles "blood presser" speech artifact', () {
      final result = parser.parse('blood presser 130 over 85');
      expect(result.systolic, 130);
      expect(result.diastolic, 85);
    });
  });

  group('Heart Rate parsing', () {
    test('parses "heart rate 78"', () {
      final result = parser.parse('heart rate 78');
      expect(result.heartRate, 78);
    });

    test('parses "HR 78"', () {
      final result = parser.parse('HR 78');
      expect(result.heartRate, 78);
    });

    test('parses "pulse 65"', () {
      final result = parser.parse('pulse 65');
      expect(result.heartRate, 65);
    });

    test('parses "heartrate 72" (no space)', () {
      final result = parser.parse('heartrate 72');
      expect(result.heartRate, 72);
    });

    test('parses with "is": heart rate is 78', () {
      final result = parser.parse('heart rate is 78');
      expect(result.heartRate, 78);
    });

    test('parses reverse: "78 bpm"', () {
      final result = parser.parse('78 bpm');
      expect(result.heartRate, 78);
    });

    test('parses "beats per minute 72"', () {
      final result = parser.parse('beats per minute 72');
      expect(result.heartRate, 72);
    });

    test('parses "heart rate hundred" as 100', () {
      final result = parser.parse('heart rate hundred');
      expect(result.heartRate, 100);
    });

    test('parses "hr hundred" as 100', () {
      final result = parser.parse('hr hundred');
      expect(result.heartRate, 100);
    });

    test('handles "hard rate" speech artifact', () {
      final result = parser.parse('hard rate 72');
      expect(result.heartRate, 72);
    });

    test('handles "@,hard ret" speech artifact', () {
      final result = parser.parse('@,hard ret 72');
      expect(result.heartRate, 72);
    });
  });

  group('Temperature parsing', () {
    test('parses "temperature 98.6"', () {
      final result = parser.parse('temperature 98.6');
      expect(result.temperature, 98.6);
    });

    test('parses "temp 99.1"', () {
      final result = parser.parse('temp 99.1');
      expect(result.temperature, 99.1);
    });

    test('parses integer temperature', () {
      final result = parser.parse('temp 100');
      expect(result.temperature, 100.0);
    });

    test('parses with "is": temperature is 98.6', () {
      final result = parser.parse('temperature is 98.6');
      expect(result.temperature, 98.6);
    });

    test('parses reverse: "98.6 degrees"', () {
      final result = parser.parse('98.6 degrees');
      expect(result.temperature, 98.6);
    });

    test('parses "99 fahrenheit"', () {
      final result = parser.parse('99 fahrenheit');
      expect(result.temperature, 99.0);
    });
  });

  group('SpO2 parsing', () {
    test('parses "spo2 98"', () {
      final result = parser.parse('spo2 98');
      expect(result.spo2, 98);
    });

    test('parses "oxygen saturation 97"', () {
      final result = parser.parse('oxygen saturation 97');
      expect(result.spo2, 97);
    });

    test('parses "oxygen 95"', () {
      final result = parser.parse('oxygen 95');
      expect(result.spo2, 95);
    });

    test('parses "o2 sat 99"', () {
      final result = parser.parse('o2 sat 99');
      expect(result.spo2, 99);
    });

    test('parses "saturation 96"', () {
      final result = parser.parse('saturation 96');
      expect(result.spo2, 96);
    });

    test('handles speech artifact "spo 2 98"', () {
      final result = parser.parse('spo 2 98');
      expect(result.spo2, 98);
    });

    test('handles speech artifact "sp o 2 97"', () {
      final result = parser.parse('sp o 2 97');
      expect(result.spo2, 97);
    });

    test('handles Chrome "SP auto 98" artifact', () {
      final result = parser.parse('SP auto 98');
      expect(result.spo2, 98);
    });

    test('handles "spot2 98" artifact', () {
      final result = parser.parse('spot2 98');
      expect(result.spo2, 98);
    });

    test('handles "sp road 97" artifact', () {
      final result = parser.parse('sp road 97');
      expect(result.spo2, 97);
    });

    test('handles "hp board 96" artifact', () {
      final result = parser.parse('hp board 96');
      expect(result.spo2, 96);
    });

    test('handles "hp auto 98" artifact', () {
      final result = parser.parse('hp auto 98');
      expect(result.spo2, 98);
    });

    test('parses with "is": oxygen is 97', () {
      final result = parser.parse('oxygen is 97');
      expect(result.spo2, 97);
    });

    test('parses "98 percent"', () {
      final result = parser.parse('98 percent');
      expect(result.spo2, 98);
    });

    test('parses "spo2 is 99"', () {
      final result = parser.parse('spo2 is 99');
      expect(result.spo2, 99);
    });
  });

  group('Respiration Rate parsing', () {
    test('parses "respiration 18"', () {
      final result = parser.parse('respiration 18');
      expect(result.respirationRate, 18);
    });

    test('parses "respiration rate 16"', () {
      final result = parser.parse('respiration rate 16');
      expect(result.respirationRate, 16);
    });

    test('parses "respiratory rate 20"', () {
      final result = parser.parse('respiratory rate 20');
      expect(result.respirationRate, 20);
    });

    test('parses "rr 14"', () {
      final result = parser.parse('rr 14');
      expect(result.respirationRate, 14);
    });

    test('parses "breathing rate 22"', () {
      final result = parser.parse('breathing rate 22');
      expect(result.respirationRate, 22);
    });

    test('parses "breaths per minute 18"', () {
      final result = parser.parse('breaths per minute 18');
      expect(result.respirationRate, 18);
    });

    test('parses with "is": respiration is 18', () {
      final result = parser.parse('respiration is 18');
      expect(result.respirationRate, 18);
    });

    test('parses "resp 16"', () {
      final result = parser.parse('resp 16');
      expect(result.respirationRate, 16);
    });
  });

  group('Multiple vitals in one sentence', () {
    test('parses BP + HR', () {
      final result = parser.parse('bp 120 over 80 heart rate 78');
      expect(result.systolic, 120);
      expect(result.diastolic, 80);
      expect(result.heartRate, 78);
    });

    test('parses all 5 vitals', () {
      final result = parser.parse(
          'blood pressure 130/85 heart rate 72 temperature 98.6 spo2 98 respiration 18');
      expect(result.systolic, 130);
      expect(result.diastolic, 85);
      expect(result.heartRate, 72);
      expect(result.temperature, 98.6);
      expect(result.spo2, 98);
      expect(result.respirationRate, 18);
    });

    test('parses comma-separated', () {
      final result =
          parser.parse('BP 120/80, heart rate 78, spo2 97, respiration 16');
      expect(result.hasBloodPressure, true);
      expect(result.hasHeartRate, true);
      expect(result.hasSpo2, true);
      expect(result.hasRespirationRate, true);
    });

    test('parses with "is" connectors', () {
      final result =
          parser.parse('bp is 120 over 80, heart rate is 72, oxygen is 98, respiration is 16');
      expect(result.systolic, 120);
      expect(result.diastolic, 80);
      expect(result.heartRate, 72);
      expect(result.spo2, 98);
      expect(result.respirationRate, 16);
    });

    test('parses Chrome-like speech output', () {
      final result =
          parser.parse('120 by 80 BP respiration 18 heart rate 72 SP auto 98');
      expect(result.systolic, 120);
      expect(result.diastolic, 80);
      expect(result.heartRate, 72);
      expect(result.spo2, 98);
      expect(result.respirationRate, 18);
    });

    test('parses exact HP auto transcript with all vitals', () {
      final result =
          parser.parse('heart rate 91 HP auto 96 bp 120 over 82 respiration 23');
      expect(result.systolic, 120);
      expect(result.diastolic, 82);
      expect(result.heartRate, 91);
      expect(result.spo2, 96);
      expect(result.respirationRate, 23);
    });

    test('parses BP when transcript says "over it"', () {
      final result =
          parser.parse('BP 120 over it 78 SP auto 98 respiration 18');
      expect(result.systolic, 120);
      expect(result.diastolic, 78);
      expect(result.spo2, 98);
      expect(result.respirationRate, 18);
    });

    test('parses BP when transcript says "hour" instead of "over"', () {
      final result =
          parser.parse('baby 120 hour 78 heart rate 76 SP auto 93 respiration 26');
      expect(result.systolic, 120);
      expect(result.diastolic, 78);
      expect(result.heartRate, 76);
      expect(result.spo2, 93);
      expect(result.respirationRate, 26);
    });
  });

  group('Partial inputs', () {
    test('only heart rate', () {
      final result = parser.parse('heart rate 72');
      expect(result.hasBloodPressure, false);
      expect(result.hasHeartRate, true);
      expect(result.hasTemperature, false);
      expect(result.hasSpo2, false);
      expect(result.hasRespirationRate, false);
    });

    test('only SpO2', () {
      final result = parser.parse('spo2 98');
      expect(result.hasSpo2, true);
      expect(result.hasBloodPressure, false);
    });

    test('only respiration', () {
      final result = parser.parse('respiration 18');
      expect(result.hasRespirationRate, true);
      expect(result.hasHeartRate, false);
    });
  });

  group('Edge cases', () {
    test('no vitals found returns hasAnyData=false', () {
      final result = parser.parse('hello world');
      expect(result.hasAnyData, false);
    });

    test('empty string', () {
      final result = parser.parse('');
      expect(result.hasAnyData, false);
    });

    test('noisy text with BP buried', () {
      final result = parser.parse(
          'the patient has 120 over 80 today');
      expect(result.hasBloodPressure, true);
    });

    test('concatenated BP without prefix', () {
      final result = parser.parse('12080');
      expect(result.systolic, 120);
      expect(result.diastolic, 80);
    });
  });
}
