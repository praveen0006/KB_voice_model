import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/speech_provider.dart';
import '../providers/vitals_provider.dart';
import '../widgets/recording_button.dart';
import '../widgets/transcript_display.dart';
import '../widgets/vitals_preview_card.dart';
import '../widgets/confirm_retry_bar.dart';
import 'vitals_history_screen.dart';

/// Main screen for voice-based vitals entry.
///
/// Flow: Tap mic → speak → see parsed vitals → confirm/retry.
///
/// Usage from host app:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => const VoiceVitalsScreen(),
/// ));
/// ```
class VoiceVitalsScreen extends ConsumerStatefulWidget {
  const VoiceVitalsScreen({super.key});

  @override
  ConsumerState<VoiceVitalsScreen> createState() => _VoiceVitalsScreenState();
}

class _VoiceVitalsScreenState extends ConsumerState<VoiceVitalsScreen> {
  @override
  Widget build(BuildContext context) {
    final speechState = ref.watch(speechProvider);
    final vitalsState = ref.watch(vitalsProvider);

    // Auto-parse when transcript arrives
    ref.listen<SpeechState>(speechProvider, (prev, next) {
      if (next.transcript.isNotEmpty &&
          next.transcript != (prev?.transcript ?? '')) {
        ref.read(vitalsProvider.notifier).parseTranscript(next.transcript);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Voice Vitals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Color(0xFF94A3B8)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VitalsHistoryScreen(),
                ),
              );
            },
            tooltip: 'History',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Success banner
              if (vitalsState.savedSuccessfully)
                _SuccessBanner(
                  onDismiss: () =>
                      ref.read(vitalsProvider.notifier).retry(),
                ),

              // Save error banner
              if (vitalsState.saveError != null)
                _ErrorBanner(message: vitalsState.saveError!),

              const SizedBox(height: 12),

              // Transcript display
              TranscriptDisplay(
                transcript: speechState.transcript,
                partialTranscript: speechState.partialTranscript,
                isListening: speechState.isListening,
                error: speechState.error,
              ),

              const SizedBox(height: 16),

              // DEBUG PANEL — shows raw transcript + parsed values
              if (vitalsState.debugInfo.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    vitalsState.debugInfo,
                    style: const TextStyle(
                      color: Color(0xFFFCD34D),
                      fontSize: 11,
                      fontFamily: 'monospace',
                      height: 1.4,
                    ),
                  ),
                ),

              // Parsed vitals preview
              if (vitalsState.parseResult != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: VitalsPreviewCard(result: vitalsState.parseResult!),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mic_none_rounded,
                          size: 60,
                          color: const Color(0xFF334155),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tap the button to start recording',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Say something like:\n"BP 120 over 80, heart rate 78,\nSpO2 98, respiration 18"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Confirm / Retry buttons (show after parsing)
              if (vitalsState.parseResult != null &&
                  !vitalsState.savedSuccessfully)
                ConfirmRetryBar(
                  canConfirm: vitalsState.parseResult!.isValid,
                  isSaving: vitalsState.isSaving,
                  onConfirm: () =>
                      ref.read(vitalsProvider.notifier).confirmAndSave(),
                  onRetry: _handleRetry,
                ),

              const SizedBox(height: 24),

              // Recording button
              RecordingButton(
                isListening: speechState.isListening,
                isAvailable: speechState.isAvailable,
                onPressed: () => _toggleRecording(speechState),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleRecording(SpeechState state) {
    if (state.isListening) {
      ref.read(speechProvider.notifier).stopListening();
    } else {
      // Reset state for new recording
      ref.read(speechProvider.notifier).reset();
      ref.read(vitalsProvider.notifier).retry();
      ref.read(speechProvider.notifier).startListening();
    }
  }

  void _handleRetry() {
    ref.read(speechProvider.notifier).reset();
    ref.read(vitalsProvider.notifier).retry();
  }
}

/// Success banner shown after saving.
class _SuccessBanner extends StatelessWidget {
  final VoidCallback onDismiss;

  const _SuccessBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF22C55E).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF22C55E), size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Vitals saved successfully!',
              style: TextStyle(
                color: Color(0xFF86EFAC),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Text(
              'New Entry',
              style: TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error banner for save failures.
class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFCA5A5),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
