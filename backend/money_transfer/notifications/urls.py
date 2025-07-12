from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import NotificationViewSet

# Create a router for the notification viewset
router = DefaultRouter()
router.register(r'', NotificationViewSet, basename='notification')

# URL patterns for notifications app
urlpatterns = [
    path('', include(router.urls)),
]
