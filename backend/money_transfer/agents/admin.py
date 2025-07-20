# agents/admin.py
from django.contrib import admin
from .models import AgentLocal

@admin.register(AgentLocal)
class AgentLocalAdmin(admin.ModelAdmin):
    list_display = ['nom', 'prenom', 'statut_agent', 'est_disponible', 'date_creation']
    list_filter = ['statut_agent', 'date_creation']
    search_fields = ['nom', 'prenom', 'telephone']
    readonly_fields = ['est_ouvert', 'est_disponible']
    
    fieldsets = (
        ('Informations personnelles', {
            'fields': ('nom', 'prenom', 'telephone', 'email', 'adresse')
        }),
        ('Statut et disponibilité', {
            'fields': ('statut_agent', 'heure_ouverture', 'heure_fermeture', 'est_ouvert', 'est_disponible')
        }),
        ('Géolocalisation', {
            'fields': ('latitude', 'longitude')
        }),
        ('Finances', {
            'fields': ('solde_compte', 'limite_retrait_journalier', 'commission_pourcentage')
        }),
    )