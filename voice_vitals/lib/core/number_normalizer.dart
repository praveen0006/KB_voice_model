/// Converts spoken word-numbers into numeric values.
///
/// Handles patterns like:
/// - "seventy eight" → 78
/// - "one twenty" → 120
/// - "ninety eight point six" → 98.6
/// - "one hundred and twenty" → 120
class NumberNormalizer {
  NumberNormalizer._();

  static final Map<String, int> _wordToNum = {
    'zero': 0,
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'ten': 10,
    'eleven': 11,
    'twelve': 12,
    'thirteen': 13,
    'fourteen': 14,
    'fifteen': 15,
    'sixteen': 16,
    'seventeen': 17,
    'eighteen': 18,
    'nineteen': 19,
    'twenty': 20,
    'thirty': 30,
    'forty': 40,
    'fifty': 50,
    'sixty': 60,
    'seventy': 70,
    'eighty': 80,
    'ninety': 90,
    'hundred': 100,
    'thousand': 1000,
  };

  /// Normalize all word-numbers in a string to digit form.
  ///
  /// Example: "heart rate seventy eight" → "heart rate 78"
  /// Example: "one twenty over eighty" → "120 over 80"
  /// Example: "ninety eight point six" → "98.6"
  static String normalizeInText(String text) {
    String normalized = text.toLowerCase().trim();

    // Replace "and" between number words (e.g., "one hundred and twenty")
    normalized = normalized.replaceAll(' and ', ' ');

    // Tokenize
    final words = normalized.split(RegExp(r'\s+'));
    final result = <String>[];
    int i = 0;

    while (i < words.length) {
      // Check if current word starts a number sequence
      if (_isNumberWord(words[i])) {
        // Collect consecutive number words
        final numberWords = <String>[];
        while (i < words.length && _isNumberWord(words[i])) {
          numberWords.add(words[i]);

          // Check for "point" followed by decimal digits
          if (words[i] == 'point') {
            i++;
            // Collect decimal part
            while (i < words.length && _isNumberWord(words[i]) && words[i] != 'point') {
              numberWords.add(words[i]);
              i++;
            }
            break;
          }
          i++;
        }

        final number = _wordsToNumber(numberWords);
        if (number != null) {
          // Format: remove trailing .0 for whole numbers
          if (number == number.truncateToDouble()) {
            result.add(number.toInt().toString());
          } else {
            result.add(number.toString());
          }
        } else {
          // Couldn't parse, keep original words
          result.addAll(numberWords);
        }
      } else {
        result.add(words[i]);
        i++;
      }
    }

    return result.join(' ');
  }

  /// Check if a word is part of a number expression.
  static bool _isNumberWord(String word) {
    return _wordToNum.containsKey(word) || word == 'point';
  }

  /// Convert a sequence of number words to a numeric value.
  ///
  /// Supports patterns:
  /// - Simple: ["seventy", "eight"] → 78
  /// - Hundreds: ["one", "hundred", "twenty"] → 120
  /// - Shorthand: ["one", "twenty"] → 120 (when first word is 1-9 and second is tens)
  /// - Decimal: ["ninety", "eight", "point", "six"] → 98.6
  static double? _wordsToNumber(List<String> words) {
    if (words.isEmpty) return null;

    // Split on "point" for decimal handling
    final pointIndex = words.indexOf('point');
    List<String> integerPart;
    List<String> decimalPart = [];

    if (pointIndex >= 0) {
      integerPart = words.sublist(0, pointIndex);
      decimalPart = words.sublist(pointIndex + 1);
    } else {
      integerPart = words;
    }

    // Parse integer part
    final intValue = _parseIntegerPart(integerPart);
    if (intValue == null) return null;

    // Parse decimal part
    if (decimalPart.isNotEmpty) {
      final decValue = _parseDecimalPart(decimalPart);
      if (decValue != null) {
        return intValue + decValue;
      }
    }

    return intValue.toDouble();
  }

  /// Parse the integer portion of a word-number sequence.
  static double? _parseIntegerPart(List<String> words) {
    if (words.isEmpty) return 0;

    int total = 0;
    int current = 0;
    bool hasHundred = false;

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final value = _wordToNum[word];
      if (value == null) return null;

      if (value == 100) {
        // "hundred" multiplier
        hasHundred = true;
        if (current == 0) current = 1;
        current *= 100;
      } else if (value == 1000) {
        if (current == 0) current = 1;
        current *= 1000;
        total += current;
        current = 0;
      } else if (value >= 20 && value <= 90 && current >= 1 && current <= 9 && !hasHundred) {
        // Shorthand: "one twenty" → 120 (1 × 100 + 20)
        current = current * 100 + value;
      } else {
        current += value;
      }
    }

    total += current;
    return total.toDouble();
  }

  /// Parse decimal digits from word-numbers.
  ///
  /// E.g., ["six"] → 0.6, ["six", "five"] → 0.65
  static double? _parseDecimalPart(List<String> words) {
    if (words.isEmpty) return null;

    String decimalStr = '0.';
    for (final word in words) {
      final value = _wordToNum[word];
      if (value == null || value >= 10) return null; // Only single digits after point
      decimalStr += value.toString();
    }

    return double.tryParse(decimalStr);
  }

  /// Try to parse a single token as a number (digit string or word).
  static double? tryParseToken(String token) {
    // Try digit parse first
    final digitParse = double.tryParse(token);
    if (digitParse != null) return digitParse;

    // Try word parse
    final wordValue = _wordToNum[token.toLowerCase()];
    if (wordValue != null) return wordValue.toDouble();

    return null;
  }
}
