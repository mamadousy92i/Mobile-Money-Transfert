from django.contrib import admin
from .models import Reception

@admin.register(Reception)
class ReceptionAdmin(admin.ModelAdmin):
    list_display = ['code_reception', 'destinataire', 'montant_a_recevoir', 'statut', 'mode_reception']
    list_filter = ['statut', 'mode_reception', 'notification_envoyee']
    search_fields = ['code_reception', 'destinataire__username']
    
    fieldsets = (
        ('Informations de réception', {
            'fields': ('code_reception', 'montant_a_recevoir', 'devise_reception')
        }),
        ('Destinataire', {
            'fields': ('destinataire', 'mode_reception')
        }),
        ('Statut et dates', {
            'fields': ('statut', 'date_notification', 'date_confirmation', 'date_retrait')
        }),
        ('Notifications', {
            'fields': ('notification_envoyee', 'sms_envoye')
        }),
    )