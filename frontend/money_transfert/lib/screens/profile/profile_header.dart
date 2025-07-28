import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../widgets/ui/badge.dart' as custom_badge;


class ProfileHeader extends StatelessWidget {
  final UserProfile user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final kycStatusInfo = _getKYCStatus(user.kycStatus);

    return Column(
      children: [
        // Avatar avec badge
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.initials.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.green.shade500,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Nom et email
        Text(
          user.fullName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Badges
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            custom_badge.Badge(
              backgroundColor: Color(kycStatusInfo['bgColor'] as int),
              textColor: Color(kycStatusInfo['textColor'] as int),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    kycStatusInfo['icon'] as IconData,
                    size: 12,
                    color: Color(kycStatusInfo['textColor'] as int),
                  ),
                  const SizedBox(width: 4),
                  Text(kycStatusInfo['text'] as String),
                ],
              ),
            ),
            const SizedBox(width: 8),
            custom_badge.Badge(
              backgroundColor: Colors.blue.shade50,
              textColor: Colors.blue.shade800,
              child: Text('Niveau ${user.verificationLevel}'),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, dynamic> _getKYCStatus(String status) {
    switch (status) {
      case 'VERIFIED':
        return {
          'icon': Icons.check_circle,
          'textColor': 0xFF16A34A, // green-600
          'bgColor': 0xFFDCFCE7, // green-100
          'text': 'Vérifié',
        };
      case 'PENDING':
        return {
          'icon': Icons.access_time,
          'textColor': 0xFFEA580C, // orange-600
          'bgColor': 0xFFFFEDD5, // orange-100
          'text': 'En cours',
        };
      case 'REJECTED':
        return {
          'icon': Icons.warning,
          'textColor': 0xFFDC2626, // red-600
          'bgColor': 0xFFFEE2E2, // red-100
          'text': 'Rejeté',
        };
      default:
        return {
          'icon': Icons.shield,
          'textColor': 0xFF4B5563, // gray-600
          'bgColor': 0xFFF3F4F6, // gray-100
          'text': 'Non vérifié',
        };
    }
  }
}
