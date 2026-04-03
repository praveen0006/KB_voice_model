import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../../core/logger.dart';

/// State for the speech recognition service.
class SpeechState {
  final bool isAvailable;
  final bool isListening;
  final String transcript;
  final String partialTranscript;
  final String? error;

  const SpeechState({
    this.isAvailable = false,
    this.isListening = false,
    this.transcript = '',
    this.partialTranscript = '',
    this.error,
  });

  SpeechState copyWith({
    bool? isAvailable,
    bool? isListening,
    String? transcript,
    String? partialTranscript,
    String? error,
  }) {
    return SpeechState(
      isAvailable: isAvailable ?? this.isAvailable,
      isListening: isListening ?? this.isListening,
      transcript: transcript ?? this.transcript,
      partialTranscript: partialTranscript ?? this.partialTranscript,
      error: error,
    );
  }
}

/// Manages speech_to_text lifecycle and state.
///
/// Note: On Chrome Web, the speech_to_text plugin's `recognizedWords`
/// already contains the full accumulated text for the session, so we
/// use it directly without manual accumulation.
class SpeechNotifier extends StateNotifier<SpeechState> {
  final SpeechToText _speech = SpeechToText();
  String _lastTranscript = '';

  SpeechNotifier() : super(const SpeechState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final available = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
      state = state.copyWith(isAvailable: available);
      if (!available) {
        state = state.copyWith(
          error: 'Speech recognition not available on this device',
        );
      }
      VitalsLogger.logInfo('Speech initialized: available=$available');
    } catch (e, stack) {
      VitalsLogger.logError('Speech initialization failed', e, stack);
      state = state.copyWith(
        isAvailable: false,
        error: 'Failed to initialize speech recognition',
      );
    }
  }

  /// Start listening for speech input.
  Future<void> startListening() async {
    if (!state.isAvailable) {
      state = state.copyWith(
          error: 'Speech recognition not available');
      return;
    }

    _lastTranscript = '';

    state = state.copyWith(
      isListening: true,
      transcript: '',
      partialTranscript: '',
      error: null,
    );

    try {
      await _speech.listen(
        onResult: _onResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        listenMode: ListenMode.dictation,
      );
    } catch (e, stack) {
      VitalsLogger.logError('Failed to start listening', e, stack);
      state = state.copyWith(
        isListening: false,
        error: 'Failed to start listening',
      );
    }
  }

  /// Stop listening.
  Future<void> stopListening() async {
    await _speech.stop();
    // Use whatever we have accumulated
    if (_lastTranscript.isNotEmpty) {
      state = state.copyWith(
        isListening: false,
        transcript: _lastTranscript,
        partialTranscript: '',
      );
    } else {
      state = state.copyWith(isListening: false);
    }
  }

  /// Reset transcript for a new recording.
  void reset() {
    _lastTranscript = '';
    state = state.copyWith(
      transcript: '',
      partialTranscript: '',
      error: null,
    );
  }

  void _onResult(SpeechRecognitionResult result) {
    // recognizedWords always contains the full text so far
    final words = result.recognizedWords.trim();
    
    if (words.isNotEmpty) {
      _lastTranscript = words;
    }

    if (result.finalResult) {
      state = state.copyWith(
        transcript: _lastTranscript,
        partialTranscript: '',
        isListening: false,
      );
      VitalsLogger.logTranscript(_lastTranscript);
    } else {
      // Show live partial text
      state = state.copyWith(
        partialTranscript: words,
      );
    }
  }

  void _onStatus(String status) {
    VitalsLogger.logInfo('Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      // Make sure we set the final transcript if we have one
      if (_lastTranscript.isNotEmpty && state.transcript != _lastTranscript) {
        state = state.copyWith(
          isListening: false,
          transcript: _lastTranscript,
        );
      } else {
        state = state.copyWith(isListening: false);
      }
    }
  }

  void _onError(dynamic error) {
    VitalsLogger.logError('Speech error: $error');
    state = state.copyWith(
      isListening: false,
      transcript: _lastTranscript.isNotEmpty ? _lastTranscript : state.transcript,
      error: 'Speech recognition error. Please try again.',
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _speech.cancel();
    super.dispose();
  }
}

/// Global provider for speech recognition state.
final speechProvider =
    StateNotifierProvider<SpeechNotifier, SpeechState>((ref) {
  return SpeechNotifier();
});
