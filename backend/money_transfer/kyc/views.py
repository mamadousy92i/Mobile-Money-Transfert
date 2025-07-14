from rest_framework import viewsets, permissions, status, generics
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import KYCDocument
from .serializers import KYCDocumentSerializer, KYCDocumentAdminSerializer, UserKYCStatusSerializer
from authentication.models import User


class IsOwnerOrAdmin(permissions.BasePermission):
    """
    Permission personnalisée pour permettre uniquement aux propriétaires d'un document KYC ou aux administrateurs de le consulter.
    """
    def has_object_permission(self, request, view, obj):
        # Autoriser les utilisateurs administrateurs
        if request.user.is_staff:
            return True
        
        # Vérifier si l'objet a un attribut utilisateur
        if hasattr(obj, 'user'):
            return obj.user == request.user
        
        return False


class KYCDocumentUploadView(generics.CreateAPIView):
    """
    Vue API pour le téléchargement des documents KYC.
    """
    serializer_class = KYCDocumentSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class KYCStatusView(generics.RetrieveAPIView):
    """
    Vue API pour vérifier le statut KYC de l'utilisateur actuel.
    """
    serializer_class = UserKYCStatusSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self):
        return self.request.user


class KYCAdminViewSet(viewsets.ModelViewSet):
    """
    Ensemble de vues API pour les opérations administratives sur les documents KYC.
    """
    queryset = KYCDocument.objects.all().order_by('-submitted_at')
    serializer_class = KYCDocumentAdminSerializer
    permission_classes = [permissions.IsAdminUser]
    
    def get_serializer_class(self):
        if self.action in ['update', 'partial_update']:
            return KYCDocumentAdminSerializer
        return KYCDocumentSerializer
    
    @action(detail=False, methods=['get'])
    def pending(self, request):
        """Renvoie tous les documents KYC en attente."""
        pending_docs = KYCDocument.objects.filter(status=KYCDocument.Status.PENDING)
        serializer = self.get_serializer(pending_docs, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def verify(self, request, pk=None):
        """Marquer un document KYC comme vérifié."""
        document = self.get_object()
        document.status = KYCDocument.Status.VERIFIED
        document.save()
        
        # Mettre à jour le statut KYC de l'utilisateur
        user = document.user
        user.kyc_status = User.KYCStatus.VERIFIED
        user.save()
        
        serializer = self.get_serializer(document)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        """Marquer un document KYC comme rejeté."""
        document = self.get_object()
        document.status = KYCDocument.Status.REJECTED
        document.save()
        
        # Mettre à jour le statut KYC de l'utilisateur
        user = document.user
        user.kyc_status = User.KYCStatus.REJECTED
        user.save()
        
        serializer = self.get_serializer(document)
        return Response(serializer.data)
