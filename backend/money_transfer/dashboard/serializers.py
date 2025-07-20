from rest_framework import serializers
from .models import DashboardStats

class DashboardStatsSerializer(serializers.ModelSerializer):
    class Meta:
        model = DashboardStats
        fields = '__all__'

class DashboardSummarySerializer(serializers.Serializer):
    total_transactions_today = serializers.IntegerField()
    total_volume_today = serializers.DecimalField(max_digits=20, decimal_places=2)
    total_commissions_today = serializers.DecimalField(max_digits=15, decimal_places=2)
    nouveaux_utilisateurs_today = serializers.IntegerField()
    agents_actifs = serializers.IntegerField()
    total_retraits_today = serializers.IntegerField()
    taux_reussite = serializers.DecimalField(max_digits=5, decimal_places=2)
    evolution_transactions = serializers.DecimalField(max_digits=5, decimal_places=2)
    evolution_volume = serializers.DecimalField(max_digits=5, decimal_places=2)

