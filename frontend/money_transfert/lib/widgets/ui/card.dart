import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? width;
  final double? height;
  final Clip clipBehavior;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.boxShadow,
    this.border,
    this.width,
    this.height,
    this.clipBehavior = Clip.none,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: border,
      ),
      clipBehavior: clipBehavior,
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}
