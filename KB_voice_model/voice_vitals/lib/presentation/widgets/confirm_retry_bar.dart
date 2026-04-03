import 'package:flutter/material.dart';

/// Confirm / Retry action bar for the vitals entry flow.
class ConfirmRetryBar extends StatelessWidget {
  final bool canConfirm;
  final bool isSaving;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;

  const ConfirmRetryBar({
    super.key,
    required this.canConfirm,
    required this.isSaving,
    required this.onConfirm,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Retry button
        Expanded(
          child: _ActionButton(
            onPressed: onRetry,
            icon: Icons.refresh_rounded,
            label: 'Retry',
            backgroundColor: const Color(0xFF334155),
            textColor: const Color(0xFF94A3B8),
            borderColor: const Color(0xFF475569),
          ),
        ),
        const SizedBox(width: 12),
        // Confirm button
        Expanded(
          flex: 2,
          child: _ActionButton(
            onPressed: canConfirm && !isSaving ? onConfirm : null,
            icon: isSaving
                ? Icons.hourglass_top_rounded
                : Icons.check_rounded,
            label: isSaving ? 'Saving...' : 'Confirm & Save',
            backgroundColor: canConfirm
                ? const Color(0xFF22C55E)
                : const Color(0xFF1E293B),
            textColor:
                canConfirm ? Colors.white : const Color(0xFF64748B),
            borderColor: canConfirm
                ? const Color(0xFF22C55E)
                : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            boxShadow: onPressed != null
                ? [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
