import 'package:flutter/material.dart';
import '../../models/beneficiary.dart';
import '../../widgets/ui/card.dart' as ui;
import '../../widgets/ui/button.dart';

class BeneficiariesCard extends StatelessWidget {
  final List<Beneficiary> beneficiaries;

  const BeneficiariesCard({
    super.key,
    required this.beneficiaries,
  });

  @override
  Widget build(BuildContext context) {
    return ui.CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bénéficiaires récents',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigation vers la page de gestion des bénéficiaires
                },
                icon: const Text('Gérer'),
                label: const Icon(Icons.chevron_right, size: 16),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Liste des bénéficiaires
          ...beneficiaries.map((beneficiary) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                // Avatar avec drapeau
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      beneficiary.flag,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Informations du bénéficiaire
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            beneficiary.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (beneficiary.favorite) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber.shade500,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        beneficiary.country,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Date du dernier transfert
                Text(
                  beneficiary.lastUsed,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          )).toList(),
          
          // Bouton pour voir tous les bénéficiaires
          if (beneficiaries.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: CustomButton(
                variant: ButtonVariant.outline,
                width: double.infinity,
                child: const Text('Voir tous les bénéficiaires'),
                onPressed: () {
                  // Navigation vers la page de tous les bénéficiaires
                },
              ),
            ),
        ],
      ),
    );
  }
}
