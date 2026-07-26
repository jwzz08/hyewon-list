import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/components/add_item_dialog.dart';

/// Deprecated: superseded by [showAddItemDialog], which lets the user pick
/// To-do vs Schedule and fill in full detail (due time, priority, category,
/// event time range, recurrence) instead of a task-only title field. Kept
/// as a thin forwarding wrapper so any stray call site keeps working.
@Deprecated('Use showAddItemDialog from shared/widgets/components/add_item_dialog.dart')
Future<void> showQuickAddDialog(BuildContext context, WidgetRef ref) {
  return showAddItemDialog(context, initialDate: DateTime.now());
}
