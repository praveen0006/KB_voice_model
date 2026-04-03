import 'dart:convert';
import '../../domain/entities/vital_record.dart';

/// JSON-serializable model for [VitalRecord].
class VitalRecordModel {
  final DateTime timestamp;
  final int? systolic;
  final int? diastolic;
  final int? heartRate;
  final double? temperature;
  final int? spo2;
  final int? respirationRate;

  const VitalRecordModel({
    required this.timestamp,
    this.systolic,
    this.diastolic,
    this.heartRate,
    this.temperature,
    this.spo2,
    this.respirationRate,
  });

  /// Create from domain entity.
  factory VitalRecordModel.fromEntity(VitalRecord record) {
    return VitalRecordModel(
      timestamp: record.timestamp,
      systolic: record.bloodPressure?.systolic,
      diastolic: record.bloodPressure?.diastolic,
      heartRate: record.heartRate,
      temperature: record.temperature,
      spo2: record.spo2,
      respirationRate: record.respirationRate,
    );
  }

  /// Create from JSON map.
  factory VitalRecordModel.fromJson(Map<String, dynamic> json) {
    return VitalRecordModel(
      timestamp: DateTime.parse(json['timestamp'] as String),
      systolic: json['blood_pressure']?['systolic'] as int?,
      diastolic: json['blood_pressure']?['diastolic'] as int?,
      heartRate: json['heart_rate'] as int?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      spo2: json['spo2'] as int?,
      respirationRate: json['respiration_rate'] as int?,
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'timestamp': timestamp.toUtc().toIso8601String(),
    };

    if (systolic != null && diastolic != null) {
      map['blood_pressure'] = {
        'systolic': systolic,
        'diastolic': diastolic,
      };
    }

    if (heartRate != null) map['heart_rate'] = heartRate;
    if (temperature != null) map['temperature'] = temperature;
    if (spo2 != null) map['spo2'] = spo2;
    if (respirationRate != null) map['respiration_rate'] = respirationRate;

    return map;
  }

  /// Convert to JSON string.
  String toJsonString() => jsonEncode(toJson());

  /// Convert to domain entity.
  VitalRecord toEntity() {
    return VitalRecord(
      timestamp: timestamp,
      bloodPressure: (systolic != null && diastolic != null)
          ? BloodPressure(systolic: systolic!, diastolic: diastolic!)
          : null,
      heartRate: heartRate,
      temperature: temperature,
      spo2: spo2,
      respirationRate: respirationRate,
    );
  }

  /// CSV header row.
  static String get csvHeader =>
      'timestamp,systolic,diastolic,heart_rate,temperature,spo2,respiration_rate';

  /// Convert to CSV row.
  String toCsvRow() {
    return '${timestamp.toUtc().toIso8601String()},${systolic ?? ''},${diastolic ?? ''},${heartRate ?? ''},${temperature ?? ''},${spo2 ?? ''},${respirationRate ?? ''}';
  }
}
