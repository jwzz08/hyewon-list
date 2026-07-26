# hyewon_list

A personal, local-first desktop widget-style to-do list and calendar planner.
Windows desktop first; architected to expand to iOS and web later.

This repository contains the **Dart/Flutter source (`lib/`) and project config only**.
Native platform folders (`windows/`, `android/`, `ios/`, `web/`, `macos/`, `linux/`) and
generated Drift code are intentionally not included — see Setup below.

See **ARCHITECTURE.md** for the full architecture explanation, what's implemented vs.
planned, and the phased roadmap for drag-and-drop, recurrence UI, Firebase sync, and
Windows-native enhancements.

## Setup

Requires Flutter 3.24+ (Dart 3.4+) with Windows desktop support enabled
(`flutter config --enable-windows-desktop`).

The local database is stored as plaintext SQLite (see `lib/data/local/database/database.dart`
for why — encryption-at-rest was attempted twice and reverted; this is a known, accepted gap,
see ARCHITECTURE.md §7).

```bash
# 1. From this folder, generate the native platform scaffolding:
flutter create --platforms=windows,ios,web,macos .

# 2. Get packages:
flutter pub get

# 3. Generate Drift's database code (required — database.dart won't compile
#    without this):
dart run build_runner build --delete-conflicting-outputs

# 4. Run on Windows:
flutter run -d windows
```

If step 1 overwrites `pubspec.yaml`/`analysis_options.yaml`/`lib/main.dart`, restore the
versions from this repo afterward — `flutter create .` on an existing folder only adds the
missing platform directories but can still touch a few top-level files depending on your
Flutter version.

### Fonts

`AppTextStyles` uses Google Fonts (Quicksand + Nunito) via the `google_fonts` package,
which downloads and caches font files on first run. For a fully offline-first install,
bundle the `.ttf` files under `assets/fonts/` and switch `pubspec.yaml`'s commented-out
`fonts:` section on — see the TODO comments in `pubspec.yaml`.

## Project status

Phase 1 (foundation), Phase 2 (desktop window), Phase 3 (tasks), Phase 4 (basic
calendar), and Phase 5 (planner layout) are implemented and wired end-to-end against a
local Drift/SQLite database. Phases 6-9 (full drag-and-drop, recurrence editor UI,
polished import/export, Firebase sync) are architected but not fully built — see
ARCHITECTURE.md for exactly what's stubbed vs. done.
