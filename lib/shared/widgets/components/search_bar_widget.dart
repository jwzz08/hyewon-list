import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../platform/platform_info.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.hintText = 'Search tasks and events…',
    this.autofocus = false,
  });

  final ValueChanged<String> onChanged;
  final String hintText;
  final bool autofocus;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.bgNeutral,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: AppColors.textFaint),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                isDense: true,
                // The app-wide input theme is filled + bordered, which draws
                // a second box inside this container. Drop it on mobile only
                // (desktop keeps its existing look).
                filled: isMobilePlatform ? false : null,
                enabledBorder: isMobilePlatform ? InputBorder.none : null,
                focusedBorder: isMobilePlatform ? InputBorder.none : null,
              ),
              style: AppTextStyles.body(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
