# **Plateforme de Transfert d'Argent - Backend**

Plateforme de transfert d'argent de niveau entreprise, conçue avec une architecture modulaire et scalable. Elle gère l'ensemble du cycle de vie d'une transaction, de l'authentification de l'utilisateur à l'envoi d'argent national ou international, jusqu'au retrait physique via un réseau d'agents géolocalisés.

---

## 📜 Table des Matières

1. [✨ Fonctionnalités Clés](#-fonctionnalités-clés)  
2. [🏛️ Architecture du Projet](#-architecture-du-projet)  
3. [💻 Stack Technique](#-stack-technique)  
4. [📋 Prérequis](#-prérequis)  
5. [🚀 Installation et Configuration](#-installation-et-configuration)  
6. [🏗️ Structure du Projet](#-structure-du-projet)  
7. [▶️ Démarrage du Serveur](#-démarrage-du-serveur)  
8. [🌐 Présentation des Endpoints de lAPI](#-présentation-des-endpoints-de-lapi)  
9. [💡 Concepts Métier et Logique](#-concepts-métier-et-logique)  
10. [🔑 Variables d'Environnement](#-variables-denvironnement)  
11. [🧪 Tests](#-tests)  
12. [🤝 Contribution](#-contribution)  
13. [📄 Licence](#-licence)  
14. [✍️ Auteurs et Contact](#-auteurs-et-contact)  

---

## ✨ Fonctionnalités Clés

* **Système d'Authentification Robuste** : Inscription et connexion par numéro de téléphone, gestion de profil et sécurité via tokens JWT.  
* **Processus KYC (Know Your Customer)** : Workflow complet de vérification d'identité des utilisateurs.  
* **Notifications en Temps Réel** : Notifications via base de données (extensible vers SMS/Email) déclenchées par des événements.  
* **Transactions Nationales & Internationales** : Moteur de transaction configurable pour les envois locaux et internationaux.  
* **Simulation de Passerelles de Paiement** : Modules Wave et Orange Money simulant latence, frais et succès conditionnel.  
* **Réseau d'Agents Géolocalisés** : Recherche par proximité et gestion d’agents de retrait.  
* **Système de Retrait Sécurisé** : Validation via codes uniques et QR codes.  
* **Tableau de Bord Analytique** : API exposant des indicateurs clés et statistiques.

---

## 🏛️ Architecture du Projet

Le backend est conçu autour d’une **architecture modulaire Django** : chaque domaine métier est une app indépendante, reliée par des signaux ou des appels de services.

- **Utilisateurs & KYC & Notification** : `authentication`, `kyc`, `notifications`  
- **DTransactions & Paiments** : `transactions`, `payment_gateways`  
- **Agent ,Reception et Dashboard** : `agents`, `withdrawals`, `dashboard`, `reception`

Les modules interagissent via des signaux (`post_save`, etc.), garantissant un **faible couplage** entre les apps.

---

## 💻 Stack Technique

- **Langage** : Python 3.11+  
- **Framework** : Django 4.2+  
- **API** : Django REST Framework (DRF) 3.14+  
- **Authentification** : JWT avec `djangorestframework-simplejwt`  
- **Base de données** : PostgreSQL (prod), SQLite3 (dev)  
- **Serveur** : Gunicorn  
- **Variables** : `python-decouple`  

---

## 📋 Prérequis

- Python 3.11+  
- pip  
- Git  
- PostgreSQL (optionnel pour dev)

---

## 🚀 Installation et Configuration

```bash
git clone <url-du-depot>
cd money-transfer-backend
````

Créer un environnement virtuel :

```bash
python -m venv venv
# Windows
venv\Scripts\activate
# Linux/macOS
source venv/bin/activate
```

Installer les dépendances :

```bash
pip install -r requirements.txt
```

Configurer le fichier `.env` :

```ini
SECRET_KEY=your_secret_key
DEBUG=True
USE_POSTGRESQL=False
DB_NAME=money_transfer_db
DB_USER=user
DB_PASSWORD=password
DB_HOST=localhost
DB_PORT=5432
```

Effectuer les migrations :

```bash
python manage.py migrate
```

Créer un super utilisateur :

```bash
python manage.py createsuperuser
```

Optionnel : peupler la base avec des pays factices :

```bash
python manage.py populate_10_countries
```

---

## 🏗️ Structure du Projet

```
money-transfer-backend/
├── money_transfer/
├── apps/
│   ├── authentication/
│   ├── agents/
│   ├── dashboard/
│   ├── kyc/
│   ├── notifications/
│   ├── payment_gateways/
│   ├── reception/
│   ├── transactions/
│   └── withdrawals/
├── manage.py
└── .env
```

---

## ▶️ Démarrage du Serveur

```bash
python manage.py runserver
```

Par défaut : [http://127.0.0.1:8000](http://127.0.0.1:8000)

---

## 🌐 Présentation des Endpoints de l’API

* `GET /api/` – Endpoint racine de l’API
* `POST /api/auth/` – Authentification et gestion des comptes
* `POST /api/kyc/` – KYC : vérification de documents
* `/api/notifications/` – Liste des notifications
* `/api/v1/transactions/` – Historique et exécution des transferts
* `/api/v1/agents/` – Infos agents
* `/api/v1/withdrawals/` – Opérations de retrait
* `/api/v1/dashboard/` – Données analytiques

---

## 💡 Concepts Métier et Logique

* **Passerelles de Paiement simulées** : Chaque simulateur est instancié via un *factory pattern*.
* **Signaux Django** : Déclenchement d’événements métier entre apps sans couplage direct.
* **Corridors Internationaux** : Les modèles `Pays`, `CorridorTransfert`, etc., permettent d’ajouter dynamiquement des routes de transfert, avec leurs frais et limites.

---

## 🔑 Variables d’Environnement

| Variable        | Description                      | Exemple                  |
| --------------- | -------------------------------- | ------------------------ |
| SECRET\_KEY     | Clé secrète Django               | `django-insecure-abc123` |
| DEBUG           | Mode debug                       | `True` / `False`         |
| USE\_POSTGRESQL | BDD PostgreSQL au lieu de SQLite | `True` / `False`         |
| DB\_NAME        | Nom de la base de données        | `money_transfer_db`      |
| DB\_USER        | Utilisateur DB                   | `postgres`               |
| DB\_PASSWORD    | Mot de passe DB                  | `password123`            |
| DB\_HOST        | Hôte DB                          | `localhost`              |
| DB\_PORT        | Port DB                          | `5432`                   |

---

## 🧪 Tests

Test manuel via **Postman Collection fournie**.
Tests automatisés à venir (`pytest`, `unittest`, `factory_boy`, etc.).

```bash
python manage.py test
# ou
pytest
```

---

## 🤝 Contribution

1. Fork du dépôt
2. Nouvelle branche : `feature/xxx`
3. Commit : `git commit -m "Ajout de la feature X"`
4. Push : `git push origin feature/xxx`
5. Pull Request vers `main`

---

## 📄 Licence

Projet sous licence MIT. Voir le fichier `LICENSE`.

---

## ✍️ Auteurs et Contact

Ce projet a été développé et architecturé par :

**👤 Nom** : Mamadou SY

**🎯 Rôle** : Développeur Full Stack Web et Mobile

**📧 Email** : [92mamadousy@gmail.com](mailto:92mamadousy@gmail.com)

**📱 Téléphone** : +221 77 756 72 26 / +221 76 623 21 05

*N'hésitez pas à me contacter pour toute question, collaboration ou opportunité.*

