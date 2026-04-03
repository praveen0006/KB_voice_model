import 'package:flutter_test/flutter_test.dart';
import 'package:voice_vitals/data/parsers/vitals_parser.dart';

void main() {
  const parser = VitalsParser();

  test('New Chrome exact test: "BP 120 over 73 by 33 spot 96 hard drive 79 respiration 32"', () {
    final transcript = 'BP 120 over 73 by 33 spot 96 hard drive 79 respiration 32';
    
    print('INPUT:  "$transcript"');
    final result = parser.parse(transcript);
    print('');
    print('RESULTS:');
    print('  BP:   ${result.systolic}/${result.diastolic}');
    print('  HR:   ${result.heartRate}');
    print('  Temp: ${result.temperature}');
    print('  SpO2: ${result.spo2}');
    print('  RR:   ${result.respirationRate}');
    
    expect(result.systolic, 120);
    expect(result.diastolic, 73);
    // Note: "by 33" could be misrecognized, currently we don't map "by" to anything unless it's in a BP context "XX by YY"
    // "spot 96" should be SpO2 96
    expect(result.spo2, 96);
  });

  test('New Chrome exact test: "BP 13 by 87 hard drive 93 spot 96 respiration 27"', () {
    final transcript = 'BP 13 by 87 hard drive 93 spot 96 respiration 27';
    
    print('INPUT:  "$transcript"');
    final result = parser.parse(transcript);
    print('');
    print('RESULTS:');
    print('  BP:   ${result.systolic}/${result.diastolic}');
    print('  HR:   ${result.heartRate}');
    print('  Temp: ${result.temperature}');
    print('  SpO2: ${result.spo2}');
    print('  RR:   ${result.respirationRate}');
    
    expect(result.systolic, 130);
    expect(result.diastolic, 87);
    expect(result.spo2, 96);
    expect(result.heartRate, 93);
    expect(result.respirationRate, 27);
  });
}
