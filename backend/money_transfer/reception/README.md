# Application Réception

## Aperçu
L'application Réception gère le processus de réception d'argent dans le système de Transfert d'Argent. Elle gère le cycle de vie de la réception d'argent depuis la notification au destinataire jusqu'à la confirmation, la finalisation et l'annulation potentielle. Elle sert de passerelle entre le système de transaction et le destinataire qui reçoit les fonds.

## Fonctionnalités
- **Gestion du Cycle de Vie de Réception**: Gestion complète du processus de réception
- **Intégration des Notifications**: Notifications automatiques aux destinataires
- **Suivi de Statut**: Suivi en temps réel du statut de réception
- **Génération de Code**: Création et validation sécurisées de code de réception
- **Gestion de l'Expiration**: Gestion des transferts non réclamés
- **Traitement des Annulations**: Gestion des réceptions annulées
- **Liaison avec les Transactions**: Intégration avec le système de transaction principal

## Modèles de Données

### Réception
Représente une instance de réception d'argent :
- Lien vers la transaction d'origine
- Informations sur le destinataire (téléphone, nom)
- Code de réception pour vérification
- Statut (en attente, notifié, confirmé, terminé, annulé, expiré)
- Statut de notification et historique
- Horodatages pour chaque étape du processus
- Date d'expiration
- Détails de finalisation

Le modèle inclut des méthodes pour :
- Générer des codes de réception sécurisés
- Envoyer des notifications aux destinataires
- Confirmer la réception des fonds
- Finaliser le processus de réception
- Gérer les annulations
- Suivre le statut de réception

## Intégration avec d'Autres Applications
L'application Réception s'intègre à plusieurs autres composants du système de Transfert d'Argent :

- **Transactions** : Reçoit les données de transaction pour créer des réceptions
- **Notifications** : Envoie des notifications aux destinataires et expéditeurs
- **Withdrawals** : Facilite le processus de retrait lorsque les fonds sont collectés
- **Dashboard** : Fournit des statistiques de réception pour les rapports

L'application utilise des signaux Django pour :
- Créer automatiquement des enregistrements de réception lorsqu'une transaction est créée
- Synchroniser les statuts entre les transactions et les réceptions
- Déclencher des notifications lorsque le statut de réception change
- Mettre à jour les modèles liés lorsque la réception est finalisée ou annulée

## Logique Métier

### Création de Réception
Une instance de Réception est automatiquement créée lorsqu'une nouvelle Transaction est traitée :
- Générée avec un code de réception unique
- Liée à la transaction d'origine
- Définie avec un statut initial 'en attente'

### Processus de Notification
Lorsqu'une Réception est créée :
- Le système envoie une notification au destinataire
- La notification inclut le code de réception et le montant
- Le statut est mis à jour à 'notifié'

### Confirmation
Lorsqu'un destinataire accuse réception :
- Le statut est mis à jour à 'confirmé'
- L'expéditeur est notifié de la confirmation

### Finalisation
Lorsque le destinataire collecte les fonds :
- Le statut est mis à jour à 'terminé'
- La transaction est marquée comme terminée
- L'expéditeur et le destinataire reçoivent des notifications de finalisation

### Annulation
Une réception peut être annulée si elle n'est pas encore terminée :
- Le statut est mis à jour à 'annulé'
- La transaction est marquée comme annulée
- Les fonds sont retournés à l'expéditeur (si applicable)
- Les deux parties sont notifiées de l'annulation

### Expiration
Si une réception n'est pas réclamée dans le délai spécifié :
- Le statut est mis à jour à 'expiré'
- La transaction est marquée comme expirée
- Les fonds sont retournés à l'expéditeur
- Les deux parties sont notifiées de l'expiration

## Contributeurs
Développé par l'Équipe Backend de Transfert d'Argent.

## Licence
Cette application est propriétaire et confidentielle. Toute utilisation non autorisée est interdite.
