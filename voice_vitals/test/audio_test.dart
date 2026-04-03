import 'package:flutter_test/flutter_test.dart';
import 'package:voice_vitals/data/parsers/vitals_parser.dart';

void main() {
  const parser = VitalsParser();

  test('Exact audio transcription test', () {
    final transcript = 'baby 127 by 36 spo2 93 respiration 31 heart rate 73 BPM 76 heart rate 96 spo2 99 respiration 33';
    
    print('INPUT: "$transcript"');
    final result = parser.parse(transcript);
    print('');
    print('RESULTS:');
    print('  BP:   ${result.systolic}/${result.diastolic}');
    print('  HR:   ${result.heartRate}');
    print('  Temp: ${result.temperature}');
    print('  SpO2: ${result.spo2}');
    print('  RR:   ${result.respirationRate}');
    print('  hasAnyData: ${result.hasAnyData}');
    
    expect(result.hasAnyData, true);
  });
}
