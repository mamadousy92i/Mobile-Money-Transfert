from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from datetime import datetime, timedelta
from django.db.models import Sum, Count, Avg
from .models import DashboardStats
from .serializers import DashboardStatsSerializer, DashboardSummarySerializer
from agents.models import AgentLocal
from withdrawals.models import Withdrawal

class DashboardViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = DashboardStats.objects.all()
    serializer_class = DashboardStatsSerializer
    permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['get'])
    def summary(self, request):
        today = datetime.now().date()
        yesterday = today - timedelta(days=1)
        
        # Stats d'aujourd'hui
        today_withdrawals = Withdrawal.objects.filter(date_demande__date=today)
        yesterday_withdrawals = Withdrawal.objects.filter(date_demande__date=yesterday)
        
        today_stats = {
            'total_transactions_today': today_withdrawals.count(),
            'total_volume_today': today_withdrawals.aggregate(
                total=Sum('montant_retire')
            )['total'] or 0,
            'total_commissions_today': today_withdrawals.aggregate(
                total=Sum('commission_agent')
            )['total'] or 0,
            'nouveaux_utilisateurs_today': 5,  # Mock pour l'instant
            'agents_actifs': AgentLocal.objects.filter(statut_agent='ACTIF').count(),
            'total_retraits_today': today_withdrawals.count(),
            'taux_reussite': 95.5,  # Mock pour l'instant
        }
        
        # Calcul des évolutions
        yesterday_count = yesterday_withdrawals.count()
        today_count = today_stats['total_transactions_today']
        
        if yesterday_count > 0:
            evolution_transactions = ((today_count - yesterday_count) / yesterday_count) * 100
        else:
            evolution_transactions = 0 if today_count == 0 else 100
        
        today_stats['evolution_transactions'] = round(evolution_transactions, 2)
        today_stats['evolution_volume'] = 8.2  # Mock pour l'instant
        
        serializer = DashboardSummarySerializer(today_stats)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def weekly_stats(self, request):
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=7)
        
        weekly_data = []
        for i in range(7):
            date = start_date + timedelta(days=i)
            withdrawals = Withdrawal.objects.filter(date_demande__date=date)
            
            weekly_data.append({
                'date': date,
                'total_transactions': withdrawals.count(),
                'total_volume': withdrawals.aggregate(
                    total=Sum('montant_retire')
                )['total'] or 0,
                'total_retraits': withdrawals.count(),
            })
        
        return Response(weekly_data)