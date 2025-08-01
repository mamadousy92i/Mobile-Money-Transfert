# reception/views.py
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import Reception, StatutReception
from .serializers import ReceptionSerializer
from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import action

class ReceptionViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet pour que les utilisateurs puissent lister leurs réceptions en attente.
    """
    serializer_class = ReceptionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """
        Retourne les réceptions pour l'utilisateur connecté.
        - Par défaut, affiche uniquement les réceptions "actives" (non retirées/annulées).
        - Si un filtre de statut est fourni via l'URL (ex: ?status=RETIRE),
          il est appliqué à la place du filtre par défaut.
        """
        user = self.request.user
        queryset = Reception.objects.filter(destinataire=user)
        
        status_filter = self.request.query_params.get('status', None)

        if status_filter:
            # Si le filtre est "ACTIVE", on utilise la liste des statuts actifs.
            if status_filter.upper() == 'ACTIVE':
                statuts_actifs = [
                    StatutReception.EN_ATTENTE,
                    StatutReception.NOTIFIE,
                    StatutReception.CONFIRME
                ]
                queryset = queryset.filter(statut__in=statuts_actifs)
            else:
                # Sinon, on filtre sur le statut spécifique demandé (ex: RETIRE)
                queryset = queryset.filter(statut=status_filter)
        
        # Si aucun filtre n'est fourni, on ne filtre pas par statut (comportement pour "Tous")
            
        return queryset.order_by('-created_at')
    @action(detail=True, methods=['post'], url_path='retrait-digital')
    def retrait_digital(self, request, pk=None):
        """
        Action pour finaliser une réception via un retrait digital (vers mobile money).
        """
        # 1. Récupérer l'objet Réception
        reception = self.get_object()

        # 2. Vérifier que la réception appartient bien à l'utilisateur qui fait la demande
        if reception.destinataire != request.user:
            return Response(
                {'error': 'Vous n\'êtes pas autorisé à effectuer cette action.'},
                status=status.HTTP_403_FORBIDDEN
            )

        # 3. Appeler la méthode métier du modèle pour finaliser le retrait
        #    Cette méthode mettra à jour le statut et celui de la transaction liée.
        success, message = reception.finaliser_retrait()

        if success:
            return Response({'success': True, 'message': message}, status=status.HTTP_200_OK)
        else:
            return Response({'success': False, 'error': message}, status=status.HTTP_400_BAD_REQUEST)