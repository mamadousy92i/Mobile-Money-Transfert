# transactions/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

# Router pour les ViewSets (CRUD automatique)
router = DefaultRouter()
router.register(r'transactions', views.TransactionViewSet, basename='transaction')
router.register(r'beneficiaires', views.BeneficiaireViewSet, basename='beneficiaire')
router.register(r'canaux', views.CanalPaiementViewSet, basename='canal-paiement')

# URLs personnalisées
urlpatterns = [
    # URLs automatiques des ViewSets
    path('', include(router.urls)),
    
    # Endpoints spéciaux pour l'envoi d'argent
    path('send-money/', views.SendMoneyView.as_view(), name='send-money'),
    
    # Taux de change
    path('exchange-rates/', views.ExchangeRateView.as_view(), name='exchange-rates'),
    
    # Recherche de transactions
    path('search/', views.TransactionSearchView.as_view(), name='transaction-search'),
    
    # Endpoints par code de transaction (utilitaires)
    path('code/<str:code>/', views.transaction_by_code, name='transaction-by-code'),
    path('status/<str:code>/', views.transaction_status_check, name='transaction-status-check'),
]

# URLs générées automatiquement par le router :
"""
Transactions:
GET    /api/v1/transactions/                    - Liste toutes les transactions
POST   /api/v1/transactions/                    - Créer une transaction
GET    /api/v1/transactions/{id}/               - Détail d'une transaction
PUT    /api/v1/transactions/{id}/               - Modifier une transaction (complet)
PATCH  /api/v1/transactions/{id}/               - Modifier une transaction (partiel)
DELETE /api/v1/transactions/{id}/               - Supprimer une transaction
GET    /api/v1/transactions/statistics/         - Statistiques (action custom)
PATCH  /api/v1/transactions/{id}/update_status/ - Changer statut (action custom)

Bénéficiaires:
GET    /api/v1/beneficiaires/                   - Liste tous les bénéficiaires
POST   /api/v1/beneficiaires/                   - Créer un bénéficiaire
GET    /api/v1/beneficiaires/{id}/              - Détail d'un bénéficiaire
PUT    /api/v1/beneficiaires/{id}/              - Modifier un bénéficiaire (complet)
PATCH  /api/v1/beneficiaires/{id}/              - Modifier un bénéficiaire (partiel)
DELETE /api/v1/beneficiaires/{id}/              - Supprimer un bénéficiaire

Canaux de paiement:
GET    /api/v1/canaux/                          - Liste tous les canaux actifs
GET    /api/v1/canaux/{id}/                     - Détail d'un canal
GET    /api/v1/canaux/by_country/               - Filtrer par pays (action custom)

Endpoints personnalisés:
POST   /api/v1/send-money/                      - Envoi d'argent simplifié
GET    /api/v1/exchange-rates/                  - Taux de change
GET    /api/v1/search/?q=TXN123                 - Recherche transactions
GET    /api/v1/code/TXN2025123456/              - Transaction par code
GET    /api/v1/status/TXN2025123456/            - Statut par code
"""