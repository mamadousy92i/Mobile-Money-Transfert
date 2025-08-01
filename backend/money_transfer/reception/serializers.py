# reception/serializers.py
from rest_framework import serializers
from .models import Reception


class ReceptionSerializer(serializers.ModelSerializer):
    """
    Serializer pour lister les réceptions en attente pour un utilisateur.
    """
    expediteur_nom = serializers.CharField(source='transaction_origine.expediteur.get_full_name', read_only=True)
    montant_attendu = serializers.DecimalField(source='transaction_origine.montantRecu', max_digits=10, decimal_places=2, read_only=True)
    devise = serializers.CharField(source='transaction_origine.deviseReception', read_only=True)

    class Meta:
        model = Reception
        fields = [
            'id',
            'expediteur_nom',
            'montant_attendu',
            'devise',
            'code_reception',  # <-- CORRIGÉ
            'statut',          # <-- CORRIGÉ
            'created_at',      # <-- CORRIGÉ
        ]
    