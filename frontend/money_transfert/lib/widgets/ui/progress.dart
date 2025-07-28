import 'package:flutter/material.dart';

class Progress extends StatelessWidget {
  final double value;
  final Color? backgroundColor;
  final Color? progressColor;
  final double? height;
  final BorderRadiusGeometry? borderRadius;

  const Progress({
    super.key,
    required this.value,
    this.backgroundColor,
    this.progressColor,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(4),
      child: SizedBox(
        height: height ?? 4,
        child: LinearProgressIndicator(
          value: value / 100,
          backgroundColor: backgroundColor ?? Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            progressColor ?? Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
