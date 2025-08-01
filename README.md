# 💸 Money Transfer App
### Plateforme Complète de Transfert d'Argent Sécurisée

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Django](https://img.shields.io/badge/Django-5.0+-092E20?style=for-the-badge&logo=django&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![JWT](https://img.shields.io/badge/JWT-Auth-000000?style=for-the-badge&logo=jsonwebtokens&logoColor=white)

</div>

<div align="center">
  <img src="https://git-scm.com/images/logos/downloads/Git-Icon-1788C.png" alt="Git" width="40" height="40"/>
  <img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" alt="GitHub" width="40" height="40"/>
  <img src="https://www.postgresql.org/media/img/about/press/elephant.png" alt="PostgreSQL" width="40" height="40"/>
  <img src="https://storage.googleapis.com/cms-storage-bucket/ec64036b4eacc9f3fd73.svg" alt="Flutter" width="40" height="40"/>
  <img src="https://static.djangoproject.com/img/logos/django-logo-negative.svg" alt="Django" width="80" height="40"/>
  <img src="https://miro.medium.com/v2/resize:fit:512/1*8ZZLqaU8pWsChHcD7z_7YQ.png" alt="Retrofit" width="40" height="40"/>
</div>

---

## 🎯 Vue d'ensemble

**Money Transfer App** est une solution fintech complète permettant les transferts d'argent nationaux et internationaux. Construite avec une architecture client-serveur moderne, elle combine la puissance de **Django** pour le backend et la flexibilité de **Flutter** pour l'interface mobile multiplateforme.

### ✨ Caractéristiques principales

- 🌍 **Transferts internationaux** avec conversion automatique
- 🏦 **Transferts nationaux** instantanés
- 🔐 **Authentification JWT** sécurisée
- 📋 **Processus KYC** complet
- 💱 **Taux de change** en temps réel
- 📱 **Notifications push** interactives
- 👥 **Gestion des bénéficiaires**
- 📊 **Suivi des transactions** en temps réel

---

## 📋 Table des matières

- [🎯 Vue d'ensemble](#-vue-densemble)
- [🏗️ Architecture](#-architecture)
- [⚡ Fonctionnalités](#-fonctionnalités)
- [🔄 Workflow](#-workflow)
- [🛠️ Technologies](#-technologies)
- [🚀 Installation](#-installation)
- [📡 API Documentation](#-api-documentation)
- [📱 Captures d'écran](#-captures-décran)
- [🤝 Contribution](#-contribution)
- [📄 Licence](#-licence)

---

## 🏗️ Architecture

### Structure du Projet

```
money-transfer-app/
├── 📱 frontend/                    # Application Flutter
│   ├── lib/
│   │   ├── screens/               # Interfaces utilisateur
│   │   ├── providers/             # Gestion d'état (Provider)
│   │   ├── services/              # Services API
│   │   ├── models/                # Modèles de données
│   │   ├── network/               # Configuration réseau (Dio/Retrofit)
│   │   └── utils/                 # Utilitaires
│   └── assets/                    # Ressources statiques
│
├── 🔙 backend/                     # API Django
│   ├── money_transfer/            # Configuration principale
│   ├── apps/
│   │   ├── authentication/       # Gestion utilisateurs & JWT
│   │   ├── transactions/          # Logique de transfert
│   │   ├── kyc/                   # Vérification d'identité
│   │   ├── notifications/         # Système de notifications
│   │   ├── exchange_rates/        # Taux de change
│   │   └── agents/                # Gestion des agents
│   └── requirements.txt
│
└── 📖 docs/                       # Documentation
```

### Diagrammes d'Architecture et Workflows

#### 🏗️ Architecture Générale du Système
```mermaid
graph TB
    A[📱 Flutter App] -->|JWT Auth| B[🔐 Django API]
    B --> C[🗄️ PostgreSQL]
    B --> D[💱 Exchange Rate Service]
    B --> E[📲 Notification Service]
    B --> F[🏦 Payment Simulators]
    
    subgraph "Backend Services"
        B
        D
        E
        F
    end
```

#### 📊 Diagrammes de Cas d'Usage et Workflows

#### 📊 Diagrammes de Cas d'Usage et Workflows

> **📁 Structure des Diagrammes** : Placez vos diagrammes dans le dossier `docs/diagrams/` avec les noms suivants :
> - `use_case_diagram.png` - Diagramme de cas d'usage global
> - `user_transfer_workflow.png` - Workflow de transfert utilisateur  
> - `receiver_workflow.png` - Workflow de réception
> - `agent_workflow.png` - Workflow agent local
> - `simple_receiver_workflow.png` - Workflow réception simplifié

##### 1. Diagramme de Cas d'Usage - Vue Globale
<div align="center">
<img src="docs/diagrams/use_case_diagram.png" alt="Diagramme de Cas d'Usage" width="800"/>
</div>

*Diagramme montrant les interactions entre les différents acteurs (Utilisateur, Émetteur, Agent Local, Bénéficiaire) et les fonctionnalités du système*

##### 2. Workflow de Transfert d'Argent - Processus Utilisateur
<div align="center">
<img src="docs/diagrams/user_transfer_workflow.png" alt="Workflow Utilisateur" width="800"/>
</div>

*Processus complet de transfert d'argent : connexion → saisie → validation → confirmation → génération de reçu*

##### 3. Workflow de Réception - Processus Bénéficiaire
<div align="center">
<img src="docs/diagrams/receiver_workflow.png" alt="Workflow Réception" width="800"/>
</div>

*Processus de réception d'argent : notification → vérification → choix du mode de réception → retrait*

##### 4. Workflow Agent Local - Gestion des Transactions
<div align="center">
<img src="docs/diagrams/agent_workflow.png" alt="Workflow Agent" width="800"/>
</div>

*Processus de gestion des transactions par les agents locaux : authentification → consultation → vérification → traitement*

##### 5. Workflow de Réception Simplifié
<div align="center">
<img src="docs/diagrams/simple_receiver_workflow.png" alt="Workflow Réception Simplifié" width="600"/>
</div>

*Version simplifiée du processus de réception montrant les étapes clés*

---

## ⚡ Fonctionnalités

### 👤 Gestion des Utilisateurs
- **Inscription/Connexion** avec validation par email
- **Authentification JWT** avec refresh tokens
- **Profil utilisateur** personnalisable
- **Changement de mot de passe** sécurisé
- **Processus KYC** avec upload de documents (CNI recto/verso, selfie)

### 💸 Transferts d'Argent
- **Transferts nationaux** : Envoi instantané dans le même pays
- **Transferts internationaux** : Avec conversion automatique de devises
- **Calcul automatique des frais** basé sur le montant et la destination
- **Simulation de paiement** (Wave, Orange Money)
- **Historique complet** des transactions

### 👥 Gestion des Bénéficiaires
- **Carnet d'adresses** des bénéficiaires favoris
- **Informations détaillées** : nom, téléphone, pays
- **Ajout/modification/suppression** des contacts

### 🔔 Notifications
- **Notifications push** en temps réel
- **Badge de notifications** non lues
- **Historique des notifications**
- **Statuts de transaction** mis à jour automatiquement

### 💱 Taux de Change
- **Taux en temps réel** via API externe
- **Conversion automatique** pour les transferts internationaux
- **Historique des taux** pour analyse

---

## 🔄 Workflows Détaillés

### 📋 Vue d'ensemble des Processus

Nos diagrammes d'activité détaillent les workflows complets de l'application :

#### 🎯 **Acteurs Principaux**
- **👤 Utilisateur (Émetteur)** : Initie les transferts d'argent
- **📱 Bénéficiaire** : Reçoit et retire l'argent
- **🏪 Agent Local** : Facilite les retraits physiques
- **🏦 Système** : Gère les transactions et notifications

#### 🚀 **Workflows Implementés**

1. **📤 Processus d'Envoi d'Argent**
   - Authentification sécurisée JWT
   - Saisie et validation des informations de transfert
   - Calcul automatique des frais et taux de change
   - Confirmation et traitement du paiement
   - Génération de reçu de transaction

2. **📥 Processus de Réception**
   - Notification automatique au bénéficiaire
   - Vérification de l'identité de l'expéditeur
   - Choix du mode de réception (digital/physique)
   - Retrait sécurisé avec QR code ou agent

3. **🏪 Gestion par Agent Local**
   - Interface dédiée pour les agents partenaires
   - Consultation des transactions en attente
   - Vérification des fonds et identité
   - Validation et traitement des retraits physiques

### 🔄 Workflow de Transfert d'Argent (Détaillé)

#### Phase 1 : Initiation
```
Utilisateur sélectionne "Transfert International"
    ↓
Choix du pays destinataire
    ↓
Saisie du numéro du bénéficiaire et du montant
```

### 2. 💱 Calcul des Frais
```
Flutter → API: /calculate-fees/
    ↓
Django calcule frais + conversion
    ↓
Retour du montant total pour confirmation
```

### 3. 💳 Traitement du Paiement
```
Flutter → API: /send-money/
    ↓
Création transaction (statut: EN_ATTENTE)
    ↓
Simulation paiement (Wave/OM)
    ↓
Statut: ENVOYE ou ANNULE
```

### 4. 🔔 Notifications Automatiques
```
Statut ENVOYE → Notifications + Création Reception
    ↓
Statut ANNULE → Notification d'échec
```

### 5. 📥 Réception et Retrait
```
Bénéficiaire consulte la réception
    ↓
Choix: Retrait digital OU physique (agent + QR Code)
    ↓
Statut final: TERMINE
```

---

## 🛠️ Technologies

### Backend
| Technologie | Version | Utilisation |
|-------------|---------|-------------|
| **Django** | 5.0+ | Framework web principal |
| **Django REST Framework** | 3.14+ | API REST |
| **PostgreSQL** | 15+ | Base de données |
| **django-simplejwt** | 5.3+ | Authentification JWT |
| **Pillow** | 10.0+ | Traitement d'images (KYC) |
| **django-cors-headers** | 4.3+ | Gestion CORS |

### Frontend
| Technologie | Version | Utilisation |
|-------------|---------|-------------|
| **Flutter** | 3.24+ | Framework mobile |
| **Dio** | 5.3+ | Client HTTP |
| **Provider** | 6.1+ | Gestion d'état |
| **Shared Preferences** | 2.2+ | Stockage local |
| **Image Picker** | 1.0+ | Sélection d'images |
| **QR Flutter** | 4.1+ | Génération QR codes |

---

## 🚀 Installation

### Prérequis
- **Python** 3.10+
- **Flutter** 3.24+
- **PostgreSQL** 15+
- **Git**

### 🔙 Configuration Backend

1. **Cloner le repository**
```bash
git clone https://github.com/mamadousy92i/money-transfer-app.git
cd money-transfer-app/backend
```

2. **Créer un environnement virtuel**
```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

3. **Installer les dépendances**
```bash
pip install -r requirements.txt
```

4. **Configuration de la base de données**
```bash
# Créer la base PostgreSQL
createdb money_transfer_db

# Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos paramètres
```

5. **Migrations et données initiales**
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py loaddata fixtures/initial_data.json
```

6. **Lancer le serveur de développement**
```bash
python manage.py runserver
```

### 📱 Configuration Frontend

1. **Naviguer vers le dossier frontend**
```bash
cd ../frontend
```

2. **Installer les dépendances Flutter**
```bash
flutter pub get
```

3. **Configuration de l'API**
```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000/api/v1/';
}
```

4. **Lancer l'application**
```bash
# Pour Android
flutter run

# Pour iOS (macOS uniquement)
flutter run -d ios

# Pour le web
flutter run -d chrome
```

---

## 📡 API Documentation

### Authentification

#### POST `/api/v1/auth/register/`
Inscription d'un nouvel utilisateur
```json
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "securePassword123",
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+221771234567"
}
```

#### POST `/api/v1/auth/login/`
Connexion utilisateur
```json
{
  "username": "johndoe",
  "password": "securePassword123"
}
```

#### Response
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com"
  }
}
```

### Transactions

#### POST `/api/v1/transactions/international/calculate-fees/`
Calcul des frais pour transfert international
```json
{
  "sender_country": "SN",
  "receiver_country": "FR",
  "amount": 100000,
  "currency": "XOF"
}
```

#### POST `/api/v1/transactions/international/send-money/`
Envoi d'argent international
```json
{
  "receiver_phone": "+33612345678",
  "receiver_country": "FR",
  "amount": 100000,
  "currency": "XOF",
  "receiver_name": "Marie Dupont"
}
```

### KYC

#### POST `/api/v1/kyc/upload-documents/`
Upload des documents KYC (multipart/form-data)
- `id_front`: Image recto CNI
- `id_back`: Image verso CNI  
- `selfie`: Photo selfie

---

## 📱 Captures d'écran

### Interface Mobile
<div align="center">

| Écran de connexion | Tableau de bord | Transfert d'argent |
|:------------------:|:---------------:|:------------------:|
| <img src="docs/screenshots/login.png" width="200"/> | <img src="docs/screenshots/dashboard.png" width="200"/> | <img src="docs/screenshots/transfer.png" width="200"/> |

| Historique | Notifications | Profil KYC |
|:----------:|:-------------:|:----------:|
| <img src="docs/screenshots/history.png" width="200"/> | <img src="docs/screenshots/notifications.png" width="200"/> | <img src="docs/screenshots/kyc.png" width="200"/> |

</div>

---

## 🧪 Tests

### Backend Tests
```bash
# Tests unitaires
python manage.py test

# Coverage
pip install coverage
coverage run --source='.' manage.py test
coverage report
coverage html
```

### Frontend Tests
```bash
# Tests unitaires Flutter
flutter test

# Tests d'intégration
flutter test integration_test/
```

---

## 🚀 Déploiement

### Backend (Django)
```bash
# Variables d'environnement de production
export DEBUG=False
export DATABASE_URL=postgresql://user:pass@host:port/db
export SECRET_KEY=your-secret-key

# Collecte des fichiers statiques
python manage.py collectstatic

# Déploiement avec Gunicorn
gunicorn money_transfer.wsgi:application
```

### Frontend (Flutter)
```bash
# Build Android APK
flutter build apk --release

# Build iOS (macOS uniquement)
flutter build ios --release

# Build Web
flutter build web
```

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez suivre ces étapes :

1. **Fork** le projet
2. **Créer** une branche feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** vos changements (`git commit -m 'Add some AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. **Ouvrir** une Pull Request

### Guidelines de Contribution
- Respecter le style de code existant
- Ajouter des tests pour les nouvelles fonctionnalités
- Mettre à jour la documentation si nécessaire
- Tester sur plusieurs plateformes (Android/iOS)

---

## 📈 Roadmap

- [ ] **Phase 1** : Intégration avec vrais services de paiement (Wave, Orange Money)
- [ ] **Phase 2** : Module de crypto-monnaies
- [ ] **Phase 3** : Application web (React/Vue)
- [ ] **Phase 4** : Intelligence artificielle pour détection de fraude
- [ ] **Phase 5** : Expansion vers d'autres pays africains

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👤 Auteur

**MAMADOU SY**
- GitHub: [@mamadousy92i](https://github.com/mamadousy92i)
- Email: 92mamadousy@gmail.com
- LinkedIn: [Mamadou SY](https://www.linkedin.com/in/mamadou-sy-02166829b/)

---

## 💰 Support

Si ce projet vous aide, n'hésitez pas à lui donner une ⭐ !

<div align="center">

**Fait avec ❤️ par MAMADOU SY pour faciliter les transferts d'argent en Afrique**

</div>
