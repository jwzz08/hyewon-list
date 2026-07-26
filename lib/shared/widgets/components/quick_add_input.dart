import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

/// Free-text quick-add pill used in widget mode (glass variant) and the
/// weekly planner composer bar (solid variant).
class QuickAddInput extends StatefulWidget {
  const QuickAddInput({
    super.key,
    required this.onSubmit,
    this.hintText = 'Add a task…',
    this.glass = false,
    this.trailing,
  });

  final ValueChanged<String> onSubmit;
  final String hintText;
  final bool glass;

  /// Optional trailing widget (e.g. the weekly planner's day-picker chips +
  /// "Add" button).
  final Widget? trailing;

  @override
  State<QuickAddInput> createState() => _QuickAddInputState();
}

class _QuickAddInputState extends State<QuickAddInput> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: widget.glass ? Colors.white.withOpacity(0.55) : AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: widget.glass ? null : Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _submit,
            child: Icon(Icons.add_circle, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppTextStyles.body(fontSize: 13),
            ),
          ),
          if (widget.trailing != null) widget.trailing!,
        ],
      ),
    );
  }
}
