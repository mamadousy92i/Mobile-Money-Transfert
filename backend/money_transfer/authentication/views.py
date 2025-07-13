from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from django.contrib.auth import get_user_model

from .serializers import (
    UserSerializer,
    UserRegistrationSerializer,
    UserProfileUpdateSerializer,
    ChangePasswordSerializer
)
from .permissions import IsOwner

User = get_user_model()


class RegisterView(generics.CreateAPIView):
    """Point d'entrée API pour l'inscription des utilisateurs."""
    
    queryset = User.objects.all()
    permission_classes = [permissions.AllowAny]
    serializer_class = UserRegistrationSerializer


class LoginView(TokenObtainPairView):
    """Point d'entrée API pour la connexion des utilisateurs via JWT."""
    
    permission_classes = [permissions.AllowAny]


class LogoutView(APIView):
    """Point d'entrée API pour la déconnexion des utilisateurs."""
    
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({"detail": "Déconnexion réussie."}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class RefreshTokenView(TokenRefreshView):
    """Point d'entrée API pour le rafraîchissement des tokens JWT."""
    
    permission_classes = [permissions.AllowAny]


class UserProfileView(generics.RetrieveUpdateAPIView):
    """Point d'entrée API pour récupérer et mettre à jour le profil utilisateur."""
    
    queryset = User.objects.all()
    permission_classes = [permissions.IsAuthenticated, IsOwner]
    
    def get_object(self):
        return self.request.user
    
    def get_serializer_class(self):
        if self.request.method == 'PUT' or self.request.method == 'PATCH':
            return UserProfileUpdateSerializer
        return UserSerializer


class ChangePasswordView(generics.UpdateAPIView):
    """Point d'entrée API pour changer le mot de passe utilisateur."""
    
    serializer_class = ChangePasswordSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self):
        return self.request.user
    
    def update(self, request, *args, **kwargs):
        user = self.get_object()
        serializer = self.get_serializer(data=request.data)
        
        if serializer.is_valid():
            # Vérification de l'ancien mot de passe
            if not user.check_password(serializer.validated_data['old_password']):
                return Response({"old_password": ["Mot de passe incorrect."]}, status=status.HTTP_400_BAD_REQUEST)
            
            # Définition du nouveau mot de passe
            user.set_password(serializer.validated_data['new_password'])
            user.save()
            return Response({"detail": "Mot de passe mis à jour avec succès."}, status=status.HTTP_200_OK)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
