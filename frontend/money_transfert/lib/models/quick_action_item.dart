import 'package:flutter/material.dart';

class QuickActionItem {
  final String id;
  final String label;
  final IconData icon;
  final Color startColor;
  final Color endColor;
  final String description;

  QuickActionItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.startColor,
    required this.endColor,
    required this.description,
  });
}
