import 'package:flutter/material.dart';
import '../../domain/usecases/parse_vitals.dart';

/// Displays parsed vitals with color-coded validation indicators.
class VitalsPreviewCard extends StatelessWidget {
  final ParseVitalsResult result;

  const VitalsPreviewCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final parsed = result.parsed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: result.isValid
              ? const Color(0xFF22C55E).withOpacity(0.3)
              : const Color(0xFFF59E0B).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (result.isValid
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFF59E0B))
                .withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                result.isValid
                    ? Icons.check_circle_rounded
                    : Icons.warning_amber_rounded,
                color: result.isValid
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                result.isValid ? 'Vitals Detected' : 'Review Required',
                style: TextStyle(
                  color: result.isValid
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFF59E0B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Vitals rows
          if (parsed.hasBloodPressure)
            _VitalRow(
              icon: Icons.favorite_rounded,
              label: 'Blood Pressure',
              value: '${parsed.systolic}/${parsed.diastolic}',
              unit: 'mmHg',
              isValid: _isFieldValid('Systolic BP') &&
                  _isFieldValid('Diastolic BP'),
              errorMessage: _getFieldError('Systolic BP') ??
                  _getFieldError('Diastolic BP'),
            ),

          if (parsed.hasHeartRate)
            _VitalRow(
              icon: Icons.monitor_heart_rounded,
              label: 'Heart Rate',
              value: '${parsed.heartRate}',
              unit: 'bpm',
              isValid: _isFieldValid('Heart Rate'),
              errorMessage: _getFieldError('Heart Rate'),
            ),

          if (parsed.hasTemperature)
            _VitalRow(
              icon: Icons.thermostat_rounded,
              label: 'Temperature',
              value: '${parsed.temperature}',
              unit: '°F',
              isValid: _isFieldValid('Temperature'),
              errorMessage: _getFieldError('Temperature'),
            ),

          if (parsed.hasSpo2)
            _VitalRow(
              icon: Icons.air_rounded,
              label: 'SpO2',
              value: '${parsed.spo2}',
              unit: '%',
              isValid: _isFieldValid('SpO2'),
              errorMessage: _getFieldError('SpO2'),
            ),

          if (parsed.hasRespirationRate)
            _VitalRow(
              icon: Icons.waves_rounded,
              label: 'Respiration Rate',
              value: '${parsed.respirationRate}',
              unit: 'brpm',
              isValid: _isFieldValid('Respiration Rate'),
              errorMessage: _getFieldError('Respiration Rate'),
            ),

          if (!parsed.hasAnyData)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      color: Color(0xFF64748B),
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No vitals detected',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Try: "BP 120 over 80, heart rate 78,\nSpO2 98, respiration 18"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isFieldValid(String fieldName) {
    final field = result.validation.fieldResults
        .where((f) => f.fieldName == fieldName)
        .firstOrNull;
    return field?.isValid ?? true;
  }

  String? _getFieldError(String fieldName) {
    final field = result.validation.fieldResults
        .where((f) => f.fieldName == fieldName && !f.isValid)
        .firstOrNull;
    return field?.errorMessage;
  }
}

/// Single vital sign row with icon, value, and validation status.
class _VitalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool isValid;
  final String? errorMessage;

  const _VitalRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.isValid,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isValid
                          ? const Color(0xFF0EA5E9)
                          : const Color(0xFFEF4444))
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isValid
                      ? const Color(0xFF0EA5E9)
                      : const Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            color: isValid
                                ? Colors.white
                                : const Color(0xFFEF4444),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unit,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                isValid
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded,
                color: isValid
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
                size: 22,
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFFCA5A5),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
