import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../mobile_common.dart';

/// Small caps section label + grouped card of rows (iOS "inset grouped" look).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, this.footer, required this.children});

  final String? title;
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) MobileSectionLabel(title!),
          SizedBox(
            width: double.infinity,
            child: MobileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(height: 1, indent: 16, color: AppColors.borderLight),
                  children[i],
                ],
              ],
            ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
              child: Text(footer!, style: AppTextStyles.meta(fontSize: 12.5)),
            ),
        ],
      ),
    );
  }
}

/// Label (+ optional subtitle) with a switch on the right; whole row taps.
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.body(fontSize: 15.5, weight: FontWeight.w700)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: AppTextStyles.meta(fontSize: 12.5)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tappable row with a leading icon, title, subtitle and trailing chevron
/// (or spinner while [busy]).
class SettingsActionRow extends StatelessWidget {
  const SettingsActionRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.busy = false,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool busy;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final Color tone = destructive ? AppColors.priorityHigh : AppColors.accentTextStrong;
    return InkWell(
      onTap: busy ? null : onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: destructive ? AppColors.priorityHighTint : AppColors.accentTint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: tone),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.body(
                        fontSize: 15.5,
                        weight: FontWeight.w700,
                        color: destructive ? AppColors.priorityHigh : null,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: AppTextStyles.meta(fontSize: 12.5)),
                    ],
                  ],
                ),
              ),
              if (busy)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                )
              else
                Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-width, 52pt-tall button. Filled by default, outlined when [filled]
/// is false.
class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
    this.busy = false,
    this.destructive = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final bool busy;
  final bool destructive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color color = destructive ? AppColors.priorityHigh : AppColors.accent;
    final Widget child = busy
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: filled ? Colors.white : color,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label, style: AppTextStyles.body(fontSize: 16, weight: FontWeight.w800, color: filled ? Colors.white : color)),
            ],
          );
    final ButtonStyle style = filled
        ? ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withOpacity(0.5)),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
          );
    return SizedBox(
      width: double.infinity,
      child: filled
          ? ElevatedButton(onPressed: busy ? null : onPressed, style: style, child: child)
          : OutlinedButton(onPressed: busy ? null : onPressed, style: style, child: child),
    );
  }
}

/// iOS-style sliding segmented control with a full-width, 40pt-tall track.
class SegmentedTabs<T extends Object> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<T>(
        groupValue: value,
        backgroundColor: AppColors.borderLight.withOpacity(0.6),
        thumbColor: AppColors.cardWhite,
        padding: const EdgeInsets.all(3),
        onValueChanged: (v) {
          if (v != null) onChanged(v);
        },
        children: {
          for (final MapEntry<T, String> e in options.entries)
            e.key: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                e.value,
                style: AppTextStyles.body(
                  fontSize: 14.5,
                  weight: e.key == value ? FontWeight.w800 : FontWeight.w700,
                  color: e.key == value ? AppColors.accentTextStrong : AppColors.textSecondary,
                ),
              ),
            ),
        },
      ),
    );
  }
}
