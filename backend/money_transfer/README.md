
# **Plateforme de Transfert d'Argent - Backend**

   

Plateforme de transfert d'argent de niveau entreprise, conçue avec une architecture modulaire et scalable. Elle gère l'ensemble du cycle de vie d'une transaction, de l'authentification de l'utilisateur à l'envoi d'argent national ou international, jusqu'au retrait physique via un réseau d'agents géolocalisés.

## 📜 Table des Matières

1.  [Fonctionnalités Clés](https://www.google.com/search?q=%23-fonctionnalit%C3%A9s-cl%C3%A9s)
2.  [Architecture du Projet](https://www.google.com/search?q=%23-architecture-du-projet)
3.  [Stack Technique](https://www.google.com/search?q=%23-stack-technique)
4.  [Prérequis](https://www.google.com/search?q=%23-pr%C3%A9requis)
5.  [Installation et Configuration](https://www.google.com/search?q=%23-installation-et-configuration)
6.  [Structure du Projet](https://www.google.com/search?q=%23-structure-du-projet)
7.  [Démarrage du Serveur](https://www.google.com/search?q=%23-d%C3%A9marrage-du-serveur)
8.  [Présentation des Endpoints de l'API](https://www.google.com/search?q=%23-pr%C3%A9sentation-des-endpoints-de-lapi)
9.  [Concepts Métier et Logique](https://www.google.com/search?q=%23-concepts-m%C3%A9tier-et-logique)
10. [Variables d'Environnement](https://www.google.com/search?q=%23-variables-denvironnement)
11. [Tests](https://www.google.com/search?q=%23-tests)
12. [Contribution](https://www.google.com/search?q=%23-contribution)
13. [Licence](https://www.google.com/search?q=%23-licence)

-----

## ✨ Fonctionnalités Clés

  * **Système d'Authentification Robuste** : Inscription et connexion par numéro de téléphone, gestion de profil et sécurité via tokens JWT.
  * **Processus KYC (Know Your Customer)** : Workflow complet de vérification d'identité des utilisateurs.
  * **Notifications en Temps Réel** : Système de notifications multi-canaux (base de données, extensible vers SMS/Email) déclenché par les événements métier.
  * **Transactions Nationales & Internationales** : Moteur de transaction pour les envois locaux et internationaux avec gestion des corridors et des taux de change.
  * **Simulation de Passerelles de Paiement** : Simulateurs réalistes pour Wave et Orange Money, incluant la latence, les taux de succès et les structures de frais.
  * **Réseau d'Agents Géolocalisés** : Gestion complète d'un réseau d'agents de retrait, avec recherche par proximité.
  * **Système de Retrait Sécurisé** : Processus de retrait d'argent avec validation par codes uniques et QR codes.
  * **Tableau de Bord Analytique** : API fournissant des statistiques et des métriques de performance en temps réel.

-----

## 🏛️ Architecture du Projet

Le backend est conçu autour d'une **architecture modulaire** basée sur les applications Django. Chaque application représente un domaine métier distinct, ce qui favorise la séparation des responsabilités et la maintenabilité.

La collaboration est structurée comme suit :

  * **Développeur 1 (Fondations & Utilisateur)** : Gère `authentication`, `kyc`, `notifications`. [cite\_start]Responsable du cycle de vie de l'utilisateur. [cite: 7, 10, 11]
  * **Développeur 2 (Cœur Métier & Paiements)** : Gère `transactions`, `payment_gateways`. [cite\_start]Responsable du flux financier. [cite: 8, 9]
  * **Développeur 3 (Opérations & Distribution)** : Gère `agents`, `withdrawals`, `dashboard`, `reception`. [cite\_start]Responsable du réseau physique et de l'analyse des données. [cite: 1, 2, 3]

L'intégration est assurée par des relations claires entre les modèles (`ForeignKey`), des appels de services et l'utilisation des **Signaux Django** pour une communication découplée.

-----

## 💻 Stack Technique

  * **Langage** : Python 3.11+
  * **Framework** : Django 4.2+
  * **API** : Django REST Framework (DRF) 3.14+
  * **Authentification** : djangorestframework-simplejwt (JWT)
  * **Base de Données** : PostgreSQL (production), SQLite3 (développement)
  * **Configuration** : python-decouple
  * **Serveur** : Gunicorn (recommandé pour la production)

-----

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé les logiciels suivants sur votre machine :

  * Python (version 3.11 ou supérieure)
  * `pip` (le gestionnaire de paquets de Python)
  * Git (pour cloner le projet)
  * (Optionnel) PostgreSQL

-----

## 🚀 Installation et Configuration

Suivez ces étapes pour mettre en place votre environnement de développement local.

**1. Cloner le Dépôt**

```bash
git clone <url-du-depot>
cd money-transfer-backend
```

**2. Créer et Activer un Environnement Virtuel**
Il est fortement recommandé d'utiliser un environnement virtuel pour isoler les dépendances du projet.

```bash
# Pour Windows
python -m venv venv
venv\Scripts\activate

# Pour macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

**3. Installer les Dépendances**
Créez un fichier `requirements.txt` avec les dépendances (Django, DRF, etc.) et installez-les.

```bash
pip install django djangorestframework djangorestframework-simplejwt python-decouple psycopg2-binary
```

*(Note : La liste ci-dessus est indicative. Référez-vous au fichier `requirements.txt` du projet pour la liste complète.)*

**4. Configurer les Variables d'Environnement**
Créez un fichier `.env` à la racine du projet en vous basant sur le modèle ci-dessous.

```ini
# .env.example
# CONFIGURATION DJANGO
SECRET_KEY=votre_super_secret_key_ici
DEBUG=True

# CONFIGURATION BASE DE DONNÉES (décommenter pour PostgreSQL)
# USE_POSTGRESQL=True
# DB_NAME=money_transfer_db
# DB_USER=user
# DB_PASSWORD=password
# DB_HOST=localhost
# DB_PORT=5432
```

Copiez ce contenu dans un nouveau fichier nommé `.env` et remplissez les valeurs.

**5. Appliquer les Migrations de la Base de Données**
Cette commande crée les tables nécessaires dans votre base de données.

```bash
python manage.py migrate
```

**6. Créer un Super-Utilisateur**
Ce compte vous donnera accès à l'interface d'administration de Django (`/admin/`).

```bash
python manage.py createsuperuser
```

**7. (Optionnel) Peupler la Base de Données**
Le projet inclut des commandes pour peupler la base de données avec des données initiales (pays, services, etc.).

```bash
python manage.py populate_10_countries
```

Vous êtes maintenant prêt à lancer le serveur \!

-----

## 🏗️ Structure du Projet

L'organisation des fichiers et des applications est la suivante :

```
money-transfer-backend/
├── money_transfer/          # Fichiers de configuration du projet
│   ├── settings.py          # ✅ Configuration principale
│   ├── urls.py              # ✅ Routage principal de l'API
│   ├── wsgi.py
│   └── api_views.py         # ✅ Vues API simples pour compatibilité
├── apps/
│   ├── authentication/      # Gestion utilisateurs, JWT, profils
│   ├── agents/              # Gestion du réseau d'agents
│   ├── dashboard/           # Logique pour les statistiques
│   ├── kyc/                 # Workflow de vérification d'identité
│   ├── notifications/       # Système de notifications
│   ├── payment_gateways/    # Services de simulation de paiement
│   ├── reception/           # Logique côté réception d'argent
│   ├── transactions/        # Coeur métier : transactions, frais, etc.
│   └── withdrawals/         # Gestion des retraits
├── manage.py                # Utilitaire de commande Django
└── .env                     # Fichier des variables d'environnement (ne pas versionner)
```

-----

## ▶️ Démarrage du Serveur

Pour lancer le serveur de développement, exécutez la commande suivante depuis la racine du projet :

```bash
python manage.py runserver
```

Le serveur sera accessible à l'adresse **[http://127.0.0.1:8000](http://127.0.0.1:8000)**.

-----

## 🌐 Présentation des Endpoints de l'API

L'API est organisée de manière logique et versionnée. Pour une exploration complète et interactive, utilisez la collection Postman fournie.

  * **Endpoint Racine** : `GET /api/` - Fournit une auto-documentation des principaux endpoints disponibles.
  * **Authentification & Utilisateurs** : `  /api/auth/ ` - Inscription, connexion, profil, etc.
  * **KYC** : `/api/kyc/` - Upload et vérification des documents d'identité.
  * **Notifications** : `/api/notifications/` - Consultation des notifications.
  * **Transactions (Coeur)** : `/api/v1/transactions/` - Envoi d'argent, historique, etc.
  * **Opérations Agents** : `/api/v1/agents/`, `/api/v1/withdrawals/` - Gestion du réseau physique.
  * **Analytics** : `/api/v1/dashboard/` - Accès aux statistiques de la plateforme.

-----

## 💡 Concepts Métier et Logique

  * **Simulation de Paiement** : Le module `payment_gateways` utilise un *Factory Pattern* pour instancier des simulateurs (Wave, Orange Money). [cite\_start]Ces simulateurs miment des conditions réelles : temps de réponse variable, taux de succès non-garanti, et structures de frais distinctes, offrant un environnement de test très réaliste. [cite: 8]
  * **Communication Découplée via Signaux** : Pour éviter un couplage fort entre les applications, le système utilise intensivement les signaux Django. Par exemple, lorsque l'application `transactions` finalise une transaction, elle émet un signal `post_save`. [cite\_start]L'application `notifications` écoute ce signal et envoie une notification à l'utilisateur, sans que les deux modules aient à se connaître directement. [cite: 9]
  * **Gestion des Corridors Internationaux** : Le module `transactions` modélise les transferts internationaux via les modèles `Pays`, `ServicePaiementInternational` et `CorridorTransfert`. [cite\_start]Cela permet une configuration dynamique et flexible de nouveaux pays et services de paiement, avec leurs propres frais et limites. [cite: 6]

-----

## 🔑 Variables d'Environnement

Le fichier `.env` est utilisé pour configurer l'application sans hardcoder de valeurs sensibles.

| Variable | Description | Valeur par Défaut |
| :--- | :--- | :--- |
| `SECRET_KEY` | Clé secrète de Django pour la sécurité cryptographique. **Doit être unique en production.** | `django-insecure-...` |
| `DEBUG` | Active ou désactive le mode de débogage de Django. **Doit être `False` en production.**| `True` |
| `USE_POSTGRESQL` | Mettre à `True` pour utiliser PostgreSQL au lieu de SQLite. | `False` |
| `DB_NAME` | Nom de la base de données PostgreSQL. | `money_transfer_db`|
| `DB_USER` | Utilisateur de la base de données PostgreSQL. | `user` |
| `DB_PASSWORD`| Mot de passe de la base de données PostgreSQL. | `password` |
| `DB_HOST` | Hôte de la base de données PostgreSQL. | `localhost` |
| `DB_PORT` | Port de la base de données PostgreSQL. | `5432` |

-----

## 🧪 Tests

Ce projet dispose d'une collection Postman complète pour les tests manuels et d'intégration de l'API, couvrant plus de 60 scénarios.

Pour une robustesse de niveau production, la prochaine étape consiste à implémenter une suite de **tests automatisés**.

Pour lancer les tests (une fois créés) :

```bash
# Utiliser le runner de test de Django
python manage.py test

# Ou utiliser pytest (recommandé)
pytest
```

-----

## 🤝 Contribution

Nous encourageons les contributions pour améliorer la plateforme. Veuillez suivre ces étapes :

1.  **Fork** le dépôt.
2.  Créez une nouvelle branche pour votre fonctionnalité (`git checkout -b feature/nom-de-la-feature`).
3.  Commitez vos changements (`git commit -m 'Ajout de ...'`).
4.  Pushez vers votre branche (`git push origin feature/nom-de-la-feature`).
5.  Ouvrez une **Pull Request**.

-----

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.
