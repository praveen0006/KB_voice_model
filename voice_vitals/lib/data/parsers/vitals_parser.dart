import '../../core/number_normalizer.dart';
import '../../core/logger.dart';

/// Result of parsing a speech transcript for vitals.
class ParsedVitals {
  final int? systolic;
  final int? diastolic;
  final int? heartRate;
  final double? temperature;
  final int? spo2;
  final int? respirationRate;
  final String rawTranscript;

  const ParsedVitals({
    this.systolic,
    this.diastolic,
    this.heartRate,
    this.temperature,
    this.spo2,
    this.respirationRate,
    required this.rawTranscript,
  });

  bool get hasBloodPressure => systolic != null && diastolic != null;
  bool get hasHeartRate => heartRate != null;
  bool get hasTemperature => temperature != null;
  bool get hasSpo2 => spo2 != null;
  bool get hasRespirationRate => respirationRate != null;
  bool get hasAnyData =>
      hasBloodPressure ||
      hasHeartRate ||
      hasTemperature ||
      hasSpo2 ||
      hasRespirationRate;

  Map<String, dynamic> toMap() => {
        'systolic': systolic,
        'diastolic': diastolic,
        'heart_rate': heartRate,
        'temperature': temperature,
        'spo2': spo2,
        'respiration_rate': respirationRate,
        'raw_transcript': rawTranscript,
      };
}

/// Optional connector words the speech engine may insert between keywords and numbers.
/// e.g., "heart rate IS 78", "BP reading OF 120", "temperature AT 98.6"
const _optionalConnector = r'(?:\s+(?:is|at|of|reading|equals|was|about))?\s+';

/// Parses raw speech transcripts into structured vitals data.
///
/// Supports:
/// - Blood Pressure: "120/80", "120 over 80", "BP 120 80", "12080"
/// - Heart Rate: "heart rate 78", "HR 78", "pulse 78", "beats per minute 78"
/// - Temperature: "temperature 98.6", "temp 98.6", "99 degrees"
/// - SpO2: "spo2 98", "oxygen 98", "saturation 98", "o2 98", "SP auto 98"
/// - Respiration: "respiration 18", "respiratory rate 18", "rr 18"
/// - Multiple vitals in one sentence
/// - Word-numbers via [NumberNormalizer]
class VitalsParser {
  const VitalsParser();

  /// Parse a speech transcript and extract vitals.
  ParsedVitals parse(String transcript) {
    VitalsLogger.logTranscript(transcript);

    // Step 1: Normalize word-numbers to digits
    String normalized = NumberNormalizer.normalizeInText(transcript);
    normalized = normalized.toLowerCase().trim();

    // Step 1.5: Pre-process common speech artifacts
    normalized = _preProcess(normalized);

    VitalsLogger.logInfo('Normalized transcript: $normalized');

    // Step 2: Extract each vital type
    final bp = _extractBloodPressure(normalized);
    final hr = _extractHeartRate(normalized);
    final temp = _extractTemperature(normalized);
    final spo2 = _extractSpO2(normalized);
    final rr = _extractRespirationRate(normalized);

    final result = ParsedVitals(
      systolic: bp?.$1,
      diastolic: bp?.$2,
      heartRate: hr,
      temperature: temp,
      spo2: spo2,
      respirationRate: rr,
      rawTranscript: transcript,
    );

    VitalsLogger.logParsed(result.toMap());
    return result;
  }

  /// Pre-process the transcript to fix common speech recognition artifacts.
  String _preProcess(String text) {
    String result = text;

    // Strip leading punctuation artifacts such as "@,heart rate".
    result = result.replaceAll(RegExp(r'^[^a-z0-9]+'), '');

    // ===== STRUCTURAL FIXES (do these first) =====

    // Strip trailing periods, commas from speech: "70." → "70"
    result = result.replaceAll(RegExp(r'[.,;!?]+$'), '');
    result = result.replaceAll(RegExp(r'[.,;!?]+\s'), ' ');

    // Insert space between digits and letters: "33Hard" → "33 Hard"
    // Chrome sometimes concatenates words without spaces
    result = result.replaceAllMapped(
      RegExp(r'(\d)([a-zA-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );

    // Insert space between letters and digits: "Hard33" → "Hard 33"
    result = result.replaceAllMapped(
      RegExp(r'([a-zA-Z])(\d)'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );

    // Fix "by" being used instead of "over" for BP (common speech pattern)
    result = result.replaceAllMapped(
      RegExp(r'(\d{1,3})\s+by\s+(\d{1,3})'),
      (m) => '${m.group(1)} over ${m.group(2)}',
    );

    // Fix "on" being used instead of "over": "120 on 80"
    result = result.replaceAllMapped(
      RegExp(r'(\d{1,3})\s+on\s+(\d{1,3})'),
      (m) => '${m.group(1)} over ${m.group(2)}',
    );

    // Chrome can mishear "over" as "hour" or "our" in BP phrases.
    result = result.replaceAllMapped(
      RegExp(r'(\d{2,3})\s+(?:hour|our)\s+(\d{2,3})'),
      (m) => '${m.group(1)} over ${m.group(2)}',
    );

    // Some transcripts insert a filler token between "over" and the value.
    // Example: "BP 120 over it 78" should become "BP 120 over 78".
    result = result.replaceAllMapped(
      RegExp(r'(\d{2,3})\s+over\s+(?:it|at|the)\s+(\d{2,3})'),
      (m) => '${m.group(1)} over ${m.group(2)}',
    );

    // Handle swallowed zeros / medical shorthand (e.g., "13 over 87" -> "130 over 87", "12 over 8" -> "120 over 80")
    result = result.replaceAllMapped(
      RegExp(r'\b([7-9]|1[0-9]|2[0-5])\s+over\s+([4-9]\d|1\d{2})\b'), // e.g. 13 over 87 -> 130 over 87
      (m) => '${int.parse(m.group(1)!) * 10} over ${m.group(2)}',
    );
    result = result.replaceAllMapped(
      RegExp(r'\b([7-9]|1[0-9]|2[0-5])\s+over\s+([4-9]|1[0-4])\b(?!\d)'), // e.g. 12 over 8 -> 120 over 80
      (m) => '${int.parse(m.group(1)!) * 10} over ${int.parse(m.group(2)!) * 10}',
    );

    // Chrome STT often hears "80" as "it" right after a systolic number.
    // E.g., "BP 125 it" -> "bp 125 80"
    result = result.replaceAllMapped(
      RegExp(r'(\d{2,3})\s+it\b'),
      (m) => '${m.group(1)} 80',
    );


    // ===== SpO2 speech artifacts =====
    // Chrome Web Speech API commonly returns: "SP auto", "SPO to", "spo 2", etc.
    result = result.replaceAllMapped(
      RegExp(
        r'sp\s*auto'          // "SP auto" (most common Chrome artifact)
        r'|spo\s*to'          // "SPO to"
        r'|s\s*p\s*o\s*2'     // "s p o 2"
        r'|sp\s*o\s*2'        // "sp o 2"
        r'|spo\s*2'           // "spo 2"
        r'|sp\s*02'           // "sp02"
        r'|s\.p\.o\.?\s*2'    // "s.p.o.2"
        r'|spio\s*2?'         // "spio2" / "spio"
        r'|espio\s*2?'        // "espio2"
        r'|espeo\s*2?'        // "espeo2"
        r'|h\s*p\s*auto'      // "hp auto"
        r'|s\s*p\s*auto'      // "s p auto"
        r'|spo\s*two'         // "SPO two"
        r'|sp\s*o\s*two'      // "sp o two"
        r'|as\s*po\s*2?'      // "as po2"
        r'|h\s*p\s*board'     // "hp board"
        r'|spot\s*2'          // "spot2"
        r'|spot\b'            // "spot 96"
        r'|sp\s*road'         // "sp road"
        r'|sp\s*vote'         // "sp vote"
        ,
        caseSensitive: false,
      ),
      (m) => 'spo2 ',
    );

    // Fix speech recognizing "o2" as separate letters
    result = result.replaceAllMapped(
      RegExp(r'(?<!\w)o\s+2(?!\d)'),
      (m) => 'o2 ',
    );

    // ===== BP keyword artifacts =====
    // Chrome commonly returns: "baby" for "BP", "be pee" for "BP"
    result = result.replaceAll(RegExp(r'\bbaby\b', caseSensitive: false), 'bp');
    result = result.replaceAll(RegExp(r'be\s+pee', caseSensitive: false), 'bp');
    result = result.replaceAll(RegExp(r'\bbpi\b', caseSensitive: false), 'bp');
    result = result.replaceAll(RegExp(r'\bbpe\b', caseSensitive: false), 'bp');
    result = result.replaceAll(RegExp(r'\bbeepee\b', caseSensitive: false), 'bp');
    result = result.replaceAll(RegExp(r'blood\s+presser', caseSensitive: false), 'blood pressure');
    result = result.replaceAll(RegExp(r'blood\s+precious', caseSensitive: false), 'blood pressure');
    result = result.replaceAll(RegExp(r'blood\s+fresher', caseSensitive: false), 'blood pressure');

    // ===== HR keyword artifacts =====
    // Chrome returns: "Hard red", "hard ret", "hard rate", "hot rate", "hard drive" for "heart rate"
    result = result.replaceAll(RegExp(r'hard\s+red', caseSensitive: false), 'heart rate');
    result = result.replaceAll(RegExp(r'hard\s+ret', caseSensitive: false), 'heart rate');
    result = result.replaceAll(RegExp(r'hard\s+rate', caseSensitive: false), 'heart rate');
    result = result.replaceAll(RegExp(r'hot\s+rate', caseSensitive: false), 'heart rate');
    result = result.replaceAll(RegExp(r'hot\s+red', caseSensitive: false), 'heart rate');
    result = result.replaceAll(RegExp(r'heart\s+red', caseSensitive: false), 'heart rate');
    result = result.replaceAll(RegExp(r'heart\s+ret', caseSensitive: false), 'heart rate');
    result = result.replaceAll(RegExp(r'hard\s+drive', caseSensitive: false), 'heart rate');

    // ===== RR keyword artifacts =====
    // Chrome returns: "Desperation" for "respiration"
    result = result.replaceAll(RegExp(r'\bdesperation\b', caseSensitive: false), 'respiration');
    result = result.replaceAll(RegExp(r'\bdespiration\b', caseSensitive: false), 'respiration');
    result = result.replaceAll(RegExp(r'\binspiration\b', caseSensitive: false), 'respiration');
    result = result.replaceAll(RegExp(r'\brespect\s*ration\b', caseSensitive: false), 'respiration');
    result = result.replaceAll(RegExp(r'\brest\s*per\s*ation\b', caseSensitive: false), 'respiration');

    // Clean up multiple spaces
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();

    return result;
  }

  // ─────────────────────── Blood Pressure ───────────────────────

  (int, int)? _extractBloodPressure(String text) {
    // Pattern 1: numeric/numeric (e.g., "120/80")
    final slashPattern = RegExp(r'(\d{2,3})\s*/\s*(\d{2,3})');
    final slashMatch = slashPattern.firstMatch(text);
    if (slashMatch != null) {
      final sys = int.tryParse(slashMatch.group(1)!);
      final dia = int.tryParse(slashMatch.group(2)!);
      if (sys != null && dia != null) return _validateBpPair(sys, dia);
    }

    // Pattern 2: "X over Y" with optional BP prefix
    final overPattern = RegExp(
      r'(?:(?:bp|b\.p\.|blood\s*pressure)' + _optionalConnector + r')?' +
      r'(\d{2,3})\s+over\s+(\d{2,3})',
    );
    final overMatch = overPattern.firstMatch(text);
    if (overMatch != null) {
      final sys = int.tryParse(overMatch.group(1)!);
      final dia = int.tryParse(overMatch.group(2)!);
      if (sys != null && dia != null) return _validateBpPair(sys, dia);
    }

    // Pattern 3: "bp X Y" or "blood pressure X Y" (two numbers after keyword)
    final bpPattern = RegExp(
      r'(?:bp|b\.p\.|blood\s*pressure)' + _optionalConnector + r'(\d{2,3})\s+(\d{2,3})',
    );
    final bpMatch = bpPattern.firstMatch(text);
    if (bpMatch != null) {
      final sys = int.tryParse(bpMatch.group(1)!);
      final dia = int.tryParse(bpMatch.group(2)!);
      if (sys != null && dia != null) return _validateBpPair(sys, dia);
    }

    // Pattern 4: Concatenated numbers like "12080", "13085", "bp12080"
    final concatPattern = RegExp(
      r'(?:(?:bp|b\.p\.|blood\s*pressure)\s*)?(\d{4,6})',
    );
    final concatMatch = concatPattern.firstMatch(text);
    if (concatMatch != null) {
      final concat = concatMatch.group(1)!;
      final split = _splitConcatenatedBP(concat);
      if (split != null) return split;
    }

    return null;
  }

  (int, int)? _splitConcatenatedBP(String digits) {
    if (digits.length == 5) {
      final sys = int.tryParse(digits.substring(0, 3));
      final dia = int.tryParse(digits.substring(3));
      if (sys != null && dia != null) return _validateBpPair(sys, dia);
    }
    if (digits.length == 6) {
      final sys = int.tryParse(digits.substring(0, 3));
      final dia = int.tryParse(digits.substring(3));
      if (sys != null && dia != null) return _validateBpPair(sys, dia);
    }
    if (digits.length == 4) {
      final sys = int.tryParse(digits.substring(0, 2));
      final dia = int.tryParse(digits.substring(2));
      if (sys != null && dia != null) return _validateBpPair(sys, dia);
    }
    return null;
  }

  (int, int)? _validateBpPair(int sys, int dia) {
    if (sys > dia && sys >= 60 && sys <= 250 && dia >= 30 && dia <= 160) {
      return (sys, dia);
    }
    return null;
  }

  // ─────────────────────── Heart Rate ───────────────────────

  int? _extractHeartRate(String text) {
    // Primary: keyword + optional connector + number
    final hrPattern = RegExp(
      r'(?:heart\s*rate|heartrate|hr|pulse|pulse\s*rate|beats?\s*per\s*minute|bpm)'
      + _optionalConnector +
      r'(\d{2,3})',
    );
    final match = hrPattern.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    // Reverse: "78 bpm" or "78 beats per minute"
    final reversePattern = RegExp(
      r'(\d{2,3})\s+(?:bpm|beats?\s*per\s*minute)',
    );
    final reverseMatch = reversePattern.firstMatch(text);
    if (reverseMatch != null) {
      return int.tryParse(reverseMatch.group(1)!);
    }

    return null;
  }

  // ─────────────────────── Temperature ───────────────────────

  double? _extractTemperature(String text) {
    // Primary: keyword + optional connector + number
    final tempPattern = RegExp(
      r'(?:temperature|temp|fever)'
      + _optionalConnector +
      r'(\d{2,3}(?:\.\d{1,2})?)',
    );
    final match = tempPattern.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }

    // Reverse: "98.6 degrees" or "98.6 fahrenheit"
    final reversePattern = RegExp(
      r'(\d{2,3}(?:\.\d{1,2})?)\s+(?:degrees?|fahrenheit|°|°f)',
    );
    final reverseMatch = reversePattern.firstMatch(text);
    if (reverseMatch != null) {
      return double.tryParse(reverseMatch.group(1)!);
    }

    return null;
  }

  // ─────────────────────── SpO2 ───────────────────────

  int? _extractSpO2(String text) {
    // Primary: keyword + optional connector + number
    final spo2Pattern = RegExp(
      r'(?:spo2|sp02|oxygen\s*saturation|oxygen\s*level|oxygen|o2\s*sat(?:uration)?|o2|saturation)'
      + _optionalConnector +
      r'(\d{2,3})',
    );
    final match = spo2Pattern.firstMatch(text);
    if (match != null) {
      final val = int.tryParse(match.group(1)!);
      // Only accept values in SpO2-plausible range to avoid false matches
      // "oxygen" is a broad keyword, so we constrain to 70-100
      if (val != null && val >= 70 && val <= 100) return val;
    }

    // Reverse: "98% spo2" or "98 percent oxygen"
    final reversePattern = RegExp(
      r'(\d{2,3})\s*(?:%|percent)\s*(?:spo2|sp02|oxygen|o2|saturation)',
    );
    final reverseMatch = reversePattern.firstMatch(text);
    if (reverseMatch != null) {
      return int.tryParse(reverseMatch.group(1)!);
    }

    // Reverse: "98 percent" alone (likely SpO2 if in range)
    final percentPattern = RegExp(r'(\d{2,3})\s*(?:%|percent)');
    final percentMatch = percentPattern.firstMatch(text);
    if (percentMatch != null) {
      final val = int.tryParse(percentMatch.group(1)!);
      if (val != null && val >= 70 && val <= 100) return val;
    }

    return null;
  }

  // ─────────────────────── Respiration Rate ───────────────────────

  int? _extractRespirationRate(String text) {
    // Primary: keyword + optional connector + number
    final rrPattern = RegExp(
      r'(?:respiration\s*rate|respiration|respiratory\s*rate|rr|breathing\s*rate|breaths?\s*per\s*minute|respiratory|resp)'
      + _optionalConnector +
      r'(\d{1,2})',
    );
    final match = rrPattern.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    // Reverse: "18 breaths per minute"
    final reversePattern = RegExp(
      r'(\d{1,2})\s+(?:breaths?\s*per\s*minute)',
    );
    final reverseMatch = reversePattern.firstMatch(text);
    if (reverseMatch != null) {
      return int.tryParse(reverseMatch.group(1)!);
    }

    return null;
  }
}
