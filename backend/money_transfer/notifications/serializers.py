from rest_framework import serializers
from .models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    """Sérialiseur pour les notifications utilisateur."""
    
    notification_type_display = serializers.SerializerMethodField()
    status_display = serializers.SerializerMethodField()
    
    class Meta:
        model = Notification
        fields = [
            'id', 'user', 'title', 'message', 'notification_type', 
            'notification_type_display', 'status', 'status_display', 
            'auto_sent', 'created_at', 'seen_at'
        ]
        read_only_fields = ['status', 'created_at', 'seen_at']
    
    def get_notification_type_display(self, obj):
        return obj.get_notification_type_display()
    
    def get_status_display(self, obj):
        return obj.get_status_display()
    
    def create(self, validated_data):
        # Définir auto_sent à False pour les notifications créées manuellement
        if 'auto_sent' not in validated_data:
            validated_data['auto_sent'] = False
        return super().create(validated_data)


class AdminNotificationSerializer(NotificationSerializer):
    """Sérialiseur permettant à l'administrateur de créer des notifications."""
    
    class Meta(NotificationSerializer.Meta):
        read_only_fields = ['created_at', 'seen_at']  # L'administrateur peut définir le statut
