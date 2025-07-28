import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final String? className;

  const Badge({
    super.key,
    required this.child,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.className,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: textColor ?? Theme.of(context).primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        child: child,
      ),
    );
  }
}
