import 'package:flutter/material.dart';

/// Animated pulsing microphone button.
///
/// Pulses with a glowing ring when [isListening] is true.
/// Shows a mic icon normally, stop icon when listening.
class RecordingButton extends StatefulWidget {
  final bool isListening;
  final bool isAvailable;
  final VoidCallback onPressed;

  const RecordingButton({
    super.key,
    required this.isListening,
    required this.isAvailable,
    required this.onPressed,
  });

  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnim = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(RecordingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isListening && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing ring
        if (widget.isListening)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 90 * _scaleAnim.value,
                height: 90 * _scaleAnim.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0EA5E9)
                        .withOpacity(_opacityAnim.value),
                    width: 3,
                  ),
                ),
              );
            },
          ),
        // Main button
        GestureDetector(
          onTap: widget.isAvailable ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isListening
                    ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                    : widget.isAvailable
                        ? [const Color(0xFF0EA5E9), const Color(0xFF0284C7)]
                        : [Colors.grey.shade400, Colors.grey.shade500],
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.isListening
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF0EA5E9))
                      .withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              widget.isListening ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }
}
