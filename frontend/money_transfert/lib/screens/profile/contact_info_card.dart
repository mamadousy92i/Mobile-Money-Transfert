import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../widgets/ui/card.dart' as ui;

class ContactInfoCard extends StatelessWidget {
  final UserProfile user;

  const ContactInfoCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ui.CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de contact',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Email
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 20,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 12),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Téléphone
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 20,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 12),
              Text(
                user.phoneNumber,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Localisation
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 12),
              Text(
                'Paris, France',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
