from django.contrib import admin
from .models import Withdrawal

@admin.register(Withdrawal)
class WithdrawalAdmin(admin.ModelAdmin):
    list_display = ['code_retrait', 'beneficiaire', 'agent', 'montant_retire', 'statut', 'date_demande']
    list_filter = ['statut', 'date_demande', 'piece_identite_verifie']
    search_fields = ['code_retrait', 'beneficiaire__username', 'agent__nom']
    readonly_fields = ['code_retrait', 'qr_code', 'date_demande']
    
    fieldsets = (
        ('Informations de retrait', {
            'fields': ('code_retrait', 'qr_code', 'montant_retire', 'commission_agent')
        }),
        ('Participants', {
            'fields': ('beneficiaire', 'agent')
        }),
        ('Statut et vérification', {
            'fields': ('statut', 'piece_identite_verifie', 'notes_verification')
        }),
        ('Dates', {
            'fields': ('date_demande', 'date_retrait')
        }),
    )