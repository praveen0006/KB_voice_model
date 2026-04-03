import 'package:flutter/material.dart';

/// Displays live speech transcription with a blinking cursor effect.
class TranscriptDisplay extends StatelessWidget {
  final String transcript;
  final String partialTranscript;
  final bool isListening;
  final String? error;

  const TranscriptDisplay({
    super.key,
    required this.transcript,
    required this.partialTranscript,
    required this.isListening,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = transcript.isNotEmpty
        ? transcript
        : partialTranscript.isNotEmpty
            ? partialTranscript
            : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isListening
              ? const Color(0xFF0EA5E9).withOpacity(0.5)
              : const Color(0xFF334155),
          width: isListening ? 2 : 1,
        ),
        boxShadow: isListening
            ? [
                BoxShadow(
                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                isListening ? Icons.hearing : Icons.text_fields_rounded,
                color: const Color(0xFF94A3B8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isListening ? 'Listening...' : 'Transcript',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              if (isListening) ...[
                const SizedBox(width: 8),
                _PulsingDot(),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Error message
          if (error != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error!,
                      style: const TextStyle(
                        color: Color(0xFFFCA5A5),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Transcript text
          if (error == null)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: displayText != null
                  ? Text(
                      displayText,
                      key: ValueKey(displayText),
                      style: TextStyle(
                        color: transcript.isNotEmpty
                            ? Colors.white
                            : const Color(0xFF94A3B8),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        fontStyle: transcript.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    )
                  : Text(
                      isListening
                          ? 'Speak your vitals now...'
                          : 'Tap the microphone to start recording',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

/// Small pulsing green dot to indicate active listening.
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                const Color(0xFF22C55E).withOpacity(0.5 + _controller.value * 0.5),
          ),
        );
      },
    );
  }
}
