from rest_framework import viewsets, permissions, status, generics, mixins
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from .models import Notification
from .serializers import NotificationSerializer, AdminNotificationSerializer


class IsOwnerOrAdmin(permissions.BasePermission):
    """
    Custom permission to only allow owners of a notification or admins to view it.
    """
    def has_object_permission(self, request, view, obj):
        # Allow admin users
        if request.user.is_staff:
            return True
        
        # Check if the object has a user attribute
        if hasattr(obj, 'user'):
            return obj.user == request.user
        
        return False


class NotificationViewSet(mixins.ListModelMixin,
                          mixins.RetrieveModelMixin,
                          mixins.CreateModelMixin,
                          viewsets.GenericViewSet):
    """
    API viewset for notifications.
    GET: List notifications for current user
    POST: Create notification (admin only)
    """
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        # Admin can see all notifications, regular users only see their own
        if user.is_staff:
            return Notification.objects.all().order_by('-created_at')
        return Notification.objects.filter(user=user).order_by('-created_at')
    
    def get_serializer_class(self):
        if self.request.method == 'POST' and self.request.user.is_staff:
            return AdminNotificationSerializer
        return NotificationSerializer
    
    def create(self, request, *args, **kwargs):
        # Only admins can create notifications
        if not request.user.is_staff:
            return Response(
                {'detail': 'You do not have permission to create notifications.'},
                status=status.HTTP_403_FORBIDDEN
            )
        return super().create(request, *args, **kwargs)
    
    @action(detail=True, methods=['patch'])
    def read(self, request, pk=None):
        """Mark a notification as read."""
        notification = self.get_object()
        
        # Check if the user is the owner or an admin
        if notification.user != request.user and not request.user.is_staff:
            return Response(
                {'detail': 'You do not have permission to mark this notification as read.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        notification.mark_as_read()
        serializer = self.get_serializer(notification)
        return Response(serializer.data)


# Abstract base class for notification channels
class NotificationChannel:
    """
    Abstract base class for notification channels.
    This can be extended for SMS, FCM, etc.
    """
    def send(self, user, title, message, notification_type='INFO'):
        """Send notification through the channel."""
        raise NotImplementedError('Subclasses must implement send()')


class DatabaseNotificationChannel(NotificationChannel):
    """Database notification channel implementation."""
    def send(self, user, title, message, notification_type='INFO'):
        """Create a notification in the database."""
        return Notification.objects.create(
            user=user,
            title=title,
            message=message,
            notification_type=notification_type,
            auto_sent=True
        )


# Factory for getting notification channels
class NotificationChannelFactory:
    """Factory for creating notification channel instances."""
    @staticmethod
    def get_channel(channel_type='database'):
        """Get notification channel by type."""
        channels = {
            'database': DatabaseNotificationChannel,
            # Add more channels here as they are implemented
            # 'sms': SMSNotificationChannel,
            # 'fcm': FCMNotificationChannel,
        }
        
        channel_class = channels.get(channel_type.lower())
        if not channel_class:
            raise ValueError(f'Unsupported notification channel: {channel_type}')
        
        return channel_class()
