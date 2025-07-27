# Documentation de l'API Money Transfer

## Aperçu
L'API Money Transfer est un système backend complet pour la gestion des transferts d'argent mobile, construit avec Django et Django REST Framework. Elle fournit une plateforme sécurisée, évolutive et riche en fonctionnalités pour le traitement des transactions financières, la gestion des utilisateurs et les opérations commerciales liées aux transferts d'argent.

## Architecture du Système
Le système est organisé en applications modulaires, chacune responsable d'aspects spécifiques de l'écosystème de transfert d'argent :

### Applications Principales
1. **Authentication**: Gestion des utilisateurs, authentification JWT et gestion des profils
2. **KYC**: Gestion et vérification des documents Know Your Customer
3. **Transactions**: Traitement et gestion des transactions principales
4. **Reception**: Gestion de la réception d'argent et notifications
5. **Withdrawals**: Traitement des retraits d'espèces via des agents
6. **Agents**: Gestion du réseau d'agents locaux
7. **Payment Gateways**: Intégration avec les services d'argent mobile
8. **Dashboard**: Analyses commerciales et rapports
9. **Notifications**: Système de notification multi-canal

### Stack Technique
- **Framework**: Django & Django REST Framework
- **Authentification**: JWT (JSON Web Tokens) avec SimpleJWT
- **Base de données**: PostgreSQL (recommandé)
- **Format API**: RESTful JSON
- **Communication inter-applications**: Signaux Django
- **Traitement des paiements**: Passerelles de paiement simulées

## Authentification et Sécurité

### Flux d'Authentification
L'API utilise JWT (JSON Web Tokens) pour l'authentification :

1. **Inscription**: Les utilisateurs s'inscrivent avec un numéro de téléphone et un mot de passe
2. **Connexion**: Les utilisateurs reçoivent des tokens d'accès et de rafraîchissement
3. **Utilisation du Token**: Token d'accès inclus dans l'en-tête d'autorisation
4. **Rafraîchissement du Token**: Token de rafraîchissement utilisé pour obtenir de nouveaux tokens d'accès
5. **Déconnexion**: Les tokens sont mis sur liste noire lors de la déconnexion

### Points d'Accès
```
POST /api/auth/register/
POST /api/auth/login/
POST /api/auth/token/refresh/
POST /api/auth/logout/
GET /api/auth/profile/
PUT /api/auth/profile/
POST /api/auth/password/change/
```

### Fonctionnalités de Sécurité
- Vérification du numéro de téléphone
- Hachage des mots de passe
- Expiration des tokens
- Vérification KYC
- Limitation de débit
- Contrôle d'accès basé sur les permissions

## Flux de Transaction Principal

### Transfert d'Argent National
1. **Initiation**: L'expéditeur initie la transaction avec le téléphone du destinataire, le montant et la méthode de paiement
2. **Traitement du Paiement**: Le système traite le paiement via la passerelle sélectionnée
3. **Création de Transaction**: Enregistrement de transaction créé avec un code unique
4. **Création de Réception**: Enregistrement de réception créé pour le destinataire
5. **Notification**: Le destinataire est notifié des fonds disponibles
6. **Retrait**: Le destinataire retire les fonds via un agent ou de l'argent mobile

### Transfert d'Argent International
1. **Initiation**: L'expéditeur spécifie le destinataire international et le pays de destination
2. **Conversion de Devise**: Montant converti en utilisant les taux de change en temps réel
3. **Calcul des Frais**: Frais internationaux calculés en fonction du corridor
4. **Traitement**: Transaction traitée via des services de paiement internationaux
5. **Réception**: Fonds rendus disponibles dans le pays du destinataire
6. **Notification**: Le destinataire est notifié dans sa langue locale

## Points d'Accès API par Domaine

### Gestion des Utilisateurs
```
POST /api/auth/register/                # Inscrire un nouvel utilisateur
POST /api/auth/login/                   # Se connecter avec identifiants
GET /api/auth/profile/                  # Obtenir le profil utilisateur
PUT /api/auth/profile/                  # Mettre à jour le profil utilisateur
POST /api/auth/password/change/         # Changer le mot de passe
```

### Gestion KYC
```
GET /api/kyc/documents/                 # Lister les documents KYC de l'utilisateur
POST /api/kyc/documents/                # Télécharger un nouveau document KYC
GET /api/kyc/documents/{id}/            # Obtenir les détails du document
PUT /api/kyc/documents/{id}/verify/     # Vérifier le document (admin)
PUT /api/kyc/documents/{id}/reject/     # Rejeter le document (admin)
```

### Gestion des Transactions
```
GET /api/transactions/                  # Lister les transactions de l'utilisateur
POST /api/transactions/                 # Créer une nouvelle transaction
GET /api/transactions/{id}/             # Obtenir les détails de la transaction
PATCH /api/transactions/{id}/update_status/ # Mettre à jour le statut de la transaction
GET /api/transactions/statistics/       # Obtenir les statistiques de transaction
POST /api/send-money/                   # Envoi d'argent simplifié
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

### Réseau d'Agents
```
GET /api/agents/                        # Lister les agents à proximité
GET /api/agents/{id}/                   # Obtenir les détails de l'agent
```

### Gestion des Retraits
```
GET /api/mes-retraits-disponibles/      # Lister les retraits disponibles
POST /api/validate-transaction-code/    # Valider le code de retrait
POST /api/complete-transaction-withdrawal/ # Compléter le retrait
```

### Transferts Internationaux
```
GET /api/pays-disponibles/              # Lister les pays disponibles
GET /api/services-par-pays/{pays_code}/ # Services par pays
POST /api/calculer-frais-international/ # Calculer les frais internationaux
POST /api/send-money-international/     # Envoyer de l'argent à l'international
GET /api/corridors-disponibles/         # Lister les corridors de transfert
```

### Tableau de Bord et Analyses
```
GET /api/dashboard/summary/             # Obtenir le résumé du tableau de bord
GET /api/dashboard/weekly/              # Obtenir les statistiques hebdomadaires
```

## Modèles de Données

### Utilisateur
- Numéro de téléphone (identifiant principal)
- Mot de passe (haché)
- Informations de profil
- Statut KYC
- Solde du compte

### Transaction
- Identifiants uniques (UUID et ID numérique)
- Informations sur l'expéditeur et le destinataire
- Montant et devise
- Statut (en attente, accepté, envoyé, terminé, annulé)
- Méthode de paiement
- Code de transaction
- Frais
- Horodatages

### Réception
- Liaison avec la transaction
- Informations sur le destinataire
- Code de réception
- Statut
- Statut de notification
- Horodatages

### Retrait
- Liaison avec la transaction
- Informations sur l'agent et le bénéficiaire
- Code de retrait et code QR
- Montant et commission
- Statut
- Informations de vérification
- Géolocalisation
- Horodatages

### Agent
- Liaison avec l'utilisateur
- Informations commerciales
- Géolocalisation
- Statut
- Configuration financière
- Taux de commission
- Limites de transaction

### Canal de Paiement
- Type de fournisseur
- Structure des frais
- Limites de transaction
- Disponibilité par pays

## Modèles d'Intégration

### Communication Inter-applications
Le système utilise les signaux Django pour la communication entre applications :
- La création de transaction déclenche la création de réception
- Les changements de statut déclenchent des notifications
- La vérification KYC met à jour le statut de l'utilisateur

### Intégration de Services Externes
- Intégration de passerelles de paiement via la couche de service
- API de taux de change pour la conversion de devises
- Passerelle SMS pour les notifications

## Gestion des Erreurs

### Codes de Statut HTTP
- 200: Succès
- 201: Créé
- 400: Mauvaise Requête
- 401: Non Autorisé
- 403: Interdit
- 404: Non Trouvé
- 500: Erreur Serveur

### Format de Réponse d'Erreur
```json
{
  "success": false,
  "message": "Description de l'erreur",
  "errors": {
    "nom_champ": ["Détails spécifiques de l'erreur"]
  }
}
```

## Meilleures Pratiques

### Authentification
- Toujours utiliser HTTPS
- Stocker les tokens de manière sécurisée
- Rafraîchir les tokens avant expiration
- Implémenter une déconnexion appropriée

### Transactions
- Valider les numéros de téléphone des destinataires
- Calculer et afficher les frais avant confirmation
- Implémenter des requêtes idempotentes
- Gérer les erreurs de passerelle avec élégance

### Sécurité
- Vérifier l'identité avant les opérations sensibles
- Implémenter la limitation de débit
- Journaliser les événements de sécurité
- Respecter les réglementations KYC

## Tests
L'API inclut une couverture de test complète :
- Tests unitaires pour les modèles et la logique métier
- Tests d'intégration pour les points d'accès API
- Tests de passerelles de paiement simulées

## Considérations de Déploiement
- Configurer les paramètres de base de données appropriés
- Mettre en place des variables d'environnement sécurisées
- Implémenter la mise en cache pour les performances
- Configurer les paramètres CORS appropriés
- Mettre en place la surveillance et la journalisation

## Versionnement
L'API suit le versionnement sémantique :
- Changements de version majeure pour les modifications incompatibles
- Changements de version mineure pour les nouvelles fonctionnalités
- Changements de version correctifs pour les corrections de bugs

## Support et Retour d'Information
Pour le support de l'API, veuillez contacter l'équipe de développement à support@example.com.

## Licence
Cette API est propriétaire et confidentielle. Toute utilisation non autorisée est interdite.
