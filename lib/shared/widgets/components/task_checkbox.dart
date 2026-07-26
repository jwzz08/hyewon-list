import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Square, rounded checkbox matching the mockup: purple fill + white check
/// when done, light-gray outline when not.
class TaskCheckbox extends StatelessWidget {
  const TaskCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
    this.size = 18,
  });

  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isChecked ? AppColors.accent : Colors.transparent,
          border: Border.all(
            color: isChecked ? AppColors.accent : AppColors.borderMedium,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: isChecked ? Icon(Icons.check, size: size * 0.7, color: Colors.white) : null,
      ),
    );
  }
}
