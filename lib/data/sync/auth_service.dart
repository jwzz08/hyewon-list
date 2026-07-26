import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Thin wrapper around [FirebaseAuth] for turning the app's anonymous,
/// per-install Firebase identity (see FirebaseSyncRepository._ensureUserId)
/// into a real email/password account the user can sign into from a second
/// machine to pull the same data down — this is the missing piece that
/// previously made "Firebase sync" only round-trip through Firestore per
/// install rather than actually unify multiple devices under one identity.
///
/// Every method fails soft (returns a human-readable error string instead
/// of throwing) so UI code never needs its own try/catch — same convention
/// FirebaseSyncRepository already uses.
class AuthService {
  /// Emits whenever the signed-in user changes (sign in/out/link) — settings
  /// UI watches this to show either "Sign in / Sign up" or the current
  /// email + "Sign out".
  Stream<User?> get authStateChanges {
    if (Firebase.apps.isEmpty) return const Stream<User?>.empty();
    return FirebaseAuth.instance.authStateChanges();
  }

  User? get currentUser => Firebase.apps.isEmpty ? null : FirebaseAuth.instance.currentUser;

  /// True if there's no permanent account yet — either nobody's signed in,
  /// or they're on the auto-created anonymous identity used to scope
  /// offline/unauthenticated sync.
  bool get isAnonymous => currentUser?.isAnonymous ?? true;

  /// Creates a real account for [email]/[password]. If the current session
  /// is anonymous (the common case — every install starts anonymous, see
  /// FirebaseSyncRepository), this *links* the new credential to that same
  /// uid instead of creating a fresh one, so whatever was already synced
  /// under the anonymous identity carries over rather than being orphaned.
  /// Returns null on success, or an error message to show the user.
  Future<String?> signUp({required String email, required String password}) async {
    if (Firebase.apps.isEmpty) return 'Firebase isn\'t available right now.';
    try {
      final User? current = FirebaseAuth.instance.currentUser;
      if (current != null && current.isAnonymous) {
        final AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);
        await current.linkWithCredential(credential);
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Include the raw `code` alongside the message — Firebase's desktop
      // Auth plugin sometimes returns a generic "internal-error" with a
      // message like "An internal error has occurred" for what's actually a
      // project-configuration problem (most commonly: the Email/Password
      // sign-in provider not being enabled yet in Firebase Console >
      // Authentication > Sign-in method). The bare message alone isn't
      // enough to tell those apart from a real transient failure.
      return '${e.message ?? 'Sign-in failed'} (${e.code})';
    } catch (e) {
      return e.toString();
    }
  }

  /// Signs into an existing account. This method itself only changes who
  /// `FirebaseAuth.instance.currentUser` is — it doesn't touch Firestore.
  /// The caller (see data_settings_section.dart's sign-in dialog) triggers a
  /// [FirebaseSyncRepository.syncNow] immediately after a successful call,
  /// so a second device signing into an account it's never used before gets
  /// merged automatically rather than requiring a manual "Sync now" tap.
  /// That merge is safe because record ids are randomly generated (see
  /// IdGenerator), so this device's local-only records simply get added
  /// rather than colliding with anything, and FirebaseSyncRepository's
  /// last-write-wins comparison (by `updatedAt`) handles the rare case where
  /// the same id genuinely exists on both sides.
  Future<String?> signIn({required String email, required String password}) async {
    if (Firebase.apps.isEmpty) return 'Firebase isn\'t available right now.';
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      // Include the raw `code` alongside the message — Firebase's desktop
      // Auth plugin sometimes returns a generic "internal-error" with a
      // message like "An internal error has occurred" for what's actually a
      // project-configuration problem (most commonly: the Email/Password
      // sign-in provider not being enabled yet in Firebase Console >
      // Authentication > Sign-in method). The bare message alone isn't
      // enough to tell those apart from a real transient failure.
      return '${e.message ?? 'Sign-in failed'} (${e.code})';
    } catch (e) {
      return e.toString();
    }
  }

  /// Signs out back to no account at all. The next sync attempt
  /// (FirebaseSyncRepository._ensureUserId) will silently create a brand
  /// new anonymous identity, same as a fresh install — so signing out
  /// effectively disconnects this device from the account's data until
  /// someone signs in again.
  Future<void> signOut() async {
    if (Firebase.apps.isEmpty) return;
    await FirebaseAuth.instance.signOut();
  }

  /// Permanently deletes the signed-in Firebase Auth account itself —
  /// irreversible, distinct from [signOut]. This only removes the account;
  /// it does not touch that account's Firestore documents (Firebase Auth
  /// and Firestore are separate products with no cascading delete between
  /// them), so callers that want a full wipe should call
  /// [FirebaseSyncRepository.deleteAllCloudData] *first* — see
  /// data_settings_section.dart's "Delete account & cloud data" flow, which
  /// does exactly that. Once this succeeds there's no uid left to clean up
  /// under, so ordering matters.
  ///
  /// Firebase requires a "recent" sign-in for account deletion — if the
  /// session is old enough, this fails with `requires-recent-login` rather
  /// than actually deleting anything; that specific case is translated into
  /// a message asking the user to sign out/in again first, since silently
  /// failing here would be confusing (the cloud data would already be gone
  /// from the step before, but the account itself would still exist).
  Future<String?> deleteAccount() async {
    if (Firebase.apps.isEmpty) return 'Firebase isn\'t available right now.';
    try {
      final User? current = FirebaseAuth.instance.currentUser;
      if (current == null) return 'Not signed in.';
      await current.delete();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'For security, please sign out and sign back in, then try again.';
      }
      return '${e.message ?? 'Delete failed'} (${e.code})';
    } catch (e) {
      return e.toString();
    }
  }
}
