import 'package:flutter_test/flutter_test.dart';
import 'package:voice_vitals/core/number_normalizer.dart';

void main() {
  group('NumberNormalizer.normalizeInText', () {
    // Simple single words
    test('converts single digit words', () {
      expect(NumberNormalizer.normalizeInText('five'), '5');
    });

    test('converts teens', () {
      expect(NumberNormalizer.normalizeInText('thirteen'), '13');
    });

    test('converts tens', () {
      expect(NumberNormalizer.normalizeInText('sixty'), '60');
    });

    // Compound numbers
    test('converts compound: seventy eight → 78', () {
      expect(NumberNormalizer.normalizeInText('seventy eight'), '78');
    });

    test('converts compound: forty two → 42', () {
      expect(NumberNormalizer.normalizeInText('forty two'), '42');
    });

    // Shorthand hundreds
    test('converts shorthand: one twenty → 120', () {
      expect(NumberNormalizer.normalizeInText('one twenty'), '120');
    });

    test('converts shorthand: one forty → 140', () {
      expect(NumberNormalizer.normalizeInText('one forty'), '140');
    });

    // Full hundreds
    test('converts: one hundred twenty → 120', () {
      expect(NumberNormalizer.normalizeInText('one hundred twenty'), '120');
    });

    test('converts: one hundred and twenty → 120', () {
      expect(
          NumberNormalizer.normalizeInText('one hundred and twenty'), '120');
    });

    // Decimals
    test('converts: ninety eight point six → 98.6', () {
      expect(NumberNormalizer.normalizeInText('ninety eight point six'),
          '98.6');
    });

    // In context
    test('preserves non-number words', () {
      expect(
        NumberNormalizer.normalizeInText('heart rate seventy eight'),
        'heart rate 78',
      );
    });

    test('handles multiple number sequences', () {
      expect(
        NumberNormalizer.normalizeInText(
            'one twenty over eighty'),
        '120 over 80',
      );
    });

    test('handles BP with word numbers in context', () {
      expect(
        NumberNormalizer.normalizeInText(
            'bp one twenty over eighty heart rate seventy eight'),
        'bp 120 over 80 heart rate 78',
      );
    });

    // Edge cases
    test('handles already-digit text', () {
      expect(NumberNormalizer.normalizeInText('120 over 80'), '120 over 80');
    });

    test('handles empty string', () {
      expect(NumberNormalizer.normalizeInText(''), '');
    });

    test('handles mixed words and digits', () {
      expect(
        NumberNormalizer.normalizeInText('bp 120 over eighty'),
        'bp 120 over 80',
      );
    });
  });
}
