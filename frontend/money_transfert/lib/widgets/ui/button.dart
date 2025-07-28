import 'package:flutter/material.dart';

enum ButtonVariant {
  primary,
  outline,
  ghost,
}

class CustomButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Déterminer les couleurs en fonction de la variante
    Color bgColor;
    Color txtColor;
    Color? borderClr;
    
    switch (variant) {
      case ButtonVariant.primary:
        bgColor = backgroundColor ?? theme.primaryColor;
        txtColor = textColor ?? Colors.white;
        borderClr = borderColor;
      case ButtonVariant.outline:
        bgColor = backgroundColor ?? Colors.transparent;
        txtColor = textColor ?? theme.primaryColor;
        borderClr = borderColor ?? theme.primaryColor;
      case ButtonVariant.ghost:
        bgColor = backgroundColor ?? Colors.transparent;
        txtColor = textColor ?? theme.primaryColor;
        borderClr = borderColor;
    }

    // Désactiver le bouton si nécessaire
    if (isDisabled) {
      bgColor = bgColor.withOpacity(0.5);
      txtColor = txtColor.withOpacity(0.5);
      if (borderClr != null) {
        borderClr = borderClr.withOpacity(0.5);
      }
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            side: borderClr != null 
                ? BorderSide(color: borderClr) 
                : BorderSide.none,
          ),
          elevation: variant == ButtonVariant.primary ? 0 : 0,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: bgColor,
          disabledForegroundColor: txtColor,
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(txtColor),
                  ),
                ),
              )
            : DefaultTextStyle(
                style: TextStyle(
                  color: txtColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                child: child,
              ),
      ),
    );
  }
}
