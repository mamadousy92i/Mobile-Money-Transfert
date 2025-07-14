# transactions/urls.py - AVEC ENDPOINTS GATEWAYS SIMULÉS

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
    
    # ===== ENDPOINTS PRINCIPAUX AVEC GATEWAYS INTÉGRÉS =====
    path('send-money/', views.SendMoneyView.as_view(), name='send-money'),
    path('send-international/', views.send_money_international, name='send-international'),
    path('exchange-rates/', views.ExchangeRateView.as_view(), name='exchange-rates'),
    path('search/', views.TransactionSearchView.as_view(), name='transaction-search'),
    
    # ===== ENDPOINTS DE RETRAIT =====
    path('validate-code/', views.validate_transaction_code, name='validate-code'),
    path('complete-withdrawal/', views.complete_transaction_withdrawal, name='complete-withdrawal'),
    
    # ===== ENDPOINTS PUBLICS DE VÉRIFICATION =====
    path('code/<str:code>/', views.transaction_by_code, name='transaction-by-code'),
    path('status/<str:code>/', views.transaction_status_check, name='transaction-status-check'),
    
    # ===== ENDPOINTS INFO GATEWAYS =====
    path('gateway-info/', views.gateway_info, name='gateway-info'),
    
    # ===== ENDPOINTS DE TEST ET DEBUG =====
    path('test-gateway/', views.test_gateway_direct, name='test-gateway'),
    path('simulate-scenarios/', views.simulate_gateway_scenarios, name='simulate-scenarios'),
# ===== NOUVEAUX ENDPOINTS INTERNATIONAUX =====
    
    # Informations pays et services
    path('international/pays/', views.pays_disponibles, name='pays-disponibles'),
    path('international/pays/<str:pays_code>/services/', views.services_par_pays, name='services-par-pays'),
    path('international/corridors/', views.corridors_disponibles, name='corridors-disponibles'),
    
    # Calculs et envois internationaux
    path('international/calculate-fees/', views.calculer_frais_international, name='calculate-international-fees'),
    path('international/send-money/', views.send_money_international, name='send-money-international'),
    
    # Taux de change
    path('international/exchange-rates/', views.ExchangeRateView.as_view(), name='exchange-rates-international'),
    #path('international/exchange-rates/<str:from_currency>/<str:to_currency>/', views.get, name='specific-exchange-rate'),
    
    # Suivi transactions internationales
   # path('international/track/<str:code>/', views.track_international_transaction, name='track-international'),
]

# URLs générées automatiquement pour l'international :
"""
🌍 ENDPOINTS INTERNATIONAUX :

Informations générales :
GET /api/v1/transactions/international/pays/                           - Liste pays supportés
GET /api/v1/transactions/international/pays/COG/services/              - Services Congo
GET /api/v1/transactions/international/corridors/                      - Corridors actifs

Calculs :
POST /api/v1/transactions/international/calculate-fees/                - Calculer frais
{
  "montant": 50000,
  "corridor": "SEN_TO_COG", 
  "service_destination": "MTN_CG"
}

Envoi international :
POST /api/v1/transactions/international/send-money/                    - Envoyer international
{
  "destinataire_phone": "+243811234567",
  "montant": 50000,
  "pays_destination": "COG",
  "service_destination": "MTN_CG",
  "canal_paiement_id": "uuid"
}

Taux de change :
GET /api/v1/transactions/international/exchange-rates/                 - Tous les taux
GET /api/v1/transactions/international/exchange-rates/XOF/CDF/         - Taux spécifique

Suivi :
GET /api/v1/transactions/international/track/TXN2025123456/            - Suivi détaillé
"""
# URLs générées automatiquement par le router avec GATEWAYS INTÉGRÉS :
"""
🔐 AUTHENTIFIÉES (JWT Token requis):

Transactions avec gateways simulés:
GET    /api/v1/transactions/transactions/                     - Mes transactions (avec info gateway)
POST   /api/v1/transactions/transactions/                     - Créer transaction avec simulation gateway
GET    /api/v1/transactions/transactions/{id}/                - Détail transaction avec gateway info
PATCH  /api/v1/transactions/transactions/{id}/update_status/ - Changer statut
GET    /api/v1/transactions/transactions/statistics/          - Statistiques avec répartition gateways
GET    /api/v1/transactions/transactions/mes_retraits_disponibles/ - Retraits disponibles

Bénéficiaires:
GET    /api/v1/transactions/beneficiaires/                    - Mes bénéficiaires
POST   /api/v1/transactions/beneficiaires/                    - Ajouter bénéficiaire
GET    /api/v1/transactions/beneficiaires/{id}/               - Détail bénéficiaire
PUT    /api/v1/transactions/beneficiaires/{id}/               - Modifier bénéficiaire
DELETE /api/v1/transactions/beneficiaires/{id}/               - Supprimer bénéficiaire

Envoi d'argent avec simulation:
POST   /api/v1/transactions/send-money/                       - Envoi avec simulation Wave/Orange Money
GET    /api/v1/transactions/search/?q=TXN123                  - Recherche transactions
POST   /api/v1/transactions/validate-code/                    - Valider code retrait
POST   /api/v1/transactions/complete-withdrawal/              - Finaliser retrait

🌐 PUBLIQUES (pas d'auth requise):

Canaux et gateways:
GET    /api/v1/transactions/canaux/                           - Liste canaux avec info gateways
GET    /api/v1/transactions/canaux/{id}/                      - Détail canal
GET    /api/v1/transactions/canaux/by_country/                - Canaux par pays
GET    /api/v1/transactions/canaux/gateway_status/            - Statut des gateways simulés

Informations générales:
GET    /api/v1/transactions/exchange-rates/                   - Taux de change
GET    /api/v1/transactions/code/TXN2025123456/               - Transaction par code
GET    /api/v1/transactions/status/TXN2025123456/             - Statut par code

🔧 ENDPOINTS DE TEST ET DEBUG:

Tests gateways:
GET    /api/v1/transactions/gateway-info/                     - Info tous les gateways
GET    /api/v1/transactions/gateway-info/?type=WAVE          - Info gateway spécifique
POST   /api/v1/transactions/test-gateway/                     - Test direct gateway
POST   /api/v1/transactions/simulate-scenarios/               - Simuler scénarios spécifiques

Paramètres de test pour simulate-scenarios:
{
  "scenario": "success|insufficient_funds|invalid_phone|timeout|service_unavailable",
  "gateway_type": "WAVE|ORANGE_MONEY",
  "phone": "+221771234567",
  "amount": 10000
}

📊 NOUVEAUX FILTRES DISPONIBLES:

Transactions:
GET /api/v1/transactions/transactions/?gateway=WAVE           - Filtrer par gateway
GET /api/v1/transactions/transactions/?status=ENVOYE         - Filtrer par statut
GET /api/v1/transactions/transactions/?type=sent             - Mes envois
GET /api/v1/transactions/transactions/?type=received         - Mes réceptions

🎯 WORKFLOW COMPLET AVEC GATEWAYS:

1. Inscription/Connexion:
   POST /api/auth/register/
   POST /api/auth/login/

2. Voir les canaux disponibles:
   GET /api/v1/transactions/canaux/

3. Envoyer de l'argent (avec simulation):
   POST /api/v1/transactions/send-money/
   {
     "beneficiaire_phone": "+221771234567",
     "montant": 15000,
     "canal_paiement": "uuid-du-canal"
   }

4. Vérifier le statut:
   GET /api/v1/transactions/transactions/

5. Retrait (si destinataire):
   POST /api/v1/transactions/validate-code/
   POST /api/v1/transactions/complete-withdrawal/

🚀 RÉPONSES AVEC GATEWAYS:

Transaction réussie:
{
  "success": true,
  "message": "✅ Transaction Wave réussie - Prête pour retrait",
  "transaction_id": "uuid",
  "code_transaction": "TXN2025123456",
  "status": "ENVOYE",
  "gateway_utilise": "Wave",
  "ready_for_withdrawal": true
}

Transaction échouée:
{
  "success": false,
  "message": "❌ Transaction Orange Money échouée - Solde insuffisant",
  "transaction_id": "uuid",
  "code_transaction": "TXN2025123457", 
  "status": "ANNULE",
  "gateway_utilise": "Orange Money"
}
"""