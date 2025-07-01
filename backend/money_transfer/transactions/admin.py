

# Register your models here.
# transactions/admin.py
from django.contrib import admin
from .models import Transaction, Beneficiaire, CanalPaiement

@admin.register(CanalPaiement)
class CanalPaiementAdmin(admin.ModelAdmin):
    list_display = ['canal_name', 'type_canal', 'country', 'is_active']
    list_filter = ['type_canal', 'country', 'is_active']

@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ['codeTransaction', 'montantEnvoye', 'statusTransaction', 'dateTraitement']
    list_filter = ['statusTransaction', 'deviseEnvoi']
    readonly_fields = ['codeTransaction', 'idTransaction']

@admin.register(Beneficiaire)
class BeneficiaireAdmin(admin.ModelAdmin):
    list_display = ['first_name', 'last_name', 'phone']
    search_fields = ['first_name', 'last_name', 'phone']