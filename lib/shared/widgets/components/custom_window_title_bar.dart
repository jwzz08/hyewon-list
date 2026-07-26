import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../features/widget_mode/application/widget_mode_providers.dart';

/// Frameless-window title bar (drag-to-move region + minimize/maximize/close).
/// Only shown in the "full app" screens (planner/month/settings/search) —
/// per the design mockup, widget mode itself stays fully chromeless with
/// just a corner resize handle (see WidgetScreen).
class CustomWindowTitleBar extends ConsumerWidget {
  const CustomWindowTitleBar({super.key, this.showWindowControls = true});

  final bool showWindowControls;

  Future<void> _toggleMaximize() async {
    final bool isMaximized = await windowManager.isMaximized();
    if (isMaximized) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragToMoveArea(
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        color: Colors.transparent,
        child: Row(
          children: [
            Text('hyewon_list', style: AppTextStyles.wordmark),
            const Spacer(),
            if (showWindowControls) ...[
              _ShrinkToWidgetButton(),
              _TitleBarButton(icon: Icons.remove, onTap: windowManager.minimize),
              _TitleBarButton(icon: Icons.crop_square, onTap: _toggleMaximize),
              _TitleBarButton(
                icon: Icons.close,
                onTap: windowManager.close,
                hoverColor: AppColors.priorityHigh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reverse of WidgetScreen's `_ExpandButton`: jumps the big nav-chrome
/// window straight back down to the small chromeless widget's last size
/// (see lastWidgetSizeProvider), crossing back below AppBreakpoints.plannerMin
/// so RootShell swaps back to the chromeless WidgetScreen on the next frame.
class _ShrinkToWidgetButton extends ConsumerWidget {
  const _ShrinkToWidgetButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TitleBarButton(
      icon: Icons.close_fullscreen,
      onTap: () async {
        final Size target = ref.read(lastWidgetSizeProvider) ?? const Size(360, 480);
        await ref.read(windowServiceProvider).setSize(target);
      },
    );
  }
}

class _TitleBarButton extends StatelessWidget {
  const _TitleBarButton({required this.icon, required this.onTap, this.hoverColor});

  final IconData icon;
  final Future<void> Function() onTap;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      hoverColor: (hoverColor ?? AppColors.borderLight).withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Icon(icon, size: 15, color: AppColors.textSecondary),
      ),
    );
  }
}
