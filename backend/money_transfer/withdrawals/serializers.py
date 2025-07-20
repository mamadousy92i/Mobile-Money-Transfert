from rest_framework import serializers
from .models import Withdrawal
from agents.serializers import AgentLocalSerializer

class WithdrawalSerializer(serializers.ModelSerializer):
    agent_info = AgentLocalSerializer(source='agent', read_only=True)
    beneficiaire_nom = serializers.CharField(source='beneficiaire.username', read_only=True)
    statut_formatted = serializers.SerializerMethodField()
    
    class Meta:
        model = Withdrawal
        fields = [
            'id', 'code_retrait', 'qr_code', 'montant_retire',
            'commission_agent', 'statut', 'statut_formatted', 'date_demande', 
            'date_retrait', 'piece_identite_verifie', 'notes_verification',
            'agent_info', 'beneficiaire_nom'
        ]
        read_only_fields = ['code_retrait', 'qr_code', 'commission_agent', 'date_demande']
    
    def get_statut_formatted(self, obj):
        status_map = {
            'EN_ATTENTE': 'En attente',
            'ACCEPTE': 'Accepté',
            'TERMINE': 'Terminé',
            'ANNULE': 'Annulé'
        }
        return status_map.get(obj.statut, obj.statut)

class WithdrawalCreateSerializer(serializers.ModelSerializer):
    agent_id = serializers.IntegerField()
    notes = serializers.CharField(max_length=500, required=False, allow_blank=True)
    
    class Meta:
        model = Withdrawal
        fields = ['agent_id', 'montant_retire', 'notes']
    
    def validate(self, data):
        # Vérifier que l'agent existe et est actif
        from agents.models import AgentLocal
        try:
            agent = AgentLocal.objects.get(id=data['agent_id'], statut_agent='ACTIF')
        except AgentLocal.DoesNotExist:
            raise serializers.ValidationError("Agent non trouvé ou inactif")
        
        # Vérifier les montants
        if data['montant_retire'] < 1000:
            raise serializers.ValidationError("Montant minimum: 1,000 FCFA")
        if data['montant_retire'] > 1000000:
            raise serializers.ValidationError("Montant maximum: 1,000,000 FCFA")
        
        data['agent'] = agent
        return data
    
    def create(self, validated_data):
        # Calculer la commission
        agent = validated_data['agent']
        montant = validated_data['montant_retire']
        commission = montant * (agent.commission_pourcentage / 100)
        
        # Créer le retrait
        withdrawal = Withdrawal.objects.create(
            agent=agent,
            beneficiaire=self.context['request'].user,
            montant_retire=montant,
            commission_agent=commission,
            notes_verification=validated_data.get('notes', ''),
        )
        
        return withdrawal