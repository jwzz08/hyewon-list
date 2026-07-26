import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

/// Which instances of a recurring series an edit/delete/move should apply
/// to — the standard "this event / this and following / entire series"
/// choice every calendar app asks before touching a recurring item. See
/// ARCHITECTURE.md "Recurring event edit/delete scopes".
enum EditScope { thisOccurrence, thisAndFollowing, entireSeries }

/// Shows the scope picker and resolves to the chosen [EditScope], or `null`
/// if the user dismissed the dialog (callers should treat `null` as
/// "cancel the whole edit/delete/move", not as any particular scope).
Future<EditScope?> showEditScopeDialog(
  BuildContext context, {
  required String actionLabel,
}) {
  return showDialog<EditScope>(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This is a recurring event', style: AppTextStyles.display(fontSize: 16)),
            const SizedBox(height: 4),
            Text('$actionLabel for:', style: AppTextStyles.meta()),
            const SizedBox(height: 12),
            _ScopeOption(
              label: 'This event only',
              onTap: () => Navigator.of(dialogContext).pop(EditScope.thisOccurrence),
            ),
            _ScopeOption(
              label: 'This and following events',
              onTap: () => Navigator.of(dialogContext).pop(EditScope.thisAndFollowing),
            ),
            _ScopeOption(
              label: 'All events in the series',
              onTap: () => Navigator.of(dialogContext).pop(EditScope.entireSeries),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ScopeOption extends StatelessWidget {
  const _ScopeOption({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(label, style: AppTextStyles.body(fontSize: 13)),
      ),
    );
  }
}
