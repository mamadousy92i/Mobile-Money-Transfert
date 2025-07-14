from rest_framework import serializers
from .models import KYCDocument
from authentication.models import User


class KYCDocumentSerializer(serializers.ModelSerializer):
    """Sérialiseur pour le téléchargement et la vérification du statut des documents KYC."""
    
    user_full_name = serializers.SerializerMethodField()
    status_display = serializers.SerializerMethodField()
    document_type_display = serializers.SerializerMethodField()
    
    class Meta:
        model = KYCDocument
        fields = [
            'id', 'user', 'user_full_name', 'document_type', 'document_type_display',
            'document_number', 'document_image', 'status', 'status_display', 'submitted_at'
        ]
        read_only_fields = ['status', 'submitted_at', 'user']
    
    def get_user_full_name(self, obj):
        return obj.user.get_full_name()
    
    def get_status_display(self, obj):
        return obj.get_status_display()
    
    def get_document_type_display(self, obj):
        return obj.get_document_type_display()
    
    def create(self, validated_data):
        # Définir l'utilisateur comme l'utilisateur authentifié actuel
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)


class KYCDocumentAdminSerializer(KYCDocumentSerializer):
    """Sérialiseur pour les opérations administratives sur les documents KYC."""
    
    class Meta(KYCDocumentSerializer.Meta):
        read_only_fields = ['document_type', 'document_number', 'document_image', 'submitted_at', 'user']


class UserKYCStatusSerializer(serializers.ModelSerializer):
    """Sérialiseur pour le statut KYC de l'utilisateur."""
    
    kyc_status_display = serializers.SerializerMethodField()
    kyc_documents = KYCDocumentSerializer(many=True, read_only=True)
    
    class Meta:
        model = User
        fields = ['id', 'kyc_status', 'kyc_status_display', 'kyc_documents']
        read_only_fields = ['kyc_status']
    
    def get_kyc_status_display(self, obj):
        return obj.get_kyc_status_display()
