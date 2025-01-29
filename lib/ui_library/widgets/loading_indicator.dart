import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 20,
    this.strokeWidth = 2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: color != null 
            ? AlwaysStoppedAnimation<Color>(color!)
            : null,
      ),
    );
  }
} 