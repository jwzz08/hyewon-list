import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/sync/auth_service.dart';
import '../../../../domain/models/sync_status.dart';
import '../../../../domain/repositories/sync_repository.dart';
import '../../../../shared/widgets/components/settings_section.dart';
import '../../../import_export/application/import_export_service.dart';

class DataSettingsSection extends ConsumerStatefulWidget {
  const DataSettingsSection({super.key});

  @override
  ConsumerState<DataSettingsSection> createState() => _DataSettingsSectionState();
}

class _DataSettingsSectionState extends ConsumerState<DataSettingsSection> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImportExportService service = ref.watch(importExportServiceProvider);

    return SettingsSection(
      title: 'DATA',
      subtitle:
          'Export/import tasks, events, categories and settings as JSON. Window position/size never leaves this device.',
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        final String? path = await service.exportAllToJsonFile();
                        if (path != null && mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Exported to $path')));
                        }
                      }),
              icon: const Icon(Icons.upload_file, size: 16),
              label: const Text('Export JSON'),
            ),
            OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        final int count = await service.importFromJsonFile();
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Imported $count records')));
                        }
                      }),
              icon: const Icon(Icons.download_outlined, size: 16),
              label: const Text('Import JSON'),
            ),
            OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        final String? path = await service.exportTasksToCsvFile();
                        if (path != null && mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Exported to $path')));
                        }
                      }),
              icon: const Icon(Icons.table_chart_outlined, size: 16),
              label: const Text('Export tasks as CSV'),
            ),
            OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        final int count = await service.importTasksFromCsvFile();
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Imported $count tasks')));
                        }
                      }),
              icon: const Icon(Icons.table_rows_outlined, size: 16),
              label: const Text('Import tasks from CSV'),
            ),
          ],
        ),
        if (_busy) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(),
        ],
        const SizedBox(height: 14),
        const _AccountRow(),
        const SizedBox(height: 10),
        const _SyncRow(),
      ],
    );
  }
}

/// Shows the current Firebase account (or lack of one) and lets the user
/// turn the per-install anonymous identity [_SyncRow] syncs through into a
/// real account — see data/sync/auth_service.dart for what "sign in" here
/// actually does under the hood, and [_DeleteAccountDialog] for permanently
/// erasing it again.
class _AccountRow extends ConsumerWidget {
  const _AccountRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthService auth = ref.watch(authServiceProvider);
    return StreamBuilder<User?>(
      stream: auth.authStateChanges,
      initialData: auth.currentUser,
      builder: (context, snapshot) {
        final User? user = snapshot.data ?? auth.currentUser;
        final bool signedIn = user != null && !user.isAnonymous;
        return Row(
          children: [
            Icon(
              signedIn ? Icons.account_circle : Icons.account_circle_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                signedIn
                    ? (user.email ?? 'Signed in')
                    : 'Not signed in — syncing anonymously (this device only).',
                style: AppTextStyles.meta(fontSize: 10.5),
              ),
            ),
            if (signedIn) ...[
              OutlinedButton(
                onPressed: () => auth.signOut(),
                child: const Text('Sign out'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const _DeleteAccountDialog(),
                ),
                style: TextButton.styleFrom(foregroundColor: AppColors.priorityHigh),
                child: const Text('Delete account'),
              ),
            ] else
              OutlinedButton(
                onPressed: () =>
                    showDialog<void>(context: context, builder: (_) => const _SignInDialog()),
                child: const Text('Sign in / Sign up'),
              ),
          ],
        );
      },
    );
  }
}

/// Confirms, then permanently deletes both the Firestore data under this
/// account's uid and the Firebase Auth account itself. Deliberately in that
/// order — see AuthService.deleteAccount's doc comment for why deleting the
/// account first would leave no uid to clean up cloud data under
/// afterward. Local, on-device data is never touched by this dialog.
class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  bool _busy = false;
  String? _error;

  Future<void> _confirmDelete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(syncRepositoryProvider).deleteAllCloudData();
      final String? error = await ref.read(authServiceProvider).deleteAccount();
      if (!mounted) return;
      if (error != null) {
        setState(() {
          _busy = false;
          _error = error;
        });
        return;
      }
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delete account & cloud data', style: AppTextStyles.display(fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                "Permanently deletes your account and everything you've "
                "synced to Firebase. Tasks/events already on this device "
                "aren't affected, but nothing more will sync anywhere "
                'afterward. This cannot be undone.',
                style: AppTextStyles.meta(fontSize: 10.5),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: AppTextStyles.meta(fontSize: 10.5, color: AppColors.priorityHigh),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _busy ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.priorityHigh),
                    onPressed: _busy ? null : _confirmDelete,
                    child: _busy
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Delete permanently'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInDialog extends ConsumerStatefulWidget {
  const _SignInDialog();

  @override
  ConsumerState<_SignInDialog> createState() => _SignInDialogState();
}

class _SignInDialogState extends ConsumerState<_SignInDialog> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _isSignUp = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Client-side password strength gate, sign-up only — Firebase enforces a
  /// bare minimum of 6 characters server-side regardless, but never warns
  /// the user *before* they've committed to a weak one. Deliberately modest
  /// (length + a letter + a digit) rather than a full complexity policy —
  /// this is a personal planner app, not a bank, so the goal is nudging
  /// away from trivially-guessable passwords, not adding friction. Never
  /// applied on sign-*in* — an existing account's password strength isn't
  /// this dialog's business to second-guess.
  String? _passwordStrengthIssue(String password) {
    if (password.length < 8) return 'Use at least 8 characters.';
    final bool hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final bool hasDigit = RegExp(r'[0-9]').hasMatch(password);
    if (!hasLetter || !hasDigit) return 'Mix letters and numbers.';
    return null;
  }

  Future<void> _submit() async {
    final String email = _emailCtrl.text.trim();
    final String password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter an email and password.');
      return;
    }
    if (_isSignUp) {
      final String? strengthIssue = _passwordStrengthIssue(password);
      if (strengthIssue != null) {
        setState(() => _error = strengthIssue);
        return;
      }
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final AuthService auth = ref.read(authServiceProvider);
    final String? error = _isSignUp
        ? await auth.signUp(email: email, password: password)
        : await auth.signIn(email: email, password: password);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return;
    }
    // Merge this device's data with the account's the moment sign-in
    // succeeds, rather than waiting for the user to separately find "Sync
    // now" below — this is what actually makes signing into an existing
    // account from a second device work like a merge. Fire-and-forget: the
    // dialog doesn't need to block on it, and _SyncRow's own StreamBuilder
    // already shows live progress/errors for whoever's watching Settings.
    unawaited(ref.read(syncRepositoryProvider).syncNow());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isSignUp ? 'Create account' : 'Sign in',
                  style: AppTextStyles.display(fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                _isSignUp
                    ? 'Lets you sync this data to other devices later.'
                    : 'Pulls your synced data down to this device.',
                style: AppTextStyles.meta(fontSize: 10.5),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _emailCtrl,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password'),
                onSubmitted: (_) => _submit(),
              ),
              if (_isSignUp) ...[
                const SizedBox(height: 4),
                Text(
                  'At least 8 characters, with letters and numbers.',
                  style: AppTextStyles.meta(fontSize: 10),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: AppTextStyles.meta(fontSize: 10.5, color: AppColors.priorityHigh)),
              ],
              const SizedBox(height: 8),
              // Its own row (rather than sharing one with Cancel/Submit) —
              // at the dialog's 340px max width, "Have an account? Sign in"
              // alongside both buttons overflowed the row by ~43px.
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _busy ? null : () => setState(() => _isSignUp = !_isSignUp),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: Text(
                    _isSignUp ? 'Have an account? Sign in' : 'New here? Create account',
                    style: AppTextStyles.meta(fontSize: 10.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _busy ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isSignUp ? 'Create account' : 'Sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncRow extends ConsumerWidget {
  const _SyncRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SyncRepository sync = ref.watch(syncRepositoryProvider);
    return StreamBuilder<SyncStatus>(
      stream: sync.watchStatus(),
      builder: (context, snapshot) {
        final SyncStatus status = snapshot.data ?? SyncStatus.initial;
        final bool syncing = status.state == SyncState.syncing;
        return Row(
          children: [
            OutlinedButton.icon(
              onPressed: syncing
                  ? null
                  : () async {
                      try {
                        await sync.syncNow();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Sync failed: $e')));
                        }
                      }
                    },
              icon: syncing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_sync_outlined, size: 16),
              label: Text(syncing ? 'Syncing…' : 'Sync now'),
            ),
            const SizedBox(width: 10),
            Text(
              _statusLabel(status),
              style: AppTextStyles.meta(
                fontSize: 10.5,
                color: status.state == SyncState.error ? AppColors.priorityHigh : AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  String _statusLabel(SyncStatus status) {
    switch (status.state) {
      case SyncState.offline:
        return 'Firebase sync: not signed in / offline.';
      case SyncState.syncing:
        return 'Syncing with Firebase…';
      case SyncState.success:
        return status.lastSyncedAt == null
            ? 'Synced.'
            : 'Last synced ${status.lastSyncedAt!.toLocal()}';
      case SyncState.error:
        return 'Sync error: ${status.errorMessage ?? 'unknown'}';
      case SyncState.idle:
        return 'Firebase sync ready.';
    }
  }
}
