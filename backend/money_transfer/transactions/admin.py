from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from django.utils.safestring import mark_safe
from django.db.models import Count, Sum, Avg
from django.utils import timezone
from datetime import timedelta

from .models import (
    Transaction, 
    Beneficiaire, 
    CanalPaiement,
    # Modèles internationaux
    Pays, 
    ServicePaiementInternational, 
    CorridorTransfert, 
    TransactionInternationale,
    TauxChange
)

# ===== CONFIGURATION GÉNÉRALE ADMIN =====
admin.site.site_header = "💰 Money Transfer - Administration"
admin.site.site_title = "Money Transfer Admin"
admin.site.index_title = "Tableau de Bord Transactions"

# ===== ADMIN TRANSACTIONS PRINCIPALES =====

@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = [
        'codeTransaction', 
        'expediteur_display',
        'destinataire_display', 
        'montant_simple',
        'status_badge',
        'canal_display',
        'date_simple'
    ]
    
    list_filter = [
        'statusTransaction',
        'typeTransaction', 
        'deviseEnvoi',
        'canal_paiement__type_canal',
        'created_at'
    ]
    
    search_fields = [
        'codeTransaction',
        'idTransaction', 
        'expediteur__first_name',
        'expediteur__last_name',
        'destinataire_phone'
    ]
    
    readonly_fields = [
        'id',
        'idTransaction', 
        'codeTransaction',
        'created_at',
        'updated_at'
    ]
    
    ordering = ['-created_at']
    list_per_page = 25
    
    def expediteur_display(self, obj):
        if obj.expediteur:
            return f"{obj.expediteur.get_full_name()} ({obj.expediteur.phone_number})"
        return "Inconnu"
    expediteur_display.short_description = 'Expéditeur'
    
    def destinataire_display(self, obj):
        if obj.destinataire:
            return f"{obj.destinataire.get_full_name()}"
        return f"{obj.destinataire_nom} ({obj.destinataire_phone})"
    destinataire_display.short_description = 'Destinataire'
    
    def montant_simple(self, obj):
        return f"{obj.montantEnvoye:,.0f} {obj.deviseEnvoi}"
    montant_simple.short_description = 'Montant'
    
    def status_badge(self, obj):
        colors = {
            'EN_ATTENTE': '#ff9800',
            'ACCEPTE': '#2196f3', 
            'ENVOYE': '#4caf50',
            'TERMINE': '#8bc34a',
            'ANNULE': '#f44336'
        }
        color = colors.get(obj.statusTransaction, '#666')
        return format_html(
            '<span style="background: {}; color: white; padding: 2px 8px; border-radius: 4px; font-size: 11px;">{}</span>',
            color,
            obj.get_statusTransaction_display()
        )
    status_badge.short_description = 'Statut'
    
    def canal_display(self, obj):
        if obj.canal_paiement:
            return obj.canal_paiement.canal_name
        return "Inconnu"
    canal_display.short_description = 'Canal'
    
    def date_simple(self, obj):
        return obj.created_at.strftime('%d/%m/%Y %H:%M')
    date_simple.short_description = 'Date'

# ===== ADMIN PAYS =====

@admin.register(Pays)
class PaysAdmin(admin.ModelAdmin):
    list_display = ['flag_emoji', 'nom', 'code_iso', 'devise', 'prefixe_tel', 'services_count', 'is_active']
    list_filter = ['devise', 'is_active']
    search_fields = ['nom', 'code_iso']
    list_editable = ['is_active']
    
    def services_count(self, obj):
        count = obj.services.filter(is_active=True).count()
        return f"{count} services"
    services_count.short_description = 'Services'

# ===== ADMIN SERVICES INTERNATIONAUX =====

@admin.register(ServicePaiementInternational)
class ServicePaiementInternationalAdmin(admin.ModelAdmin):
    list_display = ['nom', 'pays', 'type_service', 'frais_simple', 'limites_simple', 'is_active']
    list_filter = ['type_service', 'pays', 'is_active']
    search_fields = ['nom', 'code_service']
    list_editable = ['is_active']
    
    fieldsets = (
        ('Service & Pays', {
            'fields': ('pays', 'nom', 'type_service', 'code_service', 'is_active')
        }),
        ('Configuration Financière', {
            'fields': ('frais_percentage', 'frais_fixe', 'frais_min', 'frais_max')
        }),
        ('Limites de Transaction', {
            'fields': ('limite_min', 'limite_max')
        }),
        ('Configuration Technique', {
            'fields': ('regex_telephone', 'api_url'),
            'classes': ('collapse',)
        })
    )
    
    def frais_simple(self, obj):
        return f"{obj.frais_percentage}% + {obj.frais_fixe}"
    frais_simple.short_description = 'Frais'
    
    def limites_simple(self, obj):
        return f"{obj.limite_min:,.0f} - {obj.limite_max:,.0f}"
    limites_simple.short_description = 'Limites'

# ===== ADMIN CORRIDORS =====

@admin.register(CorridorTransfert)
class CorridorTransfertAdmin(admin.ModelAdmin):
    list_display = [
        'corridor_simple',
        'commission_simple', 
        'temps_simple',
        'performance_simple',
        'is_active'
    ]
    
    list_filter = ['pays_origine', 'pays_destination', 'is_active']
    list_editable = ['is_active']
    
    fieldsets = (
        ('Géographie', {
            'fields': ('pays_origine', 'pays_destination', 'is_active')
        }),
        ('Commission & Frais', {
            'fields': ('commission_percentage', 'commission_fixe', 'montant_min_corridor', 'montant_max_corridor')
        }),
        ('Temps de Livraison', {
            'fields': ('temps_livraison_min', 'temps_livraison_max')
        }),
        ('Statistiques', {
            'fields': ('nb_transactions', 'volume_total', 'taux_succes'),
            'classes': ('collapse',)
        })
    )
    
    def corridor_simple(self, obj):
        return f"{obj.pays_origine.flag_emoji} {obj.pays_origine.nom} → {obj.pays_destination.flag_emoji} {obj.pays_destination.nom}"
    corridor_simple.short_description = 'Corridor'
    
    def commission_simple(self, obj):
        exemple = (50000 * float(obj.commission_percentage) / 100) + float(obj.commission_fixe)
        return f"{obj.commission_percentage}% + {obj.commission_fixe} (Ex: {exemple:,.0f})"
    commission_simple.short_description = 'Commission'
    
    def temps_simple(self, obj):
        return f"{obj.temps_livraison_min}-{obj.temps_livraison_max} min"
    temps_simple.short_description = 'Temps'
    
    def performance_simple(self, obj):
        return f"{obj.taux_succes}% succès"
    performance_simple.short_description = 'Performance'

# ===== ADMIN TRANSACTIONS INTERNATIONALES =====

@admin.register(TransactionInternationale) 
class TransactionInternationaleAdmin(admin.ModelAdmin):
    list_display = [
        'transaction_code_simple',
        'corridor_display_simple', 
        'montants_simple',
        'taux_simple',
        'timing_simple'
    ]
    
    list_filter = [
        'corridor',
        'pays_origine',
        'pays_destination',
        'created_at'
    ]
    
    search_fields = [
        'transaction_locale__codeTransaction',
        'reference_externe'
    ]
    
    def transaction_code_simple(self, obj):
        return obj.transaction_locale.codeTransaction
    transaction_code_simple.short_description = 'Code Transaction'
    
    def corridor_display_simple(self, obj):
        return f"{obj.pays_origine.code_iso} → {obj.pays_destination.code_iso}"
    corridor_display_simple.short_description = 'Corridor'
    
    def montants_simple(self, obj):
        return f"{obj.montant_origine:,.0f} {obj.pays_origine.devise} → {obj.montant_destination:,.0f} {obj.pays_destination.devise}"
    montants_simple.short_description = 'Conversion'
    
    def taux_simple(self, obj):
        return f"1 {obj.pays_origine.devise} = {obj.taux_applique} {obj.pays_destination.devise}"
    taux_simple.short_description = 'Taux'
    
    def timing_simple(self, obj):
        if obj.date_livraison_reelle:
            temps_reel = obj.calculer_temps_reel()
            return f"✅ Livré en {temps_reel} min"
        else:
            return f"⏳ Estimé: {obj.temps_traitement_estime} min"
    timing_simple.short_description = 'Timing'

# ===== ADMIN CANAUX =====

@admin.register(CanalPaiement)
class CanalPaiementAdmin(admin.ModelAdmin):
    list_display = ['canal_name', 'type_canal', 'country', 'frais_exemple', 'is_active']
    list_filter = ['type_canal', 'country', 'is_active']
    search_fields = ['canal_name']
    list_editable = ['is_active']
    
    def frais_exemple(self, obj):
        try:
            exemple = obj.calculate_fees(50000)
            return f"{obj.fees_percentage}% + {obj.fees_fixed} = {exemple:,.0f}"
        except:
            return f"{obj.fees_percentage}% + {obj.fees_fixed}"
    frais_exemple.short_description = 'Frais (ex: 50K)'

# ===== ADMIN BÉNÉFICIAIRES =====

@admin.register(Beneficiaire)
class BeneficiaireAdmin(admin.ModelAdmin):
    list_display = ['nom_complet', 'phone', 'proprietaire', 'nb_transactions', 'inscrit_status']
    list_filter = ['created_at']
    search_fields = ['first_name', 'last_name', 'phone']
    
    def inscrit_status(self, obj):
        if obj.user_correspondant:
            return "✅ Inscrit"
        else:
            return "❌ Non inscrit"
    inscrit_status.short_description = 'Statut'

# ===== ADMIN TAUX DE CHANGE =====

@admin.register(TauxChange)
class TauxChangeAdmin(admin.ModelAdmin):
    list_display = ['devise_origine', 'devise_destination', 'taux', 'taux_avec_marge', 'source', 'last_updated', 'is_active']
    list_filter = ['devise_origine', 'devise_destination', 'source', 'is_active']
    list_editable = ['is_active']
    
    def taux_avec_marge(self, obj):
        try:
            taux_vente = obj.get_taux_client('vente')
            return f"{taux_vente:.6f} (marge: {obj.marge_vente*100:.1f}%)"
        except:
            return f"{obj.taux} (base)"
    taux_avec_marge.short_description = 'Taux Client'

# ===== ACTIONS PERSONNALISÉES =====

def marquer_comme_termine(modeladmin, request, queryset):
    """Action pour marquer des transactions comme terminées"""
    updated = queryset.update(statusTransaction='TERMINE')
    modeladmin.message_user(request, f'{updated} transactions marquées comme terminées.')
marquer_comme_termine.short_description = "Marquer comme terminé"

def marquer_comme_annule(modeladmin, request, queryset):
    """Action pour annuler des transactions"""
    updated = queryset.update(statusTransaction='ANNULE')
    modeladmin.message_user(request, f'{updated} transactions annulées.')
marquer_comme_annule.short_description = "Annuler transactions"

# Ajouter les actions à TransactionAdmin
TransactionAdmin.actions = [marquer_comme_termine, marquer_comme_annule]

# ===== PERSONNALISATION AVANCÉE =====

# Personnaliser la page d'accueil admin
class CustomAdminSite(admin.AdminSite):
    site_header = "💰 Money Transfer Administration"
    site_title = "Money Transfer Admin"
    index_title = "Tableau de Bord Principal"
    
    def index(self, request, extra_context=None):
        """Page d'accueil avec statistiques"""
        extra_context = extra_context or {}
        
        # Statistiques rapides
        try:
            total_transactions = Transaction.objects.count()
            transactions_today = Transaction.objects.filter(
                created_at__date=timezone.now().date()
            ).count()
            
            extra_context.update({
                'total_transactions': total_transactions,
                'transactions_today': transactions_today,
            })
        except:
            pass
            
        return super().index(request, extra_context)