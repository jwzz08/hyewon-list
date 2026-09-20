import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../import_export/application/import_export_service.dart';
import 'settings_widgets.dart';

/// Shared body for the Backup (JSON) and Tasks (CSV) pages: two big tappable
/// rows (export / import) that show a spinner while running and report the
/// outcome in a snackbar.
class _ImportExportPage extends ConsumerStatefulWidget {
  const _ImportExportPage({
    required this.description,
    required this.exportLabel,
    required this.exportSubtitle,
    required this.importLabel,
    required this.importSubtitle,
    required this.onExport,
    required this.onImport,
  });

  final String description;
  final String exportLabel;
  final String exportSubtitle;
  final String importLabel;
  final String importSubtitle;
  final Future<String?> Function(ImportExportService) onExport;
  final Future<String> Function(ImportExportService) onImport;

  @override
  ConsumerState<_ImportExportPage> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends ConsumerState<_ImportExportPage> {
  bool _busy = false;

  Future<void> _run(Future<String?> Function() action) async {
    setState(() => _busy = true);
    try {
      final String? message = await action();
      if (message != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
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
    return SettingsGroup(
      footer: widget.description,
      children: [
        SettingsActionRow(
          icon: Icons.ios_share_rounded,
          label: widget.exportLabel,
          subtitle: widget.exportSubtitle,
          busy: _busy,
          onTap: () => _run(() async {
            final String? path = await widget.onExport(service);
            return path == null ? null : 'Saved to Files';
          }),
        ),
        SettingsActionRow(
          icon: Icons.file_download_outlined,
          label: widget.importLabel,
          subtitle: widget.importSubtitle,
          busy: _busy,
          onTap: () => _run(() => widget.onImport(service)),
        ),
      ],
    );
  }
}

class MobileBackupPage extends StatelessWidget {
  const MobileBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ImportExportPage(
      description: 'A backup includes tasks, events, categories, tags, theme presets and '
          'settings. Importing merges by ID, so nothing is duplicated.',
      exportLabel: 'Export backup',
      exportSubtitle: 'Save everything as a JSON file',
      importLabel: 'Import backup',
      importSubtitle: 'Restore from a JSON file',
      onExport: (s) => s.exportAllToJsonFile(),
      onImport: (s) async => 'Imported ${await s.importFromJsonFile()} records',
    );
  }
}

class MobileCsvPage extends StatelessWidget {
  const MobileCsvPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ImportExportPage(
      description: 'Tasks only. Handy for spreadsheets — CSV files from other apps '
          'work too if the columns are recognizable.',
      exportLabel: 'Export tasks',
      exportSubtitle: 'Save tasks as a CSV file',
      importLabel: 'Import tasks',
      importSubtitle: 'Add tasks from a CSV file',
      onExport: (s) => s.exportTasksToCsvFile(),
      onImport: (s) async => 'Imported ${await s.importTasksFromCsvFile()} tasks',
    );
  }
}
