# Documentation du Travail d'Omar sur le Projet Mobile Money Transfert

## Introduction

Ce document présente une documentation détaillée des composants développés par Omar dans le cadre du projet Mobile Money Transfert. Les composants concernés sont les suivants :

- **Backend** :
  - Module d'authentification
  - Module KYC (Know Your Customer)
  - Module de notifications
  
- **Frontend** :
  - Pages de profil et gestion de profil
  - Pages de connexion et d'inscription
  - Implémentation du Retrofit
  - Gestion de l'authentification JWT

## Partie Backend

### 1. Module d'Authentification

Le module d'authentification est responsable de la gestion des utilisateurs et de l'authentification dans l'application. Il utilise un système d'authentification basé sur JWT (JSON Web Token) pour sécuriser les API.

#### 1.1 Fonctionnalités principales

- Modèle d'utilisateur personnalisé avec numéro de téléphone comme champ d'authentification principal
- Authentification JWT utilisant SimpleJWT
- Points d'API pour l'inscription, la connexion, la déconnexion, le rafraîchissement de token et la gestion de profil
- Suivi du statut KYC pour les utilisateurs
- Permissions personnalisées pour contrôler l'accès aux ressources

#### 1.2 Structure du module

- **models.py** : Définit le modèle d'utilisateur personnalisé et son gestionnaire
- **views.py** : Contient les vues API pour l'authentification et la gestion des utilisateurs
- **serializers.py** : Définit les sérialiseurs pour la validation et la transformation des données utilisateur
- **permissions.py** : Implémente des permissions personnalisées pour contrôler l'accès
- **signals.py** : Configure les signaux pour interagir avec d'autres applications
- **urls.py** : Définit les routes d'API pour l'application

#### 1.3 Points d'API

- `/api/auth/register/` : Inscription d'un nouvel utilisateur
- `/api/auth/login/` : Connexion et obtention des tokens JWT
- `/api/auth/logout/` : Déconnexion et mise en liste noire du token de rafraîchissement
- `/api/auth/refresh/` : Rafraîchissement du token d'accès
- `/api/auth/profile/` : Consultation ou mise à jour du profil utilisateur
- `/api/auth/change-password/` : Modification du mot de passe utilisateur

### 2. Module KYC (Know Your Customer)

Le module KYC est responsable de la gestion des documents d'identité et du processus de vérification des utilisateurs. Il permet aux utilisateurs de soumettre des documents d'identité qui sont ensuite vérifiés par les administrateurs du système.

#### 2.1 Fonctionnalités principales

- Soumission de documents d'identité par les utilisateurs
- Différents types de documents supportés (carte d'identité, passeport, permis de conduire, etc.)
- Processus de vérification avec statuts (en attente, vérifié, rejeté)
- Intégration avec le modèle utilisateur pour mettre à jour le statut KYC
- Notifications automatiques lors des changements de statut

#### 2.2 Structure du module

- **models.py** : Définit le modèle KYCDocument pour stocker les informations des documents
- **views.py** : Contient les vues API pour la soumission et la gestion des documents
- **serializers.py** : Définit les sérialiseurs pour la validation et la transformation des données
- **signals.py** : Configure les signaux pour mettre à jour le statut KYC de l'utilisateur et envoyer des notifications
- **urls.py** : Définit les routes d'API pour l'application

#### 2.3 Points d'API

- `/api/kyc/documents/` : Liste et création de documents KYC
- `/api/kyc/documents/{id}/` : Détails, mise à jour et suppression d'un document spécifique
- `/api/kyc/documents/{id}/verify/` : Vérification d'un document (admin uniquement)
- `/api/kyc/documents/{id}/reject/` : Rejet d'un document (admin uniquement)
- `/api/kyc/status/` : Consultation du statut KYC global de l'utilisateur

### 3. Module de Notifications

Le module de notifications est responsable de la création, de la gestion et de la distribution des notifications aux utilisateurs. Il permet d'informer les utilisateurs des événements importants comme les changements de statut KYC, les transactions effectuées, et d'autres alertes système.

#### 3.1 Fonctionnalités principales

- Système de notifications en base de données
- Différents types de notifications (information, transaction, alerte)
- Statuts de notification (lu, non lu)
- Architecture extensible avec pattern Factory pour les canaux de notification
- Intégration avec d'autres applications via des signaux Django

#### 3.2 Structure du module

- **models.py** : Définit le modèle Notification avec ses types et statuts
- **views.py** : Contient les vues API et l'architecture des canaux de notification
- **serializers.py** : Définit les sérialiseurs pour la validation et la transformation des données
- **signals.py** : Configure les signaux pour créer des notifications automatiques
- **urls.py** : Définit les routes d'API pour l'application

#### 3.3 Points d'API

- `/api/notifications/` : Liste des notifications de l'utilisateur connecté
- `/api/notifications/{id}/` : Détails d'une notification spécifique
- `/api/notifications/{id}/read/` : Marquer une notification comme lue
- `/api/notifications/` (POST, admin uniquement) : Créer une nouvelle notification

## Partie Frontend

### 1. Écran de Profil et Gestion de Profil

L'écran de profil permet aux utilisateurs de visualiser et de gérer leurs informations personnelles, leur statut KYC, et leurs paramètres de sécurité.

#### 1.1 Composants principaux

- **ProfileScreen** : Écran principal de profil qui organise et affiche tous les composants
- **ProfileHeader** : En-tête du profil avec photo et informations de base de l'utilisateur
- **KYCStatusCard** : Carte affichant le statut de vérification KYC et permettant de soumettre des documents
- **UserStatsCards** : Cartes affichant les statistiques de l'utilisateur (transactions, montants envoyés)
- **ContactInfoCard** : Carte permettant de visualiser et modifier les informations de contact
- **BeneficiariesCard** : Carte affichant les bénéficiaires enregistrés par l'utilisateur
- **SecuritySettingsCard** : Carte permettant de gérer les paramètres de sécurité

#### 1.2 Fonctionnalités

- Affichage des informations de profil de l'utilisateur
- Gestion du statut KYC et soumission de documents
- Visualisation des statistiques de l'utilisateur
- Modification des informations de contact
- Gestion des bénéficiaires
- Configuration des paramètres de sécurité

### 2. Écrans d'Authentification

Les écrans d'authentification permettent aux utilisateurs de s'inscrire et de se connecter à l'application.

#### 2.1 Composants principaux

- **AuthScreen** : Écran principal d'authentification avec onglets pour la connexion et l'inscription
- **LoginForm** : Formulaire de connexion avec champs pour le numéro de téléphone et le mot de passe
- **RegisterForm** : Formulaire d'inscription avec champs pour les informations personnelles

#### 2.2 Fonctionnalités

- Interface avec onglets pour basculer entre connexion et inscription
- Validation des formulaires côté client
- Sélection du pays pour le numéro de téléphone
- Option "Se souvenir de moi" pour la connexion
- Acceptation des conditions d'utilisation pour l'inscription
- Gestion des erreurs d'authentification

### 3. Implémentation Retrofit et JWT

L'implémentation Retrofit et JWT permet la communication sécurisée entre le frontend et le backend via des API REST.

#### 3.1 Composants principaux

- **AuthApi** : Interface Retrofit définissant les points d'API pour l'authentification
- **ApiService** : Service centralisant la gestion des API et des erreurs
- **RetrofitClient** : Client Retrofit configuré pour les requêtes HTTP
- **TokenPair** : Modèle pour stocker les tokens JWT (accès et rafraîchissement)

#### 3.2 Fonctionnalités

- Communication avec le backend via des API REST
- Gestion de l'authentification JWT (stockage et rafraîchissement des tokens)
- Interception des requêtes pour ajouter les headers d'authentification
- Gestion des erreurs API avec messages personnalisés
- Support pour les tests de connexion et la mise à jour de l'URL de base

## Intégration entre les Composants

### 1. Flux d'Authentification

1. L'utilisateur entre ses informations dans l'écran d'authentification (AuthScreen)
2. Les données sont validées côté client
3. La requête est envoyée au backend via AuthApi
4. Le backend valide les informations et génère des tokens JWT
5. Les tokens sont stockés côté client pour les futures requêtes
6. L'utilisateur est redirigé vers l'écran principal

### 2. Flux de Gestion de Profil

1. L'écran de profil (ProfileScreen) charge les données de l'utilisateur via AuthApi
2. Les informations sont affichées dans les différentes cartes
3. L'utilisateur peut modifier ses informations
4. Les modifications sont envoyées au backend via AuthApi
5. Le backend met à jour les informations et renvoie les données mises à jour
6. L'écran de profil est actualisé avec les nouvelles données

### 3. Flux de Vérification KYC

1. L'utilisateur accède à la carte de statut KYC dans l'écran de profil
2. Il soumet ses documents d'identité
3. Les documents sont envoyés au backend via l'API KYC
4. Le backend enregistre les documents et met à jour le statut KYC en "En attente"
5. Un administrateur vérifie les documents et les approuve ou les rejette
6. Le backend met à jour le statut KYC et envoie une notification à l'utilisateur
7. L'utilisateur reçoit une notification et son statut KYC est mis à jour dans l'écran de profil

### 4. Flux de Notifications

1. Un événement se produit dans le système (ex: approbation KYC, transaction)
2. Le backend crée une notification via le module de notifications
3. La notification est stockée en base de données
4. L'utilisateur accède à l'application et reçoit ses notifications
5. L'utilisateur peut marquer les notifications comme lues

## Conclusion

Le travail réalisé par Omar sur le projet Mobile Money Transfert comprend des composants essentiels pour la gestion des utilisateurs, l'authentification, la vérification KYC et les notifications. Ces composants sont bien intégrés entre eux et forment une base solide pour l'application de transfert d'argent mobile.

Les modules backend utilisent des pratiques modernes de développement Django avec des API RESTful, tandis que le frontend Flutter offre une interface utilisateur intuitive et réactive. L'utilisation de Retrofit et JWT assure une communication sécurisée entre le frontend et le backend.

Cette architecture modulaire facilite la maintenance et l'évolution future du projet, permettant d'ajouter de nouvelles fonctionnalités tout en conservant une base solide pour les fonctionnalités existantes.
