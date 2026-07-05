# BrainBox AI

A complete, fully offline Flutter mobile application — a smart personal memory assistant that stores notes, images, voice notes, and PDFs locally with intelligent keyword search.

## Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Local Database**: Hive (offline-first, no backend)
- **Architecture**: Feature-based clean architecture

## Key Features

- 📝 **Notes** — Create/edit/delete notes with tags and search
- 🖼️ **Image Memory** — Save and describe images locally
- 🎤 **Voice Notes** — Record, play back, and search voice notes
- 📄 **PDF Vault** — Store and view PDF documents in-app
- 🔍 **Smart Search** — Keyword + tag search across all modules
- 🕐 **Timeline** — Chronological view of all memories
- 🤖 **Ask BrainBox** — Chat-style local keyword search (no AI APIs)
- ⚙️ **Settings** — Language switcher (EN/AR with RTL), dark mode
- 📤 **Export** — Export all data as JSON

## Design

- **Dark mode required** (default and enforced)
- Color palette: deep navy background (#0A0E1A), purple primary (#7C3AED), cyan secondary (#06B6D4)
- Modern minimal UI inspired by Notion/Keep/Apple Notes
- Responsive for phones and tablets
- Full Arabic RTL support

## Folder Structure

```
lib/
├── core/          # Theme, colors, constants
├── models/        # Hive models + type adapters (manually written)
├── services/      # HiveService, SearchService
├── providers/     # ChangeNotifier providers for each module
├── screens/       # 9 screens across 5 feature folders
├── widgets/       # Reusable UI components
├── utils/         # AppLocalizations (EN + AR)
└── main.dart
```

## Running the App

```bash
flutter pub get
flutter run                        # default device
flutter run -d chrome              # web (limited native features)
flutter build apk --release        # Android APK
flutter build ios --release        # iOS (Mac required)
```

## Notes

- Hive type adapters are **manually written** (no build_runner step needed)
- Voice recording requires RECORD_AUDIO permission on Android, NSMicrophoneUsageDescription on iOS
- Image/camera requires READ_MEDIA_IMAGES / NSPhotoLibraryUsageDescription
- All data stored in device's app documents directory (no cloud)

## User Preferences

- Dark mode is **required** (not optional)
- Supports Arabic (RTL) and English (LTR)
