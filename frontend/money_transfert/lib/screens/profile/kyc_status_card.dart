import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../models/kyc_document.dart';
import '../../widgets/ui/card.dart' as ui;
import '../../widgets/ui/badge.dart' as custom_badge;
import '../../widgets/ui/button.dart' as custom_button;
import '../../widgets/ui/progress.dart';

class KycStatusCard extends StatelessWidget {
  final UserProfile user;
  final List<KycDocument> documents;

  const KycStatusCard({
    super.key,
    required this.user,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    final kycStatusInfo = _getKYCStatus(user.kycStatus);
    final kycProgress = (user.documentsSubmitted / user.documentsRequired) * 100;

    return ui.CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône de statut
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(kycStatusInfo['bgColor']),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  kycStatusInfo['icon'],
                  color: Color(kycStatusInfo['textColor']),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Informations de vérification
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vérification d\'identité',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${user.documentsSubmitted}/${user.documentsRequired} documents',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kycStatusInfo['description'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    // Barre de progression
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progression',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${kycProgress.round()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Progress(value: kycProgress),
                  ],
                ),
              ),
            ],
          ),
          
          // Liste des documents
          const SizedBox(height: 16),
          ...documents.map((doc) {
            final docStatus = _getDocumentStatus(doc.status);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(docStatus['bgColor']),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      docStatus['icon'],
                      color: Color(docStatus['textColor']),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (doc.uploadDate != null)
                          Text(
                            'Soumis le ${doc.uploadDate}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  custom_badge.Badge(
                    backgroundColor: Color(docStatus['bgColor'] as int),
                    textColor: Color(docStatus['textColor'] as int),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(docStatus['text'] as String),
                  ),
                ],
              ),
            );
          }).toList(),
          
          // Bouton d'action
          if (user.kycStatus != 'VERIFIED')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: custom_button.CustomButton(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.kycStatus == 'PENDING' 
                          ? 'Voir le statut' 
                          : 'Compléter la vérification'
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, size: 16),
                  ],
                ),
                onPressed: () {
                  // Navigation vers la page de vérification KYC
                },
              ),
            ),
        ],
      ),
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
          'description': 'Votre identité a été vérifiée avec succès',
        };
      case 'PENDING':
        return {
          'icon': Icons.access_time,
          'textColor': 0xFFEA580C, // orange-600
          'bgColor': 0xFFFFEDD5, // orange-100
          'text': 'En cours',
          'description': 'Vérification en cours, délai 24-48h',
        };
      case 'REJECTED':
        return {
          'icon': Icons.warning,
          'textColor': 0xFFDC2626, // red-600
          'bgColor': 0xFFFEE2E2, // red-100
          'text': 'Rejeté',
          'description': 'Documents non conformes, veuillez soumettre à nouveau',
        };
      default:
        return {
          'icon': Icons.shield,
          'textColor': 0xFF4B5563, // gray-600
          'bgColor': 0xFFF3F4F6, // gray-100
          'text': 'Non vérifié',
          'description': 'Commencez la vérification pour augmenter vos limites',
        };
    }
  }

  Map<String, dynamic> _getDocumentStatus(String status) {
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
          'text': 'En attente',
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
          'icon': Icons.upload_file,
          'textColor': 0xFF4B5563, // gray-600
          'bgColor': 0xFFF3F4F6, // gray-100
          'text': 'À soumettre',
        };
    }
  }
}
