from rest_framework import permissions


class IsOwner(permissions.BasePermission):
    """
    Permission personnalisée pour permettre uniquement aux propriétaires d'un objet d'y accéder.
    """
    
    def has_object_permission(self, request, view, obj):
        # Vérifie si l'utilisateur essaie d'accéder à son propre profil
        return obj.id == request.user.id


class IsVerifiedUser(permissions.BasePermission):
    """
    Permission personnalisée pour permettre uniquement aux utilisateurs avec un statut KYC vérifié.
    """
    
    def has_permission(self, request, view):
        # Vérifie si l'utilisateur est authentifié et a un statut KYC vérifié
        return request.user.is_authenticated and request.user.kyc_status == request.user.KYCStatus.VERIFIED
