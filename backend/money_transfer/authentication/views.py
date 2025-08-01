from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from django.contrib.auth import get_user_model
from rest_framework.permissions import IsAuthenticated
from rest_framework.generics import RetrieveUpdateAPIView

from .serializers import (
    UserSerializer,
    UserRegistrationSerializer,
    UserProfileUpdateSerializer,
    ChangePasswordSerializer,
    UpdateUserSerializer
)
from .permissions import IsOwner

User = get_user_model()


class RegisterView(generics.CreateAPIView):
    """API endpoint for user registration."""
    
    queryset = User.objects.all()
    permission_classes = [permissions.AllowAny]
    serializer_class = UserRegistrationSerializer


class LoginView(TokenObtainPairView):
    """API endpoint for user login using JWT."""
    
    permission_classes = [permissions.AllowAny]


class LogoutView(APIView):
    """API endpoint for user logout."""
    
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({"detail": "Successfully logged out."}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class RefreshTokenView(TokenRefreshView):
    """API endpoint for refreshing JWT tokens."""
    
    permission_classes = [permissions.AllowAny]


class UserProfileView(RetrieveUpdateAPIView):
    """
    Vue pour récupérer (GET) et mettre à jour (PATCH) le profil de l'utilisateur connecté.
    """
    permission_classes = [IsAuthenticated]
    
    # On définit les serializers à utiliser pour la lecture (GET) et l'écriture (PATCH)
    serializer_class = UserSerializer

    def get_object(self):
        """Retourne l'utilisateur actuellement authentifié."""
        return self.request.user

    def get_serializer_class(self):
        """
        Utilise UpdateUserSerializer pour les requêtes de mise à jour (PATCH)
        et UserSerializer pour tout le reste (GET).
        """
        if self.request.method == 'PATCH':
            return UpdateUserSerializer
        return UserSerializer

    def update(self, request, *args, **kwargs):
        """
        Personnalise la réponse après une mise à jour réussie.
        """
        response = super().update(request, *args, **kwargs)
        # Après une mise à jour, on retourne le profil complet et à jour.
        if response.status_code == status.HTTP_200_OK:
            user = self.get_object()
            return Response(UserSerializer(user).data)
        return response


class ChangePasswordView(generics.GenericAPIView):
    """
    Vue pour changer le mot de passe de l'utilisateur connecté.
    Accepte les requêtes POST.
    """
    serializer_class = ChangePasswordSerializer
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        serializer = self.get_serializer(data=request.data)
        
        if serializer.is_valid(raise_exception=True):
            # Vérifier l'ancien mot de passe
            if not user.check_password(serializer.data.get("old_password")):
                return Response({"old_password": ["Mauvais mot de passe."]}, status=status.HTTP_400_BAD_REQUEST)
            
            # Mettre le nouveau mot de passe
            user.set_password(serializer.data.get("new_password"))
            user.save()
            
            return Response({"detail": "Mot de passe changé avec succès."}, status=status.HTTP_200_OK)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
