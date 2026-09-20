import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/sync/auth_service.dart';
import '../mobile_common.dart';
import 'settings_widgets.dart';

/// Settings > Account: who is signed in, sign in / sign out, delete account.
class MobileAccountPage extends ConsumerWidget {
  const MobileAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthService auth = ref.watch(authServiceProvider);
    return StreamBuilder<User?>(
      stream: auth.authStateChanges,
      initialData: auth.currentUser,
      builder: (context, snapshot) {
        final User? user = snapshot.data ?? auth.currentUser;
        final bool signedIn = user != null && !user.isAnonymous;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccountCard(email: signedIn ? user.email : null),
            const SizedBox(height: 16),
            if (signedIn) ...[
              BigButton(
                label: 'Sign out',
                filled: false,
                icon: Icons.logout_rounded,
                onPressed: () => auth.signOut(),
              ),
              const SizedBox(height: 28),
              SettingsGroup(
                title: 'Danger zone',
                footer: 'Permanently deletes your account and everything synced to the '
                    'cloud. Data already on this device stays.',
                children: [
                  SettingsActionRow(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete account',
                    destructive: true,
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      showDragHandle: true,
                      backgroundColor: AppColors.cardWhite,
                      builder: (_) => const _DeleteAccountSheet(),
                    ),
                  ),
                ],
              ),
            ] else
              BigButton(
                label: 'Sign in or create account',
                icon: Icons.login_rounded,
                onPressed: () => showMobileAuthSheet(context),
              ),
          ],
        );
      },
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final bool signedIn = email != null;
    return MobileCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.accentTint,
            child: signedIn
                ? Text(
                    email!.isEmpty ? '?' : email!.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.display(fontSize: 22, color: AppColors.accentTextStrong),
                  )
                : Icon(Icons.person_outline_rounded, size: 30, color: AppColors.accentTextStrong),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signedIn ? email! : 'Not signed in',
                  style: AppTextStyles.body(fontSize: 17, weight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  signedIn
                      ? 'Your data syncs across your devices.'
                      : 'Sign in to sync across devices. Until then, data is backed up '
                          'anonymously for this device only.',
                  style: AppTextStyles.meta(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showMobileAuthSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.cardWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _AuthSheet(),
  );
}

enum _AuthMode { signIn, signUp }

class _AuthSheet extends ConsumerStatefulWidget {
  const _AuthSheet();

  @override
  ConsumerState<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends ConsumerState<_AuthSheet> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  _AuthMode _mode = _AuthMode.signIn;
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Same modest gate as the desktop dialog (sign-up only): 8+ chars with a
  /// letter and a digit.
  String? _strengthIssue(String p) {
    if (p.length < 8) return 'Use at least 8 characters.';
    if (!RegExp(r'[A-Za-z]').hasMatch(p) || !RegExp(r'[0-9]').hasMatch(p)) {
      return 'Mix letters and numbers.';
    }
    return null;
  }

  Future<void> _submit() async {
    final String email = _email.text.trim();
    final String password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter an email and password.');
      return;
    }
    if (_mode == _AuthMode.signUp) {
      final String? issue = _strengthIssue(password);
      if (issue != null) {
        setState(() => _error = issue);
        return;
      }
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final AuthService auth = ref.read(authServiceProvider);
    final String? error = _mode == _AuthMode.signUp
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
    // Merge this device with the account right away (same as desktop).
    unawaited(ref.read(syncRepositoryProvider).syncNow());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool signUp = _mode == _AuthMode.signUp;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedTabs<_AuthMode>(
              options: const {
                _AuthMode.signIn: 'Sign in',
                _AuthMode.signUp: 'Create account',
              },
              value: _mode,
              onChanged: (m) => setState(() {
                _mode = m;
                _error = null;
              }),
            ),
            const SizedBox(height: 20),
            Text(
              signUp ? 'Create your account' : 'Welcome back',
              style: AppTextStyles.display(fontSize: 24),
            ),
            const SizedBox(height: 6),
            Text(
              signUp
                  ? 'Lets you sync this data to your other devices.'
                  : 'Pulls your synced data down to this device.',
              style: AppTextStyles.meta(fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              style: AppTextStyles.body(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Email',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              autofillHints: [signUp ? AutofillHints.newPassword : AutofillHints.password],
              style: AppTextStyles.body(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Password',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            if (signUp) ...[
              const SizedBox(height: 8),
              Text(
                'At least 8 characters, with letters and numbers.',
                style: AppTextStyles.meta(fontSize: 13),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.priorityHighTint,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Text(
                  _error!,
                  style: AppTextStyles.body(fontSize: 13.5, color: AppColors.priorityHighText),
                ),
              ),
            ],
            const SizedBox(height: 22),
            BigButton(
              label: signUp ? 'Create account' : 'Sign in',
              busy: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountSheet extends ConsumerStatefulWidget {
  const _DeleteAccountSheet();

  @override
  ConsumerState<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends ConsumerState<_DeleteAccountSheet> {
  bool _busy = false;
  String? _error;

  /// Cloud data first, then the account itself — same order and same calls as
  /// the desktop dialog (see AuthService.deleteAccount).
  Future<void> _delete() async {
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delete account?', style: AppTextStyles.display(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            "This permanently deletes your account and everything you've synced to the "
            "cloud. Tasks and events already on this device aren't affected, but nothing "
            'will sync afterward. This cannot be undone.',
            style: AppTextStyles.meta(fontSize: 14),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: AppTextStyles.body(fontSize: 13.5, color: AppColors.priorityHighText)),
          ],
          const SizedBox(height: 22),
          BigButton(label: 'Delete permanently', destructive: true, busy: _busy, onPressed: _delete),
          const SizedBox(height: 10),
          BigButton(
            label: 'Cancel',
            filled: false,
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
