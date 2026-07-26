import 'package:flutter/widgets.dart';

/// Thin, semantically-named wrapper over [LayoutBuilder] used anywhere a
/// widget needs to pick a different child based on the *locally* available
/// space (as opposed to the whole-window size tracked in
/// widget_mode_providers.dart's `currentWindowSizeProvider`). Kept as its
/// own component per the architecture spec so call sites read clearly.
class ResizeAwareLayout extends StatelessWidget {
  const ResizeAwareLayout({super.key, required this.builder});

  final Widget Function(BuildContext context, BoxConstraints constraints) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);
}
