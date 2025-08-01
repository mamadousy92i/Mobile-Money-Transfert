# reception/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ReceptionViewSet

router = DefaultRouter()
router.register(r'', ReceptionViewSet, basename='reception')

urlpatterns = [
    path('', include(router.urls)),
]