import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/components/add_item_dialog.dart';

/// Deprecated: superseded by [showAddItemDialog] (opened here with
/// `initialType: AddItemType.event`), which adds the type picker plus
/// full event detail (time range, all-day, category, recurrence) that this
/// title-only dialog never had. Kept as a thin forwarding wrapper so any
/// stray call site keeps working. See ARCHITECTURE.md "Event create/edit
/// UI" — that plan is now implemented by [AddItemDialog].
@Deprecated('Use showAddItemDialog from shared/widgets/components/add_item_dialog.dart')
Future<void> showQuickAddEventDialog(BuildContext context, WidgetRef ref, DateTime forDate) {
  return showAddItemDialog(context, initialDate: forDate, initialType: AddItemType.event);
}
