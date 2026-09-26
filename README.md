# hyewon_list

A personal, local-first desktop widget-style to-do list and calendar planner —
a small always-on-top "memo" widget that expands into a full weekly
planner/monthly calendar, with tasks and calendar events kept as separate,
color-coded sections everywhere. Runs on Windows; a companion iOS app is in
progress on a separate branch.

Highlights: drag-and-drop between the weekly planner's To-do/Schedule
sections and a MEMO list of undated to-dos, recurring events (daily/weekly/
monthly/yearly, with this-occurrence/this-and-following/entire-series edit
and delete), reminders/notifications, Korean/Canada holidays + lunar
calendar + 24 solar terms, tags/categories/theme presets, CSV/JSON import
and export, and optional Firebase sign-in for syncing across your own
devices. See **ARCHITECTURE.md** for the full technical write-up of what's
implemented vs. still planned.

## Installing (for friends/testers — no Flutter needed)

Go to this repo's **[Releases](../../releases)** page (not the green "Code"
button — that only downloads the source, which needs the full Flutter/Visual
Studio toolchain to build) and grab the latest version. Two options are
published for each release:

- **`hyewon_list_setup_X.X.X.exe`** (recommended) — a normal Windows
  installer. Run it, click through the wizard, and it adds a Start Menu
  entry, an optional desktop shortcut, and a proper uninstaller under
  "Add or remove programs". Doesn't need admin rights.
- **`hyewon_list_windows_X.X.X.zip`** (portable) — no installer at all.
  Unzip it anywhere and run `hyewon_list.exe` directly from inside the
  extracted folder. Useful if you'd rather not install anything, but keep
  the whole extracted folder together — the exe won't run on its own
  without the DLLs and `data\` folder sitting next to it.

Windows SmartScreen will likely show an "Unknown publisher" warning the
first time you run either one, since the app isn't code-signed — click
**"More info" → "Run anyway"**.

**Updating an existing install**: your data (to-dos, events, categories,
settings, etc.) lives in `%LOCALAPPDATA%\hyewon_list`, completely separate
from wherever the program itself is installed. Installing a newer version
over an old one (same installer, or a fresh portable zip) never touches
that folder, so nothing gets lost — just install/extract the new version
and keep using it.

## Building the release + installer (for whoever's publishing a version)

```bash
# 1. Build the release binaries:
flutter build windows --release

# 2. Zip the whole output folder for the portable download — the exe alone
#    will not run without the DLLs and data\ folder next to it:
#    build\windows\x64\runner\Release\  →  hyewon_list_windows_X.X.X.zip

# 3. Build the installer (requires Inno Setup — free, https://jrsoftware.org/isinfo.php):
iscc windows\installer\hyewon_list.iss
# Output lands in installer_output\hyewon_list_setup_X.X.X.exe (gitignored —
# this is a release artifact, not something tracked in the repo).
```

Then upload both files (the zip and the installer exe) as binary assets on
a new [GitHub Release](../../releases/new), tagged with the version number.

See `windows/installer/hyewon_list.iss` for the installer script itself —
it packages whatever's currently in `build\windows\x64\runner\Release`, so
step 1 always has to run first. Bump `MyAppVersion` at the top of that file
to match the version you're publishing.

## Developer setup

Requires Flutter 3.24+ (Dart 3.4+) with Windows desktop support enabled
(`flutter config --enable-windows-desktop`).

The local database is stored as plaintext SQLite (see
`lib/data/local/database/database.dart` for why — encryption-at-rest was
attempted twice and reverted; this is a known, accepted gap, see
ARCHITECTURE.md §7). It lives at `%LOCALAPPDATA%\hyewon_list\hyewon_list\hyewon_list.sqlite`,
independent of wherever the app itself is installed/run from.

```bash
# 1. Get packages:
flutter pub get

# 2. Generate Drift's database code (required — database.dart won't compile
#    without this):
dart run build_runner build --delete-conflicting-outputs

# 3. Run on Windows:
flutter run -d windows
```

Firebase sync is optional and fails soft if unconfigured — `firebase_options.dart`
and `.firebaserc` in this repo point at this project's own Firebase project;
if you're forking this to run your own instance, replace those with your
own (`flutterfire configure`) rather than reusing this project's.

### Fonts

`AppTextStyles` uses Google Fonts (Quicksand + Nunito) via the `google_fonts`
package, which downloads and caches font files on first run. For a fully
offline-first install, bundle the `.ttf` files under `assets/fonts/` and
switch `pubspec.yaml`'s commented-out `fonts:` section on — see the TODO
comments in `pubspec.yaml`.

## Project status

Tasks, calendar events (including recurrence and occurrence-level edit/
delete), the weekly planner (with drag-and-drop between To-do/Schedule
sections and the MEMO list), reminders/notifications, categories/tags/theme
presets, holidays/lunar calendar/solar terms, search, CSV/JSON import-export,
and Firebase sign-in/sync are all implemented and wired end-to-end against a
local Drift/SQLite database. See ARCHITECTURE.md for the detailed
implemented-vs-planned breakdown and the handful of remaining known gaps
(e.g. no code signing yet, plaintext-at-rest DB, Firebase App Check
unavailable on Windows).
