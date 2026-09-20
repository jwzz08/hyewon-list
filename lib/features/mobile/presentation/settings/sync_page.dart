import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/models/sync_status.dart';
import '../../../../domain/repositories/sync_repository.dart';
import '../mobile_common.dart';
import 'settings_widgets.dart';

/// Settings > Cloud sync: live status card, one primary "Sync now" button and
/// the one-way upload/download actions.
class MobileSyncPage extends ConsumerWidget {
  const MobileSyncPage({super.key});

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    }
  }

  String _lastSynced(DateTime t) =>
      '${AppDateUtils.formatShortDate(t)}, ${AppDateUtils.formatTimeOfDay(t.hour, t.minute)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SyncRepository sync = ref.watch(syncRepositoryProvider);
    return StreamBuilder<SyncStatus>(
      stream: sync.watchStatus(),
      initialData: SyncStatus.initial,
      builder: (context, snapshot) {
        final SyncStatus status = snapshot.data ?? SyncStatus.initial;
        final bool syncing = status.state == SyncState.syncing;
        final (IconData icon, String title, Color color) = switch (status.state) {
          SyncState.syncing => (Icons.sync_rounded, 'Syncing…', AppColors.accent),
          SyncState.error => (Icons.error_outline_rounded, 'Sync failed', AppColors.priorityHigh),
          SyncState.offline => (Icons.cloud_off_rounded, 'Not connected', AppColors.textSecondary),
          _ => (Icons.cloud_done_outlined, 'Up to date', AppColors.categoryHome),
        };
        final String? detail = status.state == SyncState.error
            ? status.errorMessage
            : (status.lastSyncedAt != null
                ? 'Last synced ${_lastSynced(status.lastSyncedAt!)}'
                : (status.state == SyncState.offline ? 'Tap Sync now to connect.' : null));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MobileCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: syncing
                        ? Padding(
                            padding: const EdgeInsets.all(15),
                            child: CircularProgressIndicator(strokeWidth: 2.6, color: color),
                          )
                        : Icon(icon, size: 26, color: color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.body(fontSize: 17, weight: FontWeight.w800)),
                        if (detail != null) ...[
                          const SizedBox(height: 3),
                          Text(detail, style: AppTextStyles.meta(fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BigButton(
              label: 'Sync now',
              icon: Icons.sync_rounded,
              busy: syncing,
              onPressed: () => _run(context, sync.syncNow),
            ),
            const SizedBox(height: 28),
            SettingsGroup(
              title: 'One-way',
              footer: 'Sync now merges both directions. Use these only if you want to '
                  'send or receive changes one way.',
              children: [
                SettingsActionRow(
                  icon: Icons.cloud_upload_outlined,
                  label: 'Upload to cloud',
                  subtitle: "Send this device's changes",
                  onTap: syncing ? null : () => _run(context, sync.pushLocalChanges),
                ),
                SettingsActionRow(
                  icon: Icons.cloud_download_outlined,
                  label: 'Download from cloud',
                  subtitle: 'Bring cloud changes to this device',
                  onTap: syncing ? null : () => _run(context, sync.pullRemoteChanges),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
