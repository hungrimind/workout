import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double? size;
  final Color? color;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return IconButton(
      icon: Icon(
        icon,
        size: size,
        color: color ?? theme.colorScheme.onSurface,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
} 