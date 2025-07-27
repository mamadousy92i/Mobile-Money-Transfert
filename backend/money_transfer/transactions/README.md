# Application Transactions

## Aperçu
L'application Transactions est le composant central du système de Transfert d'Argent, gérant tous les aspects des opérations de transfert d'argent. Elle gère la création, le traitement et le suivi des transactions financières entre utilisateurs, y compris les transferts nationaux et internationaux.

## Fonctionnalités
- **Traitement des Transactions**: Gestion de bout en bout des transferts d'argent
- **Types de Transactions Multiples**: Support pour divers scénarios de transaction
- **Intégration des Passerelles de Paiement**: Traitement des paiements via des services d'argent mobile
- **Gestion des Bénéficiaires**: Stockage et gestion des informations des destinataires
- **Calcul des Frais**: Calcul dynamique des frais de transaction
- **Suivi de Statut**: Surveillance en temps réel du statut des transactions
- **Transferts Internationaux**: Support de transfert d'argent transfrontalier
- **Historique des Transactions**: Tenue de registres complète de toutes les transactions
- **Fonctionnalités de Sécurité**: Mesures de vérification et de prévention des fraudes

## Modèles de Données

### Transaction
Le modèle central représentant un transfert d'argent:
- Identifiants uniques (UUID et code de transaction)
- Informations sur l'expéditeur et le destinataire
- Montant et devise
- Type et statut de transaction
- Détails de la méthode de paiement
- Informations sur les frais
- Horodatages pour suivre le cycle de vie de la transaction
- Données de sécurité et de vérification

### CanalPaiement
Représente les méthodes de paiement disponibles:
- Informations sur le fournisseur (Wave, Orange Money, etc.)
- Structure des frais
- Statut de disponibilité
- Disponibilité par pays
- Paramètres de configuration

### Beneficiaire
Stocke les informations des destinataires pour les transactions répétées:
- Liaison avec l'utilisateur
- Détails du destinataire (nom, téléphone, etc.)
- Informations sur la relation
- Historique des transactions

### Modèles de Transfert International
Modèles spécialisés pour les transferts internationaux:
- Données de conversion de devise
- Structures de frais internationaux
- Règles spécifiques aux corridors
- Informations de conformité

## Points d'Accès API

### Gestion des Transactions
```
GET /api/transactions/                  # Lister les transactions de l'utilisateur
POST /api/transactions/                 # Créer une nouvelle transaction
GET /api/transactions/{id}/             # Obtenir les détails de la transaction
PATCH /api/transactions/{id}/update_status/ # Mettre à jour le statut de la transaction
```

### Envoi d'Argent Simplifié
```
POST /api/send-money/                   # Création de transaction simplifiée
GET /api/transaction-by-code/{code}/    # Obtenir la transaction par code
GET /api/transaction-status/{code}/     # Vérifier le statut de la transaction
```

### Gestion des Bénéficiaires
```
GET /api/beneficiaires/                 # Lister les bénéficiaires de l'utilisateur
POST /api/beneficiaires/                # Ajouter un nouveau bénéficiaire
GET /api/beneficiaires/{id}/            # Obtenir les détails du bénéficiaire
PUT /api/beneficiaires/{id}/            # Mettre à jour le bénéficiaire
DELETE /api/beneficiaires/{id}/         # Supprimer le bénéficiaire
```

### Méthodes de Paiement
```
GET /api/canaux-paiement/               # Lister les méthodes de paiement
GET /api/canaux-paiement/by_country/    # Méthodes de paiement par pays
GET /api/canaux-paiement/gateway_status/ # Vérifier le statut de la passerelle
```

### Transferts Internationaux
```
GET /api/pays-disponibles/              # Lister les pays disponibles
GET /api/services-par-pays/{pays_code}/ # Services par pays
POST /api/calculer-frais-international/ # Calculer les frais internationaux
POST /api/send-money-international/     # Envoyer de l'argent à l'international
```

### Statistiques de Transaction
```
GET /api/transactions/statistics/       # Obtenir les statistiques de transaction
```

## Intégration avec d'autres Applications
L'application Transactions s'intègre avec:
- **Authentification**: Pour l'identification et la vérification des utilisateurs
- **Passerelles de Paiement**: Pour le traitement des paiements via des services d'argent mobile
- **Réception**: Pour la gestion de la réception de l'argent envoyé
- **Retraits**: Pour la gestion des retraits d'argent
- **Agents**: Pour les transactions assistées par des agents
- **Notifications**: Pour l'envoi d'alertes de transaction
- **Tableau de Bord**: Pour la présentation des métriques de transaction

## Logique Métier

### Création de Transaction
1. L'utilisateur initie une transaction avec les détails du destinataire et le montant
2. Le système valide la demande et calcule les frais
3. L'utilisateur confirme et sélectionne la méthode de paiement
4. Le paiement est traité via la passerelle sélectionnée
5. L'enregistrement de transaction est créé avec un code unique
6. L'enregistrement de réception est créé pour le destinataire
7. Des notifications sont envoyées aux deux parties

### Cycle de Vie du Statut de Transaction
- **INITIÉE**: La transaction a été créée mais pas encore traitée
- **EN TRAITEMENT**: Le paiement est en cours de traitement
- **PAYÉE**: Le paiement a été confirmé
- **ENVOYÉE**: La transaction a été envoyée au destinataire
- **TERMINÉE**: Le destinataire a collecté les fonds
- **ANNULÉE**: La transaction a été annulée
- **ÉCHOUÉE**: Le traitement de la transaction a échoué

### Calcul des Frais
Les frais sont calculés en fonction de:
- Montant de la transaction
- Méthode de paiement
- Emplacement du destinataire (national vs international)
- Niveau/statut de fidélité de l'utilisateur
- Remises promotionnelles

### Transferts Internationaux
1. L'utilisateur sélectionne un destinataire international et le pays de destination
2. Le système récupère les taux de change actuels
3. Les frais sont calculés en fonction du corridor international
4. L'utilisateur confirme le taux de change et les frais
5. La transaction est traitée avec des vérifications de conformité supplémentaires
6. Les fonds sont rendus disponibles dans le pays du destinataire

## Meilleures Pratiques
- Toujours valider les numéros de téléphone des destinataires avant d'envoyer de l'argent
- Calculer et afficher les frais aux utilisateurs avant de confirmer les transactions
- Mettre en œuvre une gestion appropriée des erreurs pour les transactions échouées
- Maintenir un registre d'audit de tous les changements de statut de transaction
- Utiliser des codes de transaction pour la vérification sécurisée

## Contributeurs
- Équipe de Développement
- Équipe des Opérations Financières

## Licence
Ce module fait partie de l'application Transfert d'Argent et est soumis aux mêmes conditions de licence.
