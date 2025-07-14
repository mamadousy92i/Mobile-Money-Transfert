from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Withdrawal
from .serializers import WithdrawalSerializer, WithdrawalCreateSerializer

class WithdrawalViewSet(viewsets.ModelViewSet):
    serializer_class = WithdrawalSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        # Pour l'instant, on montre tous les retraits de l'utilisateur
        return Withdrawal.objects.filter(beneficiaire=user).order_by('-date_demande')
    
    def get_serializer_class(self):
        if self.action == 'create':
            return WithdrawalCreateSerializer
        return WithdrawalSerializer
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        withdrawal = serializer.save()
        
        # Retourner la réponse avec le serializer complet
        response_serializer = WithdrawalSerializer(withdrawal)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)

