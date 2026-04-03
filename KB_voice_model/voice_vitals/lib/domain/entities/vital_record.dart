/// Represents a blood pressure reading.
class BloodPressure {
  final int systolic;
  final int diastolic;

  const BloodPressure({required this.systolic, required this.diastolic});

  @override
  String toString() => '$systolic/$diastolic';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BloodPressure &&
          other.systolic == systolic &&
          other.diastolic == diastolic;

  @override
  int get hashCode => systolic.hashCode ^ diastolic.hashCode;
}

/// Represents a single vitals recording with timestamp.
class VitalRecord {
  final DateTime timestamp;
  final BloodPressure? bloodPressure;
  final int? heartRate;
  final double? temperature;
  final int? spo2;
  final int? respirationRate;

  const VitalRecord({
    required this.timestamp,
    this.bloodPressure,
    this.heartRate,
    this.temperature,
    this.spo2,
    this.respirationRate,
  });

  /// Returns true if at least one vital was captured.
  bool get hasData =>
      bloodPressure != null ||
      heartRate != null ||
      temperature != null ||
      spo2 != null ||
      respirationRate != null;

  @override
  String toString() {
    final parts = <String>[];
    if (bloodPressure != null) parts.add('BP: $bloodPressure');
    if (heartRate != null) parts.add('HR: $heartRate');
    if (temperature != null) parts.add('Temp: $temperature°F');
    if (spo2 != null) parts.add('SpO2: $spo2%');
    if (respirationRate != null) parts.add('RR: $respirationRate');
    return 'VitalRecord(${parts.join(', ')})';
  }
}
