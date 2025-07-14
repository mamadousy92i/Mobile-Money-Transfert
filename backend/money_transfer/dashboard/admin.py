from django.contrib import admin
from .models import DashboardStats

@admin.register(DashboardStats)
class DashboardStatsAdmin(admin.ModelAdmin):
    list_display = ['date', 'total_transactions', 'total_volume', 'agents_actifs', 'taux_reussite']
    list_filter = ['date']
    date_hierarchy = 'date'
    readonly_fields = ['date_creation']
    
    fieldsets = (
        ('Date', {
            'fields': ('date',)
        }),
        ('Transactions', {
            'fields': ('total_transactions', 'total_volume', 'total_commissions', 'taux_reussite')
        }),
        ('Utilisateurs', {
            'fields': ('nouveaux_utilisateurs', 'utilisateurs_actifs')
        }),
        ('Agents', {
            'fields': ('agents_actifs', 'total_retraits')
        }),
    )