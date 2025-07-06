from rest_framework import permissions


class IsOwner(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object to access it.
    """
    
    def has_object_permission(self, request, view, obj):
        # Check if the user is trying to access their own profile
        return obj.id == request.user.id


class IsVerifiedUser(permissions.BasePermission):
    """
    Custom permission to only allow users with verified KYC status.
    """
    
    def has_permission(self, request, view):
        # Check if user is authenticated and has verified KYC status
        return request.user.is_authenticated and request.user.kyc_status == request.user.KYCStatus.VERIFIED
