# hyewon_list — Architecture & Implementation Plan

This document explains the project's architecture, what's implemented in this pass,
and the concrete plan for everything left. It follows on from the original product
spec's phased MVP plan (sections 17-18 of the brief) and the later update covering
weekly-planner task/event separation and recurring events.

## 1. What this pass built (Phases 1-5, local-first)

- **Phase 1 — Foundation:** Flutter project skeleton, Riverpod wiring, full Drift
  schema, all 7 domain models, all repository interfaces + Drift implementations,
  base theme system matching `DayLayer Design.html`'s design tokens exactly.
- **Phase 2 — Desktop window:** frameless window via `window_manager`, a
  deliberately 3-state sizing model instead of free drag-resize — small
  chromeless "memo" widget, one `_ExpandButton` tap to jump to the nav-chrome
  shell (`WidgetScreen.menuBarModeSize`), then free OS-native edge-drag resize
  once the nav-chrome shell is showing (see the class doc on `WidgetScreen` in
  widget_screen.dart; two earlier approaches — a free-drag corner handle, then
  a 4-way tier-cycle button — were tried and dropped, see §2 below). Also:
  opacity slider (content-level glassmorphism, not OS-level alpha),
  always-on-top, position/size persistence, 4-tier responsive widget content
  (still used for reflow within whatever width the widget actually has, just
  no longer individually selectable via button).
- **Phase 3 — Tasks:** full CRUD, complete/uncomplete, today/overdue/completed
  views, move-to-date (used by the "quick add" flows; drag-and-drop UI itself is
  Phase 6, see below).
- **Phase 4 — Calendar:** monthly grid (6×7, adjacent-month padding, today/selected
  highlighting, up-to-3-chips-per-cell + overflow), basic event CRUD via a minimal
  quick-add dialog, tasks-with-due-dates rendered alongside events.
- **Phase 5 — Planner layout:** weekly summary sidebar (progress ring, needs
  attention, 7-day overview, event count) + a 7-column weekly grid where every day
  column strictly separates a "To-do" section from a "Schedule" section (different
  widgets, different providers, per the spec update).

Everything above talks to one local Drift/SQLite database. Firebase is not imported
anywhere in the dependency graph.

## 2. Remaining gaps (kept current — verify against code before trusting old TODOs)

This section previously listed drag-and-drop, recurrence editor UI, occurrence-level
edit/delete, Firebase sync, theme presets, holidays/lunar/solar terms, tag/category
CRUD UI, reminders, and Ctrl+K search as "not built" — **all of those are now
implemented.** That stale table (and several matching inline code comments) sat
unmaintained through multiple feature passes; if you find another comment claiming
something is "not built"/"not wired yet", verify it against the actual code before
trusting it — this file has a track record of drifting behind reality.

What's actually still not implemented, as of this pass:

| Area | Status | Notes |
|---|---|---|
| Undo/redo (general) | Delete, edit, and category/tag/theme-preset delete all have Undo. | `shared/utils/undo_actions.dart`. Still missing: undo for a single checkbox complete/uncomplete toggle (trivially reversible by clicking again, so not added) and for the recurring-event "this occurrence"/"this and following" edit scopes specifically (each mutates two rows — see `editEventWithUndo`'s doc comment for why those two are deliberately not covered). |
| Multi-select/bulk actions | Tasks: Search screen + weekly planner (all 7 day columns, one shared selection spanning the whole week). | `shared/widgets/components/bulk_action_bar.dart` (`BulkActionBar`, pulled out of SearchScreen so WeeklyPlannerScreen could reuse it). Still not present in the widget's own task list — screen real estate there (as small as 220×150) doesn't fit a selection UI. |
| CSV import | Reads a real header row (reordered/renamed/missing columns, several date/time formats, category/tag names as well as ids) in addition to round-tripping this app's own export format. | `ImportExportService.importTasksFromCsv` — see its doc comment and `_csvHeaderAliases`. Not a fully generic importer (fixed field set, no interactive column-mapping UI for wildly different schemas). |
| Notification tap → deep link | Focuses the window, navigates the planner/month grid to the item's date, then opens its edit dialog. | `RootShell._navigateToTaskDate`/`_navigateToEventDate`. For a recurring event the notification payload only carries the series id (not which occurrence fired), so this lands on the series' first occurrence date rather than the specific one — same simplification the edit dialog itself already made. |
| Recurring event reminders | Bounded per sync (20 occurrences / 60 days), but the window now re-rolls forward on its own. | `ReminderScheduler.resyncRecurringReminders`, called once on startup and every 12h thereafter by `RootShell._wireReminderResync` — so a recurring event's reminders keep renewing as long as the app gets opened at least once within the 60-day window, not just when the event itself is edited. Still not literally infinite (impossible — OS notifications need concrete future times); an event untouched *and* the app never opened for 60 straight days will eventually run dry. |
| Cross-device Firebase account merge | Implemented. Signing in/up now auto-triggers a full sync. | `data_settings_section.dart`'s `_SignInDialogState._submit` fires `syncRepositoryProvider.syncNow()` right after a successful `signIn`/`signUp`. This works safely because ids are randomly generated (collision-free in practice) and `FirebaseSyncRepository.pushLocalChanges` was hardened to check each record's remote `updatedAt` before overwriting (previously an unconditional `.set()`), matching `pullRemoteChanges`'s existing last-write-wins semantics — see the class doc comment. |
| Desktop wallpaper attachment | Tried and removed. | Implemented via Progman/WorkerW reparenting (pure-Dart `win32` FFI), shipped behind an opt-in Settings toggle explicitly flagged unverified. On real hardware, reparenting the window turned it into a child window that `show`/`focus`/tray-double-click could no longer bring forward — the window vanished with no in-app recovery path (worse than the blur feature's silent no-op failure; this one required force-quitting the process via Task Manager). Removed entirely rather than iterated on further — this environment has no Windows GUI to verify a fix actually works, and the failure mode is too destructive to ship speculatively. See §7 below. |
| Tray balloon notifications | Not implemented — turned out to be unnecessary. | `tray_manager`'s public API (checked against pub.dev docs) has no balloon/message method at all, and Windows 8+ already renders `Shell_NotifyIcon` balloon requests as toast notifications — which `flutter_local_notifications` already implements for every reminder (see `local_notification_service.dart`). Hand-writing raw `Shell_NotifyIcon` FFI calls would just be a riskier, redundant path to a notification the app already shows. |
| Firebase App Check | Not implemented — not currently possible. | `firebase_app_check` has no working Windows desktop provider as of this writing (open FlutterFire feature request, unresolved) — Android/iOS/web are the only platforms with a real attestation provider. Revisit if FlutterFire ever ships one; until then there's no way to stop something else from calling the Firebase project's public APIs with this app's client config, though Firestore access is still fully gated by `firestore.rules` regardless (uid-scoped `allow read, write`). |
| Local database encryption | Tried twice, reverted, accepted as a known gap. | Bumping to drift 2.32/sqlite3 3.x (SQLite3MultipleCiphers via build hooks) broke `build_runner` on a real machine (`'dart compile' does not support build hooks`). The classic `sqlcipher_flutter_libs` alternative was researched next but has its own well-documented Windows OpenSSL/CMake friction, and was not attempted — three native/toolchain changes in one session risking a third real-world break wasn't worth it. Plaintext on disk, protected only by normal per-user Windows filesystem permissions. See §7 below. |
| Task tag storage | Denormalized as a JSON column on `Tasks` (`tagIdsJson`) rather than a `TaskTags` join table, for MVP simplicity. | If tag-heavy features grow, add a join table and update `DriftTaskRepository`'s mapping — the domain `Task.tagIds` shape doesn't need to change. |

## 3. Layering rules (please keep these when extending)

```
presentation (screens/widgets)
      │  reads/writes via
      ▼
application (Riverpod providers, *Actions facades)
      │  depends on
      ▼
domain (repositories — interfaces only, models)
      ▲  implemented by
      │
data (Drift DAOs/repositories, Firebase stub)
      │  built on
      ▼
platform (window/tray/notifications — Windows-specific impls behind interfaces)
```

- **Widgets never import Drift, `window_manager`, or `tray_manager` directly.** They
  read/write through `app/providers.dart` → feature `application/*_providers.dart`.
- **`WidgetPreference` is device-local and must never be synced.** Its repository
  (`LocalWidgetPreferenceRepository`) is deliberately named "Local", not "Drift", to
  make this obvious at a glance, and it's excluded from `ImportExportService`'s JSON
  payload on purpose.
- **`Task` and `CalendarEvent` are never merged into one generic "item" type.** They
  use different components (`TaskRow` vs `EventCard`), different Riverpod providers
  (`weeklyTasksProvider` vs `weeklyEventsProvider`), and different color systems
  (priority vs. category). This was an explicit product requirement — don't
  "simplify" it into a shared model later without re-reading that requirement.

## 4. Recurrence design (detail)

`CalendarEvent` already carries every field a full recurrence editor needs:
`isRecurring`, `recurrenceRule` (RRULE-style string, e.g.
`FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR;UNTIL=20261231`), `recurrenceEndDate`,
`recurrenceCount`, `parentEventId`, `originalOccurrenceDate`,
`recurrenceExceptionDates`.

`features/calendar/domain/recurring_event_service.dart` implements a **subset** of
RRULE — `FREQ=DAILY|WEEKLY|MONTHLY|YEARLY` with `INTERVAL`, `BYDAY` (weekly only),
`UNTIL`, and `COUNT` (COUNT is exact, including multi-weekday `BYDAY` rules — see
`_countWeeklyMatchesUpTo`). This is deliberately a *subset*, not a
simplified/incompatible format — a smarter parser can replace `_ParsedRule.parse`
later without touching the stored strings, the database schema, or any UI.

**Fully implemented, both generation/display and editor UI:** monthly grid, weekly
planner, and "next event" everywhere correctly generate/display recurring
occurrences; `AddItemDialog` has the full Repeat/Every/On days/Ends recurrence
controls (`buildRecurrenceRule`/`describeRecurrence` for the live summary), and
editing or deleting a recurring event shows a 3-option scope modal
(`recurring_edit_scope_dialog.dart`: This event only / This and following / Entire
series) exactly as designed below:

- **This event only** → builds a new standalone detached row (same shape as
  `RecurringEventService.createDetachedOccurrence`, inlined in `AddItemDialog` so it
  can fold in the in-progress form edits) + `applyExceptionDate(parent, date)` to
  exclude it from the series.
- **This and following** → splits the series: sets the parent's `recurrenceEndDate`
  to the day before the edited date, creates a new series starting at that date with
  the edited fields.
- **Entire series** → updates the parent row directly.
- Deleting follows the same three branches (`applyExceptionDate` for "this occurrence
  only", trim `recurrenceEndDate` for "this and following", plain `delete()` — via
  the Undo-snackbar helpers in `shared/utils/undo_actions.dart` — for the series).

## 5. Drag-and-drop (implemented)

Fully wired — `TaskRow`/event chips are `Draggable`, `WeeklyDayColumn`/
`CalendarDayCell`/section widgets are `DragTarget`s (see
`features/calendar/application/event_drag_drop.dart`):

1. **Non-recurring task:** dropping calls
   `ref.read(taskActionsProvider).moveToDate(task.id, newDate)`.
2. **Non-recurring event:** dropping calls
   `ref.read(calendarEventActionsProvider).moveToDateTime(event.id, newStart)`, which
   preserves the event's original duration.
3. **Recurring event:** drop triggers the same This occurrence/This and
   following/Entire series modal from §4 rather than moving the row directly.
4. Drop-target highlight uses `AppColors.dragOverTint`, matching the month grid's
   `isSelected` visual language.

## 6. Firebase sync (implemented)

`domain/repositories/sync_repository.dart` is the contract; `data/sync/
firebase_sync_repository.dart` is the real implementation, wired into
`app/providers.dart` (`syncRepositoryProvider`) and fails soft (`SyncState.offline`/
`SyncState.error` via `watchStatus()`) if Firebase isn't configured/reachable rather
than throwing into UI code.

- Data lives under `/users/{uid}/{tasks,calendarEvents,categories,tags,themePresets,
  settings}` in Firestore — `WidgetPreference` stays local, never synced.
- Every document is just `model.toJson()`/`Model.fromJson(...)`, the same shape
  `ImportExportService` uses for JSON export/import — one source of truth for "what a
  Task looks like serialized."
- Conflict resolution is last-write-wins by `updatedAt`, compared per-record on
  *both* `pushLocalChanges` and `pullRemoteChanges` (no dirty-flag/revision tracking
  — fine for a single-user personal planner; revisit if concurrent multi-device
  editing of the *same* record becomes common).
- **Auth:** every install starts anonymous (`FirebaseAuth.signInAnonymously`, in
  `_ensureUserId`), enough to scope data without requiring an account. `data/sync/
  auth_service.dart` adds real email/password sign-up/sign-in on top — signing up
  from an anonymous session *links* the credential to the same uid (so already-synced
  data carries over). Signing into an *existing* account on a second device now
  auto-triggers `syncRepositoryProvider.syncNow()` right after success
  (`data_settings_section.dart`'s `_SignInDialogState._submit`), which is a safe
  real merge because ids are randomly generated (collision-free in practice) and
  push is last-write-wins symmetric with pull (see above). UI: Settings → Data →
  the account row above "Sync now".
- **Account deletion:** signed-in (non-anonymous) accounts get a "Delete account"
  action next to "Sign out" in the account row, opening `_DeleteAccountDialog` —
  calls `SyncRepository.deleteAllCloudData()` (wipes every Firestore doc under the
  uid, chunked at the 500-write batch cap) then `AuthService.deleteAccount()`
  (deletes the Auth account itself; translates Firebase's `requires-recent-login`
  error into a "sign out and back in first" message rather than failing silently).
  Order matters — deleting the account first would leave no uid to clean up
  Firestore data under afterward. Local, on-device data is never touched by this.
- **Password strength:** sign-*up* only (never sign-in) gates on 8+ characters
  with a mix of letters and numbers via `_SignInDialogState._passwordStrengthIssue`
  — Firebase only enforces a bare 6-character minimum server-side and never warns
  the user beforehand.
- **Security rules:** `firestore.rules` (repo root, referenced from `firebase.json`)
  restricts each `/users/{uid}/**` subtree to `request.auth.uid == uid` — covers both
  anonymous and permanent sessions since both populate `request.auth`. A brand-new
  Firestore database defaults to denying everything until rules are actually
  published (`firebase deploy --only firestore:rules`) — until then, every sync
  attempt fails with `[cloud_firestore/permission-denied] Missing or insufficient
  permissions`. That command also needs a `.firebaserc` picking an active project
  (`{"projects": {"default": "hyewon-list"}}`, now present at the repo root) — without
  it the CLI fails with "No currently active project" before it even gets to rules.
- **Not implemented — Firebase App Check:** would add anti-abuse protection against
  something else calling this project's Auth/Firestore APIs using the app's
  (necessarily public) client config, but `firebase_app_check` has no working
  Windows desktop attestation provider as of this writing (open FlutterFire feature
  request, unresolved) — Android/iOS/web are the only platforms it actually covers.
  Firestore access is still fully gated by the uid-scoped rule above regardless.
- **Local database encryption — tried, reverted, alternative being evaluated.**
  First attempt: SQLite3MultipleCiphers via `sqlite3` 3.x's build-hooks mechanism
  (drift's officially documented current approach — see
  https://drift.simonbinder.eu/platforms/encryption/), with a migration design
  for existing plaintext databases that had three safety nets (backup copy
  before touching anything, per-table row-count verification, original file
  renamed-not-deleted even after a "successful" migration) given the risk of
  touching a real user's already-populated data file with no way to run-verify
  from this environment. **This broke on the first real test**: `dart run
  build_runner build` failed with `'dart compile' does not support build hooks,
  use 'dart build' instead` — build_runner's own build-script compilation isn't
  compatible with a hooks-based package in the dependency graph yet (confirmed
  against build_runner 2.4.13 / Dart 3.10.3, July 2026). Since this would have
  broken code generation for the *entire app*, not just encryption, it was
  reverted immediately: `pubspec.yaml` back to `drift ^2.20.3`/
  `sqlite3_flutter_libs ^0.5.24`/`sqlite3 ^2.4.7`, `database.dart` back to a
  plain unencrypted `NativeDatabase`, no `flutter_secure_storage` dependency.
  The database is plaintext on disk again for now. A second candidate — the
  classic `sqlcipher_flutter_libs`-based approach (pre-0.7.0 versions, paired
  with the *existing* drift 2.20.x/sqlite3 2.x already proven to work with
  this project's build_runner setup, avoiding the build-hooks mechanism
  entirely) — was researched but **not attempted**: it has its own
  well-documented Windows build friction (SQLCipher needs a static OpenSSL
  linked in at build time, and CMake's `FindOpenSSL` frequently fails to
  locate `OPENSSL_ROOT_DIR` even after installing it — a recurring, still-open
  community issue). Given this would have been the *third* native/toolchain
  change this session attempted on the strength of documentation alone with no
  way to run-verify it here (after the wallpaper-attach feature and this
  encryption attempt both broke on first real-world contact), the decision was
  made to accept plaintext-at-rest as a known, documented limitation rather
  than risk a third build breakage chasing it. Revisit only if a
  lower-risk option appears (e.g. drift/sqlite3's build-hooks mechanism
  becoming build_runner-compatible, or a pure-Dart encryption layer that
  doesn't depend on a native SQLite fork at all). Normal per-user Windows
  filesystem permissions remain the only protection on the database file.

## 7. Windows-native TODOs

Implemented, despite the name of this section — these needed no native
`windows/runner/` C++ work because `window_manager`/`tray_manager` already expose
them at the Dart layer:

- **Click-through widget** — `WindowService.setIgnoreMouseEvents` (backed by
  `window_manager`'s `setIgnoreMouseEvents`), toggled via the global Ctrl+Alt+H
  hotkey (`GlobalHotkeyService`) or the tray menu checkbox.
- **"Start with Windows"** — `WindowsNativeService` (registry `Run` key), toggled
  from the tray menu checkbox (`WindowsTrayService`).
- **"Show in taskbar"** — `WindowService.setSkipTaskbar`, persisted on
  `WidgetPreference.showInTaskbar`, toggled from Settings → Window. Added a Drift
  migration (`schemaVersion` 2→3); **run
  `dart run build_runner build --delete-conflicting-outputs` before building** so
  `database.g.dart` picks up the new column.
- **Tray icon** — `windows/runner/resources/app_icon.ico` already exists (the
  Flutter-template default); `WindowsTrayService.init()` references it correctly.
  Swap that file for a custom hyewon_list icon whenever one is designed — no code
  change needed.
- **Global hotkeys** — Ctrl+Alt+H click-through toggle, via `hotkey_manager`
  (`GlobalHotkeyService`).
- **Tray Show/Hide** — `WindowService.hide`/`show`/`isVisible`/`focus` (backed by
  `window_manager`'s same-named methods) replaced an earlier version that tracked
  visibility with a local bool; that could drift out of sync (e.g. if the window was
  minimized via the taskbar instead of the tray, or if "Show in taskbar" was off so
  there was no taskbar entry to restore from at all). Now it always queries real OS
  state.
- **Live tray tooltip** — `TrayService.setToolTip`, kept in sync with the live
  overdue-task count by `RootShell._wireTrayTooltipListener` (watches
  `overdueTasksProvider`). A lightweight, safe stand-in for a true per-state tray
  *icon* — that would need new icon art this environment has no way to design, not
  just code.

Originally deferred, later revisited once there was little enough user data that a
riskier change was an acceptable tradeoff:

- **Tray balloon notifications** — investigated, then deliberately *not* built.
  `tray_manager`'s public API (checked against its pub.dev docs) has no
  balloon/message method at all — extending it would mean hand-writing raw
  `Shell_NotifyIcon` FFI calls against the same tray icon `tray_manager` already
  owns internally (fragile, since we'd have to guess its private `NOTIFYICONDATA`
  identity to target the same icon). More importantly, it'd be redundant: Windows
  8+ already renders `Shell_NotifyIcon` balloon requests as toast notifications,
  and `flutter_local_notifications` already shows a toast for every task/event
  reminder (see `local_notification_service.dart`). There's no distinct visible
  capability left to add here, only risk.

Tried and removed:

- **Real Mica/Acrylic blur** — briefly implemented via `flutter_acrylic`
  (`WindowService.setBlurEffect`, toggled by `RootShell` as the window crossed
  `AppBreakpoints.plannerMin`), but never actually rendered on this app's
  frameless `window_manager` window in testing, even after fixing the plugin
  init order and tint alpha. Removed entirely (dependency, interface method,
  both platform implementations, `RootShell` wiring) rather than keep dead
  code around. `_GlassFrame`'s `BackdropFilter`-based glassmorphism (see
  widget_screen.dart) remains the widget's only blur/translucency effect.
- **Desktop wallpaper attachment** — implemented via the undocumented
  `Progman`/`WorkerW` reparenting trick (pure-Dart `win32` FFI), shipped
  behind an opt-in, off-by-default Settings toggle explicitly flagged as
  unverified (this environment has no Windows GUI to run-test it against).
  On real hardware, `SetParent`-ing the window under `WorkerW` turned it
  into a child window that `WindowService.show`/`focus` (and the tray's
  double-click handler, which calls those) could no longer bring to the
  foreground — the window disappeared with **no in-app recovery path at
  all**, requiring a manual Task Manager force-quit to get back to a normal
  window. That's a strictly worse failure mode than blur's (blur just
  silently didn't render; this actively broke the app), so it was removed
  outright rather than patched — retry loops and a Progman fallback were
  drafted but never shipped, since there's no way to verify any fix here
  without real Windows hardware. `win32`/`ffi` were reverted back to
  transitive-only dependencies (see pubspec.yaml) since nothing else in the
  app uses them directly.

## 8. Reminders & notifications

`platform/notifications/local_notification_service.dart` wraps
`flutter_local_notifications` (Windows toast support). `features/reminders/domain/
reminder_scheduler.dart` computes fire times from `Task`/`CalendarEvent`'s
`reminderMinutesBefore` and (de)schedules via `NotificationService`, called by
`TaskActions`/`CalendarEventActions` after every create/update/delete/complete so a
reminder is never left pointing at stale data.

- **Recurring events:** occurrences are computed on the fly and never stored, so
  there's no way to schedule literally every future occurrence up front. Instead, up
  to 20 upcoming occurrences within a rolling 60-day window get their own
  deterministic "slot" id (`event_<id>_r<slot>`, not date-based) so a resync can
  always find and overwrite/cancel exactly the same ids even if the recurrence rule
  changed. Tasks have no recurrence concept in this app, so `syncForTask` only ever
  deals with a single fire time.
- **Tap-to-open:** `NotificationService.onTapped` emits the notification's payload
  (`task:<id>` / `event:<id>`, set by `ReminderScheduler`) when clicked.
  `main.dart` listens app-wide, focuses/shows the window, and sets
  `pendingOpenTaskIdProvider`/`pendingOpenEventIdProvider` (app/providers.dart);
  `RootShell` picks those up, fetches the item, and opens it in `AddItemDialog`'s
  edit mode — this works regardless of which screen (or chromeless widget mode) was
  showing when the notification fired, since the dialog overlays on top either way.

## 9. Calendar data (holidays / lunar / solar terms)

`AppSettings` has `showKoreanHolidays`, `showCanadaHolidays`, `showLunarCalendar`,
`showSolarTerms` — all persisted, all surfaced as toggles in
`CalendarSettingsSection`, and **all backed by real data**:

1. `HolidayService._korea`/`_canada` — fixed-Gregorian-date public holidays,
   computed algorithmically per year.
2. `HolidayService._koreaLunar` — Seollal/Chuseok (3-day each)/Buddha's Birthday,
   from a hardcoded, independently-verified (Wikipedia "Public holidays in South
   Korea") Gregorian-date table covering 2020-2040. Genuinely lunisolar, so a
   correct proleptic conversion is a large standalone algorithm — hardcoding a
   verified table for a bounded year range was judged safer than an
   unverified from-scratch lunisolar implementation. Years outside 2020-2040
   return no lunar holidays rather than a guess.
3. `SolarTermService.forYear` — the 24 solar terms (24절기), computed for *any*
   year via a real astronomical calculation (Sun's apparent geocentric ecliptic
   longitude, USNO's "Computing Approximate Solar Coordinates" low-precision
   formula), not a lookup table. Verified against known equinox/solstice dates.
4. All four flow through `monthHolidaysProvider` into `CalendarDayCell` as a
   fourth visual layer (not mixed into `EventCard`'s category-color chips) —
   solar terms render in `accentDark` to read as "seasonal marker" rather than
   "holiday", which stays `priorityHigh`.

## 10. Project structure reference

```
lib/
  main.dart                      Restores window geometry, then runs the app
  app/
    app.dart                     MaterialApp + theme
    root_shell.dart              Width-based routing: WidgetScreen vs NavRail shell
    providers.dart                Composition root: DB, DAOs, repos, platform services
    theme.dart                   ThemeData built from core/constants tokens
  core/
    constants/                   Design tokens extracted from DayLayer Design.html
    utils/                       Date helpers, ID generation
    errors/                      AppException hierarchy
  domain/
    models/                      Framework-agnostic data classes (+ toJson/fromJson)
    repositories/                Interfaces only — no Drift/Firebase imports here
  data/
    local/database/              Drift tables + @DriftDatabase class
    local/dao/                   Thin query classes returning raw Drift rows
    repositories/                Map Drift rows <-> domain models
    sync/                        Firebase stub (throws — see §6)
  platform/
    window/                      WindowService interface + Windows/Web impls
    tray/                        TrayService interface + Windows impl
    notifications/               NotificationService interface + no-op impl
  features/
    tasks/ calendar/ planner/ widget_mode/ settings/ search/ import_export/
      application/                Riverpod providers + *Actions facades
      domain/                     (calendar only) RecurringEventService
      presentation/screens|widgets
  shared/widgets/
    components/                  TaskRow, EventCard, ChipSelector, etc.
    layouts/                     NavRail
```

No `app/router.dart` was added — hyewon_list is a single window with a `currentAppScreenProvider`
enum switch rather than named routes, since there's no deep-linking requirement for a
one-window desktop app. If iOS/web ever need real navigation stacks, introduce
`go_router` at that point rather than retrofitting one now.

## 11. Data model reference

All 7 models from the spec are implemented exactly as specified (see
`domain/models/*.dart` for the authoritative field lists) — `Task`, `CalendarEvent`
(recurrence-ready), `Category`, `Tag`, `WidgetPreference`, `ThemePreset`,
`AppSettings`. Every model has `toJson`/`fromJson` for the import/export pipeline and
a `copyWith`.

## 12. Testing

A test suite exists (`test/`), covering the highest-bug-risk pure logic and
repository round-trips:

1. `test/features/calendar/recurring_event_service_test.dart` — `RecurringEventService`.
2. `test/data/repositories/task_repository_test.dart` /
   `test/data/repositories/calendar_event_repository_test.dart` — mapping round-trips
   via `AppDatabase.forTesting(NativeDatabase.memory())`.

Still not covered (add if/when touched again): `ImportExportService`/CSV round-trips
(export then import into a fresh DB, assert equality), `ReminderScheduler`'s
recurring-slot scheduling, and any of the platform services (window/tray/
notifications) — those need a real Windows environment to exercise meaningfully.
