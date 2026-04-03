import 'dart:developer' as developer;

/// Simple logger for the voice_vitals module.
///
/// Logs raw transcripts, parsed output, and validation errors
/// for debugging speech recognition and parsing accuracy.
class VitalsLogger {
  VitalsLogger._();

  static const String _tag = 'VoiceVitals';

  /// Log raw speech transcript.
  static void logTranscript(String transcript) {
    developer.log(
      'RAW TRANSCRIPT: $transcript',
      name: _tag,
    );
  }

  /// Log parsed vitals output.
  static void logParsed(Map<String, dynamic> parsed) {
    developer.log(
      'PARSED OUTPUT: $parsed',
      name: _tag,
    );
  }

  /// Log validation errors.
  static void logValidationError(String field, dynamic value, String reason) {
    developer.log(
      'VALIDATION ERROR: $field=$value — $reason',
      name: _tag,
      level: 900, // warning level
    );
  }

  /// Log general errors.
  static void logError(String message, [Object? error, StackTrace? stack]) {
    developer.log(
      'ERROR: $message',
      name: _tag,
      level: 1000,
      error: error,
      stackTrace: stack,
    );
  }

  /// Log info-level messages.
  static void logInfo(String message) {
    developer.log(
      'INFO: $message',
      name: _tag,
    );
  }
}
