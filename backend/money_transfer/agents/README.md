# Application Agents

## Aperçu
L'application Agents gère le réseau d'agents locaux qui facilitent les retraits d'espèces pour le système de Transfert d'Argent. Elle fournit des fonctionnalités pour l'inscription des agents, la vérification, la gestion et l'intégration avec le processus de retrait.

## Fonctionnalités
- **Gestion des Agents**: Inscription, vérification et gestion des agents locaux
- **Liaison Utilisateur-Agent**: Association entre les comptes utilisateurs et les profils d'agents
- **Intégration KYC**: Vérification de l'identité de l'agent et des documents commerciaux
- **Services de Géolocalisation**: Découverte et cartographie des agents basées sur la localisation
- **Gestion de la Disponibilité**: Heures d'ouverture des agents et suivi du statut de service
- **Calcul de Commission**: Traitement automatisé des commissions des agents
- **Limites de Transaction**: Gestion des limites de transaction et de solde des agents
- **Métriques de Performance**: Suivi de l'activité et de la performance des agents

## Modèles de Données

### AgentLocal
Représente un agent local dans le système:
- Lien vers le compte utilisateur
- Informations commerciales (nom, adresse, détails d'enregistrement)
- Coordonnées de géolocalisation
- Heures d'ouverture et statut de disponibilité
- Taux de commission et détails de paiement
- Limites de transaction et solde actuel
- Statut de vérification et historique
- Métriques de performance et évaluations

## API Endpoints

### Liste des Agents Actifs
```
GET /api/agents/
```
Retourne la liste des agents actifs, avec possibilité de filtrage:
- Par proximité (latitude, longitude, rayon)
- Par nom ou adresse de recherche
- Par statut de disponibilité

Paramètres de requête:
- `latitude`: Coordonnée de latitude décimale
- `longitude`: Coordonnée de longitude décimale
- `radius`: Rayon de recherche en kilomètres
- `search`: Recherche de texte sur le nom ou l'adresse

### Détails de l'Agent
```
GET /api/agents/{id}/
```
Retourne les informations détaillées sur un agent spécifique:
- Informations de contact
- Heures d'ouverture
- Statut de disponibilité actuel
- Taux de commission
- Limites de transaction

## Intégration avec d'autres Applications
L'application Agents s'intègre avec:
- **Authentification**: Pour la liaison des comptes utilisateurs
- **KYC**: Pour la vérification de l'identité
- **Transactions**: Pour l'historique des transactions et le calcul des commissions
- **Retraits**: Pour la gestion des retraits d'espèces
- **Tableau de Bord**: Pour les métriques de performance des agents

## Utilisation

### Recherche d'Agents à Proximité
Pour trouver des agents près d'un emplacement spécifique:

```python
import requests

# Trouver des agents dans un rayon de 5km des coordonnées
response = requests.get(
    'https://api.example.com/api/agents/',
    params={
        'latitude': 14.7167,
        'longitude': -17.4677,
        'radius': 5,  # en kilomètres
        'available': True  # uniquement les agents actuellement disponibles
    },
    headers={'Authorization': 'Bearer VOTRE_TOKEN_ACCES'}
)

# Traiter la réponse
if response.status_code == 200:
    agents = response.json()
    for agent in agents:
        print(f"Agent: {agent['business_name']}")
        print(f"Distance: {agent['distance']:.2f} km")
        print(f"Évaluation: {agent['rating']}/5")
        print("---")
```

## Bonnes Pratiques
- Toujours vérifier la disponibilité de l'agent avant de diriger les utilisateurs
- Considérer les limites de transaction de l'agent lors du traitement des retraits importants
- Utiliser la recherche de proximité pour minimiser la distance de déplacement des utilisateurs
- Vérifier le statut de vérification de l'agent avant d'autoriser les transactions

## Contributeurs
Développé par l'Équipe Backend de Transfert d'Argent.

## Licence
Cette application est propriétaire et confidentielle. Toute utilisation non autorisée est interdite.
