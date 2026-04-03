# KB Voice Model

An intelligent, voice-first Flutter system designed to capture and parse patient vital signs directly from clinical speech. 

This repository contains the complete ecosystem for the Voice Vitals project:
1. **`voice_vitals/`**: The core, self-contained feature module (package). It handles all Natural Language Processing (NLP) regex logic, validation, state management (Riverpod), and audio capture.
2. **`demo_app/`**: A parent sandbox application demonstrating how to seamlessly ingest and use the `voice_vitals` package in a real-world scenario.

## Key Features
- **Intelligent Speech Parsing**: Automatically handles clinical speech artifacts (e.g., converting "one thirty by eighty" into "130/80").
- **Real-Time Validation**: Drops inputs outside realistic clinical boundaries.
- **Local Persistence**: Stores parsed vitals locally as JSON files.

## Getting Started

To test or integrate the module, you'll primarily want to look at the [voice_vitals module instructions](voice_vitals/README.md).

### Testing the Voice Model in Chrome (Web)
The easiest way for the team to activate and test the speech-to-text NLP model is by running the `demo_app` via the Flutter dev server:

1. Open your terminal and navigate to the `demo_app` directory.
2. Launch the application using the local web server:
   ```bash
   flutter run -d web-server --web-port=8686
   ```
3. Once the terminal indicates it is serving, open **Chrome** (or Edge) and navigate to `http://localhost:8686`.
4. Click the Microphone icon, allow access, and dictate your patient vitals (e.g., "BP 130 over 80, heart rate 72, SP 98, respiration 18"). The engine will automatically parse and log the structured data.

### Running natively (Mobile / Desktop)
If you prefer to run the project locally on your physical device or emulator:
1. Open the `demo_app` directory in your IDE.
2. Select your device/emulator.
3. Run the project (`F5` in VS Code).

## Tech Stack
- **Flutter** & **Dart**
- **Riverpod** (State Management)
- **Speech to Text** (`speech_to_text`) plugin
