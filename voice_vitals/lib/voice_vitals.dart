/// Voice-Based Vitals Entry feature module.
///
/// Provides voice capture → parse → validate → confirm → store workflow
/// for patient vitals (Blood Pressure, Heart Rate, Temperature).
///
/// ## Usage
/// ```dart
/// import 'package:voice_vitals/voice_vitals.dart';
///
/// // Navigate to the main screen:
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => const VoiceVitalsScreen(),
/// ));
/// ```
library voice_vitals;

// Core
export 'core/number_normalizer.dart';
export 'core/vital_ranges.dart';
export 'core/logger.dart';

// Domain
export 'domain/entities/vital_record.dart';
export 'domain/usecases/parse_vitals.dart';
export 'domain/usecases/save_vitals.dart';
export 'domain/repositories/vitals_repository.dart';

// Data
export 'data/parsers/vitals_parser.dart';
export 'data/validators/vitals_validator.dart';
export 'data/repositories/vitals_repository_impl.dart';
export 'data/models/vital_record_model.dart';

// Presentation
export 'presentation/providers/speech_provider.dart';
export 'presentation/providers/vitals_provider.dart';
export 'presentation/screens/voice_vitals_screen.dart';
export 'presentation/screens/vitals_history_screen.dart';
export 'presentation/widgets/recording_button.dart';
export 'presentation/widgets/transcript_display.dart';
export 'presentation/widgets/vitals_preview_card.dart';
export 'presentation/widgets/confirm_retry_bar.dart';
