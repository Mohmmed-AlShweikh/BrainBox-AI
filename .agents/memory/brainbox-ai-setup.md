---
name: BrainBox AI setup
description: Key decisions and constraints from building the full BrainBox AI Flutter app
---

## Hive type adapters
Written manually in `lib/models/*.g.dart` — no `build_runner` step is needed or configured. TypeIds: NoteModel=0, ImageModel=1, VoiceNoteModel=2, PdfModel=3.

**Why:** Flutter CLI is not available on Replit, so running `build_runner` isn't possible here. Manual adapters are equivalent and avoid the extra step when the user builds locally.

**How to apply:** If new Hive models are added, write the adapter manually in a matching `.g.dart` file following the same pattern, and register it in `HiveService.init()`.

## Dark mode requirement
Dark mode is required (not optional). `ThemeMode.dark` is hardcoded in `main.dart`. The settings toggle exists for UX but defaults always to dark.

## Localization
Map-based in `lib/utils/app_localizations.dart` — supports EN and AR. RTL handled at two levels: `Directionality` wrapper in `MainScreen` and `MaterialApp.builder`. No generated `.arb` files.

## Permissions removed
`MANAGE_EXTERNAL_STORAGE` was initially added to Android manifest but removed after code review — it's overprivileged and causes Play Store policy issues. Scoped storage permissions are sufficient.

## MANAGE_EXTERNAL_STORAGE removed
Removed from `android/app/src/main/AndroidManifest.xml` — use scoped storage (`READ_MEDIA_IMAGES`, `READ_MEDIA_AUDIO`, etc.) only.
