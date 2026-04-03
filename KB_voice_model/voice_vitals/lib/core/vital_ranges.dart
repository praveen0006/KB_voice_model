/// Validation ranges for patient vitals.
///
/// These are clinically reasonable ranges used to reject
/// obviously incorrect speech recognition results.
class VitalRanges {
  VitalRanges._();

  // Blood Pressure — Systolic
  static const int systolicMin = 80;
  static const int systolicMax = 200;

  // Blood Pressure — Diastolic
  static const int diastolicMin = 50;
  static const int diastolicMax = 130;

  // Heart Rate (BPM)
  static const int heartRateMin = 40;
  static const int heartRateMax = 180;

  // Temperature (°F)
  static const double temperatureMin = 95.0;
  static const double temperatureMax = 105.0;

  // SpO2 (%)
  static const int spo2Min = 70;
  static const int spo2Max = 100;

  // Respiration Rate (breaths per minute)
  static const int respirationRateMin = 8;
  static const int respirationRateMax = 40;
}
