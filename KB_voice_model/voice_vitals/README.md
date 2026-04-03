# Voice Vitals — Feature Module

A self-contained Flutter feature module for voice-based patient vitals entry.

## What It Does

1. User taps **Start Recording**
2. Speaks vitals: *"BP 120 over 80, heart rate 78, temperature 98.6"*
3. App parses speech → structured data
4. Displays parsed results with validation
5. User confirms → saved to local JSON

## Integration Guide

### 1. Add Dependency

In your host app's `pubspec.yaml`:

```yaml
dependencies:
  voice_vitals:
    path: ./voice_vitals  # adjust path
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Add Platform Permissions

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

**iOS** — `ios/Runner/Info.plist`:
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to capture patient vitals.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record voice input.</string>
```

### 4. Wrap with ProviderScope

Ensure your app has a `ProviderScope` at the root (required for Riverpod):

```dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}
```

### 5. Navigate to the Screen

```dart
import 'package:voice_vitals/voice_vitals.dart';

Navigator.push(context, MaterialPageRoute(
  builder: (_) => const VoiceVitalsScreen(),
));
```

## Supported Speech Patterns

| Vital | Patterns |
|-------|----------|
| Blood Pressure | `"120/80"`, `"120 over 80"`, `"BP 120 over 80"`, `"blood pressure 130 over 85"` |
| Heart Rate | `"heart rate 78"`, `"HR 78"`, `"pulse 65"` |
| Temperature | `"temperature 98.6"`, `"temp 99.1"` |

Also handles:
- Word numbers: *"one twenty over eighty"* → `120/80`
- Multiple vitals in one sentence
- Partial inputs (only BP, only HR, etc.)

## Validation Ranges

| Vital | Min | Max |
|-------|-----|-----|
| Systolic BP | 80 | 200 |
| Diastolic BP | 50 | 130 |
| Heart Rate | 40 | 180 bpm |
| Temperature | 95 | 105 °F |

## Storage

Records are saved as append-only JSON in the app's documents directory (`vitals_records.json`).

CSV export is available from the History screen.

## Running Tests

```bash
cd voice_vitals
flutter test
```

## Architecture

Clean Architecture with Riverpod:

```
lib/
├── core/          # Utilities (number normalizer, logger, constants)
├── domain/        # Entities, use cases, repository interfaces
├── data/          # Parser, validator, JSON repository, models
└── presentation/  # Riverpod providers, screens, widgets
```
