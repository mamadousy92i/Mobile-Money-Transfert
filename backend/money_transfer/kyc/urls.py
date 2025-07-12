from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import KYCDocumentUploadView, KYCStatusView, KYCAdminViewSet

# Create a router for admin viewset
router = DefaultRouter()
router.register(r'admin', KYCAdminViewSet)

# URL patterns for KYC app
urlpatterns = [
    path('upload/', KYCDocumentUploadView.as_view(), name='kyc-upload'),
    path('status/', KYCStatusView.as_view(), name='kyc-status'),
    path('', include(router.urls)),
]
