import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final Color? color;
  final Color? backgroundColor;

  const ThemeToggleButton({
    super.key,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        tooltip: isDark ? 'Light mode' : 'Dark mode',
        onPressed: () => context.read<ThemeProvider>().toggle(),
        icon: Icon(icon, color: color),
      ),
    );
  }
}
