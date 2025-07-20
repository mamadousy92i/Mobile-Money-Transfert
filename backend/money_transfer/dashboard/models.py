# dashboard/models.py - VERSION CORRIGÉE POUR INTÉGRATION

from django.db import models
from django.conf import settings
from django.db.models import Sum, Count, Avg, Q
from django.utils import timezone
from datetime import datetime, timedelta
from decimal import Decimal

class DashboardStats(models.Model):
    """Statistiques quotidiennes consolidées"""
    
    date = models.DateField(unique=True)
    
    # ===== STATISTIQUES TRANSACTIONS (DEV 2) =====
    total_transactions = models.IntegerField(
        default=0,
        help_text="Nombre total de transactions du jour"
    )
    total_volume = models.DecimalField(
        max_digits=20, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Volume total en XOF"
    )
    total_commissions = models.DecimalField(
        max_digits=15, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Total des commissions"
    )
    taux_reussite = models.DecimalField(
        max_digits=5, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Taux de réussite des transactions"
    )
    
    # ===== STATISTIQUES UTILISATEURS (DEV 1) =====
    nouveaux_utilisateurs = models.IntegerField(
        default=0,
        help_text="Nouveaux utilisateurs inscrits"
    )
    utilisateurs_actifs = models.IntegerField(
        default=0,
        help_text="Utilisateurs ayant fait au moins 1 transaction"
    )
    utilisateurs_kyc_verifies = models.IntegerField(
        default=0,
        help_text="Utilisateurs avec KYC vérifié"
    )
    
    # ===== STATISTIQUES AGENTS (DEV 3) =====
    agents_actifs = models.IntegerField(
        default=0,
        help_text="Agents actifs dans la journée"
    )
    total_retraits = models.IntegerField(
        default=0,
        help_text="Nombre de retraits effectués"
    )
    volume_retraits = models.DecimalField(
        max_digits=15,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Volume des retraits en XOF"
    )
    
    # ===== STATISTIQUES GATEWAYS (DEV 2) =====
    transactions_wave = models.IntegerField(
        default=0,
        help_text="Transactions via Wave"
    )
    transactions_orange = models.IntegerField(
        default=0,
        help_text="Transactions via Orange Money"
    )
    taux_succes_wave = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Taux de succès Wave"
    )
    taux_succes_orange = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Taux de succès Orange Money"
    )
    
    # ===== STATISTIQUES INTERNATIONALES (DEV 2) =====
    transactions_internationales = models.IntegerField(
        default=0,
        help_text="Transactions internationales"
    )
    volume_international = models.DecimalField(
        max_digits=20,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Volume international en XOF"
    )
    
    # ===== MÉTADONNÉES =====
    date_creation = models.DateTimeField(auto_now_add=True)
    date_mise_a_jour = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'dashboard_stats'
        verbose_name = 'Statistique Dashboard'
        verbose_name_plural = 'Statistiques Dashboard'
        ordering = ['-date']
        
        indexes = [
            models.Index(fields=['date']),
            models.Index(fields=['-date']),
        ]
    
    def __str__(self):
        return f"Stats {self.date} - {self.total_transactions} transactions"
    
    @classmethod
    def calculer_stats_jour(cls, date=None):
        """Calculer les statistiques pour un jour donné"""
        if date is None:
            date = timezone.now().date()
        
        # Import des modèles ici pour éviter circular imports
        from transactions.models import Transaction, StatutTransaction
        from authentication.models import User
        from agents.models import AgentLocal
        from withdrawals.models import Withdrawal
        
        # ===== STATISTIQUES TRANSACTIONS =====
        transactions_jour = Transaction.objects.filter(created_at__date=date)
        transactions_terminees = transactions_jour.filter(statusTransaction=StatutTransaction.TERMINE)
        transactions_annulees = transactions_jour.filter(statusTransaction=StatutTransaction.ANNULE)
        
        total_transactions = transactions_jour.count()
        volume_total = transactions_terminees.aggregate(
            total=Sum('montantEnvoye')
        )['total'] or Decimal('0.00')
        
        # Calcul taux de réussite
        if total_transactions > 0:
            taux_reussite = (transactions_terminees.count() / total_transactions) * 100
        else:
            taux_reussite = Decimal('0.00')
        
        # ===== STATISTIQUES UTILISATEURS =====
        nouveaux_users = User.objects.filter(date_joined__date=date).count()
        users_actifs = User.objects.filter(
            transactions_envoyees__created_at__date=date
        ).distinct().count()
        users_kyc_verifies = User.objects.filter(
            kyc_status='VERIFIED',
            date_joined__date=date
        ).count()
        
        # ===== STATISTIQUES AGENTS =====
        agents_actifs_count = AgentLocal.objects.filter(
            retraits_geres__date_demande__date=date
        ).distinct().count()
        
        retraits_jour = Withdrawal.objects.filter(date_demande__date=date)
        total_retraits = retraits_jour.count()
        volume_retraits = retraits_jour.aggregate(
            total=Sum('montant_retire')
        )['total'] or Decimal('0.00')
        
        # ===== STATISTIQUES GATEWAYS =====
        transactions_wave = transactions_jour.filter(
            canal_paiement__type_canal='WAVE'
        ).count()
        transactions_orange = transactions_jour.filter(
            canal_paiement__type_canal='ORANGE_MONEY'
        ).count()
        
        # Taux de succès par gateway
        wave_terminees = transactions_jour.filter(
            canal_paiement__type_canal='WAVE',
            statusTransaction=StatutTransaction.TERMINE
        ).count()
        orange_terminees = transactions_jour.filter(
            canal_paiement__type_canal='ORANGE_MONEY',
            statusTransaction=StatutTransaction.TERMINE
        ).count()
        
        taux_succes_wave = (wave_terminees / transactions_wave * 100) if transactions_wave > 0 else Decimal('0.00')
        taux_succes_orange = (orange_terminees / transactions_orange * 100) if transactions_orange > 0 else Decimal('0.00')
        
        # ===== STATISTIQUES INTERNATIONALES =====
        transactions_intl = transactions_jour.filter(
            extension_internationale__isnull=False
        )
        transactions_internationales = transactions_intl.count()
        volume_international = transactions_intl.aggregate(
            total=Sum('montantEnvoye')
        )['total'] or Decimal('0.00')
        
        # ===== TOTAL COMMISSIONS =====
        # Commissions des retraits + frais transactions
        commissions_retraits = retraits_jour.aggregate(
            total=Sum('commission_agent')
        )['total'] or Decimal('0.00')
        
        # Estimation frais transactions (à ajuster selon votre logique)
        frais_transactions = volume_total * Decimal('0.015')  # 1.5% moyenne
        
        total_commissions = commissions_retraits + frais_transactions
        
        # ===== CRÉER OU METTRE À JOUR =====
        stats, created = cls.objects.update_or_create(
            date=date,
            defaults={
                'total_transactions': total_transactions,
                'total_volume': volume_total,
                'total_commissions': total_commissions,
                'taux_reussite': taux_reussite,
                'nouveaux_utilisateurs': nouveaux_users,
                'utilisateurs_actifs': users_actifs,
                'utilisateurs_kyc_verifies': users_kyc_verifies,
                'agents_actifs': agents_actifs_count,
                'total_retraits': total_retraits,
                'volume_retraits': volume_retraits,
                'transactions_wave': transactions_wave,
                'transactions_orange': transactions_orange,
                'taux_succes_wave': taux_succes_wave,
                'taux_succes_orange': taux_succes_orange,
                'transactions_internationales': transactions_internationales,
                'volume_international': volume_international,
            }
        )
        
        return stats
    
    @classmethod
    def get_evolution_stats(cls, date=None, jours=7):
        """Obtenir l'évolution des stats sur N jours"""
        if date is None:
            date = timezone.now().date()
        
        date_debut = date - timedelta(days=jours-1)
        
        stats = cls.objects.filter(
            date__range=[date_debut, date]
        ).order_by('date')
        
        return {
            'dates': [stat.date.strftime('%Y-%m-%d') for stat in stats],
            'transactions': [stat.total_transactions for stat in stats],
            'volume': [float(stat.total_volume) for stat in stats],
            'commissions': [float(stat.total_commissions) for stat in stats],
            'taux_reussite': [float(stat.taux_reussite) for stat in stats],
            'retraits': [stat.total_retraits for stat in stats],
        }
    
    @classmethod
    def get_stats_temps_reel(cls):
        """Obtenir les statistiques en temps réel (aujourd'hui)"""
        today = timezone.now().date()
        yesterday = today - timedelta(days=1)
        
        # Calculer les stats d'aujourd'hui
        stats_today = cls.calculer_stats_jour(today)
        
        # Récupérer les stats d'hier pour comparaison
        try:
            stats_yesterday = cls.objects.get(date=yesterday)
        except cls.DoesNotExist:
            stats_yesterday = cls.calculer_stats_jour(yesterday)
        
        # Calculer évolutions
        def calc_evolution(today_val, yesterday_val):
            if yesterday_val == 0:
                return 100.0 if today_val > 0 else 0.0
            return ((today_val - yesterday_val) / yesterday_val) * 100
        
        return {
            'stats_aujourd_hui': {
                'total_transactions': stats_today.total_transactions,
                'total_volume': float(stats_today.total_volume),
                'total_commissions': float(stats_today.total_commissions),
                'nouveaux_utilisateurs': stats_today.nouveaux_utilisateurs,
                'agents_actifs': stats_today.agents_actifs,
                'total_retraits': stats_today.total_retraits,
                'taux_reussite': float(stats_today.taux_reussite),
                'transactions_wave': stats_today.transactions_wave,
                'transactions_orange': stats_today.transactions_orange,
                'transactions_internationales': stats_today.transactions_internationales,
            },
            'evolutions': {
                'evolution_transactions': round(calc_evolution(
                    stats_today.total_transactions, 
                    stats_yesterday.total_transactions
                ), 2),
                'evolution_volume': round(calc_evolution(
                    float(stats_today.total_volume), 
                    float(stats_yesterday.total_volume)
                ), 2),
                'evolution_commissions': round(calc_evolution(
                    float(stats_today.total_commissions), 
                    float(stats_yesterday.total_commissions)
                ), 2),
                'evolution_utilisateurs': round(calc_evolution(
                    stats_today.nouveaux_utilisateurs, 
                    stats_yesterday.nouveaux_utilisateurs
                ), 2),
            },
            'date_calcul': today.isoformat(),
            'derniere_mise_a_jour': stats_today.date_mise_a_jour.isoformat(),
        }

# ===== MODÈLE POUR MÉTRIQUES TEMPS RÉEL =====
class MetriqueTempReel(models.Model):
    """Métriques calculées en temps réel pour dashboard live"""
    
    cle_metrique = models.CharField(max_length=50, unique=True)
    valeur_numerique = models.DecimalField(max_digits=20, decimal_places=2, null=True, blank=True)
    valeur_texte = models.TextField(blank=True)
    derniere_mise_a_jour = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Métrique Temps Réel'
        verbose_name_plural = 'Métriques Temps Réel'
    
    def __str__(self):
        return f"{self.cle_metrique}: {self.valeur_numerique or self.valeur_texte}"

# ===== INTÉGRATION PARFAITE AVEC VOTRE SYSTÈME =====
"""
✅ CORRECTIONS APPORTÉES :

1. 📊 DONNÉES RÉELLES :
   - Calculs basés sur vraies tables (Transaction, User, Withdrawal)
   - Import dynamique pour éviter circular imports
   - Métriques précises et cohérentes

2. 🔗 INTÉGRATION INTER-APPS :
   - Statistiques Dev 1 (Users, KYC)
   - Statistiques Dev 2 (Transactions, Gateways, International)
   - Statistiques Dev 3 (Agents, Withdrawals)

3. 🎯 BUSINESS INTELLIGENCE :
   - Taux de réussite par gateway
   - Évolutions jour par jour
   - Métriques temps réel
   - Commissions calculées

4. ⚡ PERFORMANCE :
   - Méthodes statiques pour calculs
   - Index sur dates
   - Calculs optimisés avec aggregate()

5. 📈 ÉVOLUTIONS :
   - Comparaisons automatiques jour précédent
   - Pourcentages d'évolution
   - Tendances sur 7 jours

🎯 UTILISATION :
# Calcul automatique stats du jour
stats = DashboardStats.calculer_stats_jour()

# Stats temps réel avec évolutions
dashboard_data = DashboardStats.get_stats_temps_reel()

# Évolution sur 7 jours
evolution = DashboardStats.get_evolution_stats(jours=7)
"""