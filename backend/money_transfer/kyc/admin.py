from django.contrib import admin
from .models import KYCDocument


@admin.register(KYCDocument)
class KYCDocumentAdmin(admin.ModelAdmin):
    list_display = ('user', 'document_type', 'document_number', 'status', 'submitted_at')
    list_filter = ('status', 'document_type', 'submitted_at')
    search_fields = ('user__first_name', 'user__last_name', 'user__email', 'user__phone_number', 'document_number')
    readonly_fields = ('submitted_at',)
    date_hierarchy = 'submitted_at'
    
    actions = ['mark_as_verified', 'mark_as_rejected']
    
    def mark_as_verified(self, request, queryset):
        queryset.update(status=KYCDocument.Status.VERIFIED)
        # The signal will handle updating the user's KYC status
    mark_as_verified.short_description = "Mark selected documents as verified"
    
    def mark_as_rejected(self, request, queryset):
        queryset.update(status=KYCDocument.Status.REJECTED)
        # The signal will handle updating the user's KYC status
    mark_as_rejected.short_description = "Mark selected documents as rejected"
