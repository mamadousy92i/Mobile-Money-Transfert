import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;

  const CustomSwitch({
    super.key,
    required this.checked,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: checked,
      onChanged: onChanged,
      activeColor: activeColor ?? Theme.of(context).primaryColor,
      inactiveThumbColor: inactiveColor ?? Colors.grey.shade400,
      activeTrackColor: activeTrackColor ?? Theme.of(context).primaryColor.withOpacity(0.3),
      inactiveTrackColor: inactiveTrackColor ?? Colors.grey.shade200,
    );
  }
}
