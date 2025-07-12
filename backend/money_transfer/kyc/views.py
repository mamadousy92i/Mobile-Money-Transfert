from rest_framework import viewsets, permissions, status, generics
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import KYCDocument
from .serializers import KYCDocumentSerializer, KYCDocumentAdminSerializer, UserKYCStatusSerializer
from authentication.models import User


class IsOwnerOrAdmin(permissions.BasePermission):
    """
    Custom permission to only allow owners of a KYC document or admins to view it.
    """
    def has_object_permission(self, request, view, obj):
        # Allow admin users
        if request.user.is_staff:
            return True
        
        # Check if the object has a user attribute
        if hasattr(obj, 'user'):
            return obj.user == request.user
        
        return False


class KYCDocumentUploadView(generics.CreateAPIView):
    """
    API view for uploading KYC documents.
    """
    serializer_class = KYCDocumentSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class KYCStatusView(generics.RetrieveAPIView):
    """
    API view for checking KYC status of the current user.
    """
    serializer_class = UserKYCStatusSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self):
        return self.request.user


class KYCAdminViewSet(viewsets.ModelViewSet):
    """
    API viewset for admin operations on KYC documents.
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
        """Return all pending KYC documents."""
        pending_docs = KYCDocument.objects.filter(status=KYCDocument.Status.PENDING)
        serializer = self.get_serializer(pending_docs, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def verify(self, request, pk=None):
        """Mark a KYC document as verified."""
        document = self.get_object()
        document.status = KYCDocument.Status.VERIFIED
        document.save()
        
        # Update user's KYC status
        user = document.user
        user.kyc_status = User.KYCStatus.VERIFIED
        user.save()
        
        serializer = self.get_serializer(document)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        """Mark a KYC document as rejected."""
        document = self.get_object()
        document.status = KYCDocument.Status.REJECTED
        document.save()
        
        # Update user's KYC status
        user = document.user
        user.kyc_status = User.KYCStatus.REJECTED
        user.save()
        
        serializer = self.get_serializer(document)
        return Response(serializer.data)
