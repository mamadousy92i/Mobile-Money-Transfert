
# 💸 **Plateforme de Transfert d'Argent - Backend**

---

## 📖 Présentation

Ce dépôt contient le code source du backend de la **Plateforme de Transfert d'Argent**, une application de niveau entreprise conçue pour être robuste, sécurisée et hautement scalable. Le projet gère l'ensemble du cycle de vie des transferts d'argent, de l'inscription des utilisateurs à la distribution physique des fonds via un réseau d'agents, en passant par la gestion des transactions nationales et internationales.

L'architecture est pensée pour une maintenabilité à long terme et une collaboration efficace entre plusieurs équipes de développement.

---

## 📜 Table des Matières

1. [🏛️ Architecture & Philosophie](#️-architecture--philosophie)  
2. [🔁 Workflows Métier Détaillés](#-workflows-métier-détaillés)  
3. [🧩 Fonctionnalités Détaillées par Module](#-fonctionnalités-détaillées-par-module)  
4. [💻 Stack Technique](#-stack-technique)  
5. [📋 Prérequis](#-prérequis)  
6. [🚀 Installation et Démarrage Rapide](#-installation-et-démarrage-rapide)  
7. [🏗️ Structure Détaillée du Projet](#-structure-détaillée-du-projet)  
8. [🌐 Guide de lAPI et Endpoints](#-guide-de-lapi-et-endpoints)  
9. [🔬 Concepts Techniques Approfondis](#-concepts-techniques-approfondis)  
10. [🔑 Variables dEnvironnement](#-variables-denvironnement)  
11. [🧪 Tests et Qualité du Code](#-tests-et-qualité-du-code)  
12. [✍️ Auteurs et Contact](#-auteurs-et-contact)  
13. [📄 Licence](#-licence)

---

## 🏛️ Architecture & Philosophie

Le projet repose sur une **architecture modulaire Django**, où chaque app représente un domaine métier autonome, facilitant la **séparation des responsabilités** et l’évolution du système.

- **Autonomie** : Chaque app (`transactions`, `agents`, etc.) fonctionne de façon isolée.
- **Découplage via Signaux Django** : les modules communiquent sans dépendance directe.
- **Scalabilité** : Facile à étendre pour gérer de nouveaux services ou pays.

---

## 🔁 Workflows Métier Détaillés

### ✅ Workflow 1 : Inscription → Envoi d'argent
- `authentication` → `kyc` → `transactions` → `payment_gateways` → `notifications`

### ✅ Workflow 2 : Retrait d'argent
- `agents` → `withdrawals` → `transactions` → `notifications` → `dashboard`

*(Voir section détaillée dans le code source pour la logique complète.)*

---

## 🧩 Fonctionnalités Détaillées par Module

| Module | Description |
|--------|-------------|
| `authentication` | Gestion des utilisateurs, login JWT, profil |
| `kyc` | Vérification d’identité (documents, statut) |
| `transactions` | Logique métier des transferts (montants, statuts) |
| `payment_gateways` | Simulations réalistes de paiements (Wave, Orange Money) |
| `agents` | Gestion des agents physiques et géolocalisation |
| `withdrawals` | Système sécurisé de retrait |
| `notifications` | Système de notifications basé sur les signaux |
| `dashboard` | Statistiques et indicateurs en temps réel |
| `reception` | Logique spécifique au bénéficiaire |

---

## 💻 Stack Technique

- 🐍 **Python** 3.11+  
- ⚙️ **Django** 4.2+  
- 🔌 **Django REST Framework (DRF)** 3.14+  
- 🔐 **JWT Auth** (`djangorestframework-simplejwt`)  
- 🐘 **PostgreSQL** (prod) / SQLite (dev)  
- 🧪 **python-decouple** (gestion des variables d’environnement)  
- 🌀 **Gunicorn** (serveur WSGI recommandé en production)

---

## 📋 Prérequis

- ✅ Python 3.11 ou plus récent  
- ✅ pip  
- ✅ Git  
- 🐘 PostgreSQL (si mode production)

---

## 🚀 Installation et Démarrage Rapide

```bash
git clone <url-du-depot>
cd money-transfer-backend

# Environnement virtuel
python -m venv venv
source venv/bin/activate  # ou venv\Scripts\activate sous Windows

# Dépendances
pip install -r requirements.txt

# Variables d'environnement
cp .env.example .env  # Modifier les valeurs dans .env

# Migrations & superutilisateur
python manage.py migrate
python manage.py createsuperuser

# (Optionnel) Données initiales
python manage.py populate_10_countries

# Lancement
python manage.py runserver
````

Accès : [http://127.0.0.1:8000](http://127.0.0.1:8000)

---

## 🏗️ Structure Détaillée du Projet

```
money-transfer-backend/
├── money_transfer/         # Configuration principale
├── apps/
│   ├── authentication/     # Utilisateurs & Authentification
│   ├── kyc/                # Vérification d’identité
│   ├── transactions/       # Transferts d'argent
│   ├── payment_gateways/   # Simulateurs (Wave, Orange Money)
│   ├── agents/             # Réseau d'agents
│   ├── withdrawals/        # Retrait physique
│   ├── notifications/      # Système de notification
│   ├── dashboard/          # Statistiques
│   └── reception/          # Bénéficiaire
├── manage.py
└── .env
```

---

## 🌐 Guide de l’API et Endpoints

| Endpoint                | Description                        |
| ----------------------- | ---------------------------------- |
| `GET /api/`             | Racine de l’API                    |
| `POST /api/auth/`       | Authentification, inscription, JWT |
| `POST /api/kyc/`        | Upload de documents, statut        |
| `/api/v1/transactions/` | Création et historique             |
| `/api/v1/agents/`       | Localisation des agents            |
| `/api/v1/withdrawals/`  | Demande et validation de retrait   |
| `/api/v1/dashboard/`    | Indicateurs en temps réel          |

📦 **Postman Collection** incluse pour test exhaustif.

---

## 🔬 Concepts Techniques Approfondis

* **User personnalisé** : `phone_number` comme identifiant principal.
* **Signaux Django** : notifications et mises à jour déclenchées automatiquement.
* **Factory Pattern** : instanciation dynamique des simulateurs de paiement.
* **Transactions atomiques** : cohérence garantie via `transaction.atomic()`.

---

## 🔑 Variables d’Environnement

| Clé                        | Description                          |
| -------------------------- | ------------------------------------ |
| `SECRET_KEY`               | Clé secrète Django                   |
| `DEBUG`                    | `True` pour développement            |
| `USE_POSTGRESQL`           | `True` si usage PostgreSQL           |
| `DB_NAME`, `DB_USER`, etc. | Connexion à la base de données       |
| `EMAIL_*`                  | Configuration SMTP si envoi d'emails |

---

## 🧪 Tests et Qualité du Code

* ✅ **Tests manuels** via Postman
* 🔜 **Tests automatisés** en cours de préparation avec `pytest-django`
* 🔄 Objectif CI/CD à long terme

---

## ✍️ Auteurs et Contact

👨‍💻 **Nom** : Mamadou SY

💼 **Rôle** : Développeur Full Stack Web & Mobile

📧 **Email** : [92mamadousy@gmail.com](mailto:92mamadousy@gmail.com)

📱 **Téléphone** : +221 77 756 72 26 / +221 76 623 21 05

🔗 **GitHub** : [github.com/ton-profil](https://github.com/mamadousy92i))

---

## 📄 Licence

Ce projet est sous **licence MIT**. Voir le fichier `LICENSE`.

