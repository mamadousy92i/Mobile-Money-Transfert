import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../widgets/ui/card.dart' as ui;

class UserStatsCards extends StatelessWidget {
  final UserProfile user;

  const UserStatsCards({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Carte des transactions
        Expanded(
          child: ui.CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  user.totalTransactions.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Client fidèle',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Carte du montant total envoyé
        Expanded(
          child: ui.CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  user.totalSent,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total envoyé',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Depuis ${user.memberSince}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
