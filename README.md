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

If you want to run the project locally on your device or emulator:
1. Open the `demo_app` directory in your IDE.
2. Ensure you have a working device/emulator selected.
3. Run the project (`F5` in VS Code). 

> **Note**: For web testing, a local python server script (`nocache_server.py`) is provided in `demo_app` to bypass strict browser caching constraints during development.

## Tech Stack
- **Flutter** & **Dart**
- **Riverpod** (State Management)
- **Speech to Text** (`speech_to_text`) plugin
