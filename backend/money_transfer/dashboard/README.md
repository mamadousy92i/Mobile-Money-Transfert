# Application Tableau de Bord

## Aperçu
L'application Tableau de Bord fournit des statistiques consolidées et des analyses pour le système de Transfert d'Argent. Elle agrège les données de différentes parties de la plateforme pour donner aux administrateurs et aux utilisateurs professionnels une vue complète de l'activité du système, des volumes de transactions, de la croissance des utilisateurs et d'autres indicateurs clés de performance.

## Fonctionnalités
- **Statistiques Quotidiennes**: Résumé quotidien consolidé des transactions, utilisateurs et métriques financières
- **Surveillance en Temps Réel**: Informations à jour sur l'activité du système
- **Suivi de la Croissance des Utilisateurs**: Analyse des modèles d'inscription et d'activité des utilisateurs
- **Analyse du Volume des Transactions**: Répartition des volumes de transactions par type, région et méthode de paiement
- **Rapports sur les Revenus et les Frais**: Rapports financiers sur les revenus de la plateforme et la collecte des frais
- **Aperçus du Réseau d'Agents**: Statistiques sur l'activité et la distribution des agents
- **Performance des Passerelles de Paiement**: Métriques sur l'utilisation des passerelles et les taux de réussite
- **Suivi des Transferts Internationaux**: Surveillance des corridors de transactions transfrontalières

## Modèles de Données

### DashboardStats
Stocke des statistiques agrégées pour une récupération et un affichage rapides:
- Date de collecte des statistiques
- Nombre total et volume des transactions
- Nombre d'utilisateurs (nouveaux et actifs)
- Nombre d'agents et métriques d'activité
- Statistiques d'utilisation des passerelles
- Métriques de transfert international
- Totaux des revenus et des frais transaction analytics
- Withdrawal statistics

Le modèle inclut des méthodes pour:
- Calculer les statistiques quotidiennes
- Comparer les métriques sur des périodes de temps
- Générer des rapports d'évolution
- Fournir des statistiques en temps réel avec des indicateurs de tendance

## API Endpoints

### Résumé du Tableau de Bord
```
GET /api/dashboard/summary/
```
Renvoie un résumé complet des statistiques du jour avec comparaison à la veille:
- Nombre et volume des transactions
- Nouvelles inscriptions d'utilisateurs
- Agents actifs
- Répartition des passerelles de paiement
- Métriques de retrait

### Statistiques Hebdomadaires
```
GET /api/dashboard/weekly/
```
Renvoie des statistiques agrégées pour les 7 derniers jours:
- Volumes de transactions quotidiens
- Tendances de croissance des utilisateurs
- Métriques de revenus
- Performance des passerelles
- Activité des corridors de transactions internationaux

## Intégration avec d'autres Applications
L'application Tableau de Bord s'intègre avec:
- **Transactions**: Pour les volumes, les nombres et les statuts des transactions
- **Authentification**: Pour les données d'inscription et d'activité des utilisateurs
- **Agents**: Pour les métriques de performance des agents
- **Passerelles de Paiement**: Pour les statistiques d'utilisation des passerelles
- **Retraits**: Pour les métriques de retrait et la performance des agents

## Utilisation

### Accès aux Données du Tableau de Bord
Pour récupérer les statistiques du tableau de bord:

```python
import requests

# Obtenir le résumé quotidien
response = requests.get(
    'https://api.example.com/api/dashboard/summary/',
    headers={'Authorization': 'Bearer VOTRE_TOKEN_ACCES'}
)

# Traiter la réponse
if response.status_code == 200:
    dashboard_data = response.json()
    print(f"Transactions aujourd'hui: {dashboard_data['transaction_count']}")
    print(f"Nouveaux utilisateurs aujourd'hui: {dashboard_data['new_users']}")
```

## Meilleures Pratiques

1. **Mise en Cache**: Les données du tableau de bord doivent être mises en cache pour améliorer les performances, en particulier pour les métriques fréquemment consultées
2. **Mises à Jour Programmées**: Configurer des tâches en arrière-plan pour pré-calculer les statistiques à intervalles réguliers
3. **Agrégation de Données**: Stocker des données agrégées plutôt que de calculer des métriques à la volée
4. **Contrôle d'Accès**: Implémenter des permissions appropriées pour garantir que seuls les utilisateurs autorisés peuvent accéder aux métriques commerciales sensibles
5. **Filtrage par Date**: Toujours fournir des options pour filtrer les données du tableau de bord par plages de dates

## Contributeurs
- Équipe de Développement
- Équipe d'Analyse de Données

## License
Ce module fait partie de l'application de Transfert d'Argent et est soumis aux mêmes conditions de licence.
