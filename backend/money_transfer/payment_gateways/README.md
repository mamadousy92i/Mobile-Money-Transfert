# Application Passerelles de Paiement

## Aperçu
L'application Passerelles de Paiement fournit une intégration avec les services d'argent mobile pour le traitement des paiements dans le système de Transfert d'Argent. Elle implémente des services de passerelle de paiement simulés pour le développement et les tests, avec des interfaces qui reflètent les fournisseurs de paiement du monde réel.

## Fonctionnalités
- **Simulation de Passerelle**: Simulation réaliste du comportement des passerelles de paiement
- **Support de Multiples Passerelles**: Intégration avec divers fournisseurs de paiement
- **Traitement des Paiements**: Gestion des demandes et réponses de paiement
- **Vérification de Statut**: Vérification du statut de paiement et des détails de transaction
- **Validation de Numéro de Téléphone**: Validation des numéros de compte d'argent mobile
- **Calcul des Frais**: Calcul dynamique des frais de transaction
- **Gestion des Erreurs**: Scénarios d'erreur et réponses complets
- **Délais Simulés**: Simulation réaliste de timing pour les tests
- **Options de Configuration**: Comportement de passerelle personnalisable

## Services

### Fournisseurs de Paiement Pris en Charge

### Wave
Passerelle d'argent mobile Wave simulée avec les fonctionnalités suivantes:
- Traitement des paiements via numéro de téléphone
- Vérification du statut des transactions
- Calcul des frais basé sur le montant
- Validation de compte
- Simulation d'erreur pour tester les cas limites

### Orange Money
Passerelle Orange Money simulée avec les fonctionnalités suivantes:
- Initiation et confirmation de paiement
- Vérification de statut
- Implémentation de la structure des frais
- Validation du format de numéro de téléphone
- Délais de traitement simulés

### Service de Traitement des Paiements
Un service de niveau élevé qui :
- Gère les demandes de paiement via n'importe quelle passerelle prise en charge
- Gère le cycle de vie des paiements
- Fournit des mises à jour de statut
- Calcule les frais
- Gère les erreurs et les cas limites

## Intégration avec les Transactions
L'application Passerelles de Paiement est principalement utilisée par l'application Transactions pour traiter les paiements:

```python
from payment_gateways.services import PaymentGatewayFactory

def process_transaction_payment(transaction):
    # Obtenir la passerelle appropriée
    gateway = PaymentGatewayFactory.get_gateway(transaction.payment_method)
    
    # Traiter le paiement
    result = gateway.process_payment(
        phone=transaction.sender_phone,
        amount=transaction.amount,
        reference=transaction.reference_code
    )
    
    # Gérer le résultat
    if result['success']:
        transaction.status = 'PAID'
        transaction.payment_reference = result['payment_id']
        transaction.save()
        return True
    else:
        transaction.status = 'PAYMENT_FAILED'
        transaction.payment_error = result['error_message']
        transaction.save()
        return False
```

## Gestion des Erreurs
Les implémentations de passerelle incluent une gestion complète des erreurs pour des scénarios tels que:
- Numéros de téléphone invalides
- Fonds insuffisants
- Erreurs réseau
- Scénarios de délai d'attente
- Transactions en double

Chaque erreur renvoie un format de réponse standardisé avec:
- Code d'erreur
- Message lisible par l'homme
- Action suggérée

## Configuration
Le comportement de la passerelle peut être configuré via les paramètres:
- Taux de réussite
- Délai de traitement
- Structure des frais
- Règles de validation
- Simulation d'erreur

## Bonnes Pratiques
- Toujours valider les numéros de téléphone avant de traiter les paiements
- Gérer les erreurs de passerelle de manière élégante avec des retours d'information appropriés pour l'utilisateur
- Vérifier le statut de paiement après le traitement pour confirmer la réussite
- Calculer et afficher les frais pour les utilisateurs avant de confirmer les transactions
- Implémenter une logique de réessai pour les échecs temporaires

## Contributeurs
Développé par l'Équipe Backend de Transfert d'Argent.

## Licence
Cette application est propriétaire et confidentielle. Toute utilisation non autorisée est interdite.
