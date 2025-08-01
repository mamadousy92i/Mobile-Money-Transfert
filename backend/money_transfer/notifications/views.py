from rest_framework import viewsets, permissions, status, generics, mixins
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from .models import Notification
from .serializers import NotificationSerializer, AdminNotificationSerializer


class IsOwnerOrAdmin(permissions.BasePermission):
    """
    Permission personnalisée pour permettre uniquement aux propriétaires d'une notification ou aux administrateurs de la consulter.
    """
    def has_object_permission(self, request, view, obj):
        # Autoriser les utilisateurs administrateurs
        if request.user.is_staff:
            return True
        
        # Vérifier si l'objet a un attribut utilisateur
        if hasattr(obj, 'user'):
            return obj.user == request.user
        
        return False


class NotificationViewSet(mixins.ListModelMixin,
                          mixins.RetrieveModelMixin,
                          mixins.CreateModelMixin,
                          viewsets.GenericViewSet):
    """
    Ensemble de vues API pour les notifications.
    GET: Liste les notifications pour l'utilisateur actuel
    POST: Crée une notification (admin uniquement)
    """
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        """
        Retourne les notifications pour l'utilisateur connecté.
        Filtre par statut si le paramètre 'status' est fourni.
        """
        # On commence par récupérer toutes les notifications de l'utilisateur
        queryset = Notification.objects.filter(user=self.request.user)
        
        # On récupère le filtre depuis l'URL (ex: "?status=UNREAD")
        status_filter = self.request.query_params.get('status', None)
        
        # ▼▼▼ CORRECTION DE LA LOGIQUE DE FILTRAGE ▼▼▼
        if status_filter:
            # Si le filtre est "UNREAD", on applique le filtre.
            # On vérifie aussi en majuscules pour être sûr.
            if status_filter.upper() == 'UNREAD':
                queryset = queryset.filter(status='UNREAD')
            # On pourrait ajouter d'autres filtres ici plus tard (ex: 'READ')
        
        # Si aucun filtre n'est passé, on ne filtre pas et on retourne tout.
            
        return queryset.order_by('-created_at')
    
    
    def get_serializer_class(self):
        if self.request.method == 'POST' and self.request.user.is_staff:
            return AdminNotificationSerializer
        return NotificationSerializer
    
    def create(self, request, *args, **kwargs):
        # Seuls les administrateurs peuvent créer des notifications
        if not request.user.is_staff:
            return Response(
                {'detail': 'Vous n\'avez pas la permission de créer des notifications.'},
                status=status.HTTP_403_FORBIDDEN
            )
        return super().create(request, *args, **kwargs)
    
    @action(detail=True, methods=['patch'])
    def read(self, request, pk=None):
        """Marquer une notification comme lue."""
        notification = self.get_object()
        
        # Vérifier si l'utilisateur est le propriétaire ou un administrateur
        if notification.user != request.user and not request.user.is_staff:
            return Response(
                {'detail': 'Vous n\'avez pas la permission de marquer cette notification comme lue.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        notification.mark_as_read()
        serializer = self.get_serializer(notification)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """
        Retourne le nombre de notifications non lues pour l'utilisateur connecté.
        """
        count = Notification.objects.filter(user=request.user, status='UNREAD').count()
        return Response({'unread_count': count})
    
    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        """
        Marque une notification spécifique comme lue.
        """
        try:
            notification = self.get_queryset().get(pk=pk)
            if notification.status == 'UNREAD':
                notification.status = 'READ'
                notification.save()
            return Response({'status': 'notification marked as read'}, status=status.HTTP_200_OK)
        except Notification.DoesNotExist:
            return Response({'error': 'Notification not found.'}, status=status.HTTP_404_NOT_FOUND)
        
    @action(detail=False, methods=['post'])
    def delete_multiple(self, request):
        """
        Supprime plusieurs notifications en une seule fois.
        Attend une liste d'IDs : {"ids": [1, 2, 3]}
        """
        ids_to_delete = request.data.get('ids', [])
        if not isinstance(ids_to_delete, list):
            return Response({'error': 'Une liste d\'IDs est requise.'}, status=status.HTTP_400_BAD_REQUEST)

        # On ne supprime que les notifications appartenant à l'utilisateur
        count, _ = self.get_queryset().filter(pk__in=ids_to_delete).delete()

        return Response({'status': f'{count} notifications supprimées.'}, status=status.HTTP_204_NO_CONTENT)


# Classe de base abstraite pour les canaux de notification
class NotificationChannel:
    """
    Classe de base abstraite pour les canaux de notification.
    Peut être étendue pour SMS, FCM, etc.
    """
    def send(self, user, title, message, notification_type='INFO'):
        """Envoyer une notification via le canal."""
        raise NotImplementedError('Les sous-classes doivent implémenter send()')


class DatabaseNotificationChannel(NotificationChannel):
    """Implémentation du canal de notification en base de données."""
    def send(self, user, title, message, notification_type='INFO'):
        """Créer une notification dans la base de données."""
        return Notification.objects.create(
            user=user,
            title=title,
            message=message,
            notification_type=notification_type,
            auto_sent=True
        )


# Fabrique pour obtenir des canaux de notification
class NotificationChannelFactory:
    """Fabrique pour créer des instances de canaux de notification."""
    @staticmethod
    def get_channel(channel_type='database'):
        """Obtenir un canal de notification par type."""
        channels = {
            'database': DatabaseNotificationChannel,
            # Ajouter plus de canaux ici au fur et à mesure de leur implémentation
            # 'sms': SMSNotificationChannel,
            # 'fcm': FCMNotificationChannel,
        }
        
        channel_class = channels.get(channel_type.lower())
        if not channel_class:
            raise ValueError(f'Canal de notification non pris en charge: {channel_type}')
        
        return channel_class()
