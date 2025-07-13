# money_transfer/urls.py (URLs principales du projet)

from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.documentation import include_docs_urls

urlpatterns = [
    # Admin Django
    path('admin/', admin.site.urls),
    
    # APIs par version
    path('api/kyc/', include('kyc.urls')),                  # ⭐ NOUVEAU
    path('api/notifications/', include('notifications.urls')), # ⭐ NOUVEAU
    path('api/v1/transactions/', include('transactions.urls')),  # Dev 2 (TOI)
    path('api/auth/', include('authentication.urls')),
]

# Servir les fichiers media en développement
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)


# URLs complètes finales :
"""
Admin:
http://127.0.0.1:8000/admin/

APIs Dev 2 (Transactions):
http://127.0.0.1:8000/api/v1/transactions/
http://127.0.0.1:8000/api/v1/transactions/send-money/
http://127.0.0.1:8000/api/v1/transactions/beneficiaires/
http://127.0.0.1:8000/api/v1/transactions/canaux/
http://127.0.0.1:8000/api/v1/transactions/exchange-rates/
http://127.0.0.1:8000/api/v1/transactions/search/

APIs Dev 1 (Authentication - à venir):
http://127.0.0.1:8000/api/v1/auth/login/
http://127.0.0.1:8000/api/v1/auth/register/

APIs Dev 3 (Agents - à venir):
http://127.0.0.1:8000/api/v1/agents/
http://127.0.0.1:8000/api/v1/agents/nearby/

Documentation:
http://127.0.0.1:8000/docs/
"""