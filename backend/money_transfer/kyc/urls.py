from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import KYCDocumentUploadView, KYCStatusView, KYCAdminViewSet

# Création d'un routeur pour le viewset admin
router = DefaultRouter()
router.register(r'admin', KYCAdminViewSet)

# Modèles d'URL pour l'application KYC
urlpatterns = [
    path('upload/', KYCDocumentUploadView.as_view(), name='kyc-upload'),
    path('status/', KYCStatusView.as_view(), name='kyc-status'),
    path('', include(router.urls)),
]
