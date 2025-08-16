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

class QuickActionsGrid extends StatelessWidget {
  final List<QuickActionItem> actions;
  final Function(String) onActionTap;

  const QuickActionsGrid({
    Key? key,
    required this.actions,
    required this.onActionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return QuickActionCard(
              action: action,
              onTap: () => onActionTap(action.id),
            );
          },
        ),
      ],
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final QuickActionItem action;
  final VoidCallback onTap;

  const QuickActionCard({
    Key? key,
    required this.action,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [action.startColor, action.endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                action.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
