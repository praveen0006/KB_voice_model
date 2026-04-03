import 'package:flutter_test/flutter_test.dart';
import 'package:voice_vitals/data/parsers/vitals_parser.dart';

void main() {
  const parser = VitalsParser();

  test('Chrome: "Espio 76 respiration 33Hard red 96 BP 120 by 70."', () {
    final result = parser.parse('Espio 76 respiration 33Hard red 96 BP 120 by 70.');
    print('Test 1: BP=${result.systolic}/${result.diastolic} HR=${result.heartRate} SpO2=${result.spo2} RR=${result.respirationRate}');
    expect(result.systolic, 120);
    expect(result.diastolic, 70);
    expect(result.heartRate, 96);
    expect(result.spo2, 76);
    expect(result.respirationRate, 33);
  });

  test('Chrome: "Heart rate 97 spo2 76Baby 97 by 83Desperation 36"', () {
    final result = parser.parse('Heart rate 97 spo2 76Baby 97 by 83Desperation 36');
    print('Test 2: BP=${result.systolic}/${result.diastolic} HR=${result.heartRate} SpO2=${result.spo2} RR=${result.respirationRate}');
    expect(result.heartRate, 97);
    expect(result.spo2, 76);
    expect(result.respirationRate, 36, reason: 'Desperation → respiration 36');
    expect(result.systolic, 97);
    expect(result.diastolic, 83);
  });

  test('Chrome: "baby 127 by 36 spo2 93 respiration 31 heart rate 73"', () {
    final result = parser.parse('baby 127 by 36 spo2 93 respiration 31 heart rate 73');
    print('Test 3: BP=${result.systolic}/${result.diastolic} HR=${result.heartRate} SpO2=${result.spo2} RR=${result.respirationRate}');
    expect(result.systolic, 127);
    expect(result.diastolic, 36);
    expect(result.heartRate, 73);
    expect(result.spo2, 93);
    expect(result.respirationRate, 31);
  });
}
