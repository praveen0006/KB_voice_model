import 'package:flutter_test/flutter_test.dart';
import 'package:voice_vitals/data/parsers/vitals_parser.dart';

/// Tests that simulate real Chrome Web Speech API output.
void main() {
  const parser = VitalsParser();

  // Simulate what Chrome actually returns for different speech patterns
  final realWorldInputs = [
    'BP 120 over 80',
    'blood pressure is 120 over 80',
    '120 by 80 BP',
    '120 on 80',
    'heart rate 78',
    'heart rate is 72',
    'pulse 65',
    'SP auto 98',
    'oxygen 97',
    'oxygen saturation 98',
    'spo2 98',
    'respiration 18',
    'respiration rate 16',
    'temperature 98.6',
    '120 by 80 BP respiration 73 heart rate 66 SP auto 73',
    'BP 120 over 80 heart rate 72 oxygen 98 respiration 18',
    'bp is 120 over 80 heart rate is 78 oxygen is 98 respiration is 18',
    'blood pressure 130 over 85 pulse 72 saturation 97 respiration 16',
  ];

  for (final input in realWorldInputs) {
    test('Real-world: "$input"', () {
      final result = parser.parse(input);
      print('INPUT:  "$input"');
      print('RESULT: BP=${result.systolic}/${result.diastolic} HR=${result.heartRate} Temp=${result.temperature} SpO2=${result.spo2} RR=${result.respirationRate}');
      print('---');
      // Just verify it doesn't crash — we'll read the output
      expect(result, isNotNull);
    });
  }
}
