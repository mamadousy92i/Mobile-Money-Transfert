from django.contrib import admin
from .models import Notification

# Register your models here.

@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'title', 'notification_type', 'status', 'auto_sent', 'created_at', 'seen_at')
    list_filter = ('notification_type', 'status', 'auto_sent', 'created_at')
    search_fields = ('title', 'message', 'user__email', 'user__first_name', 'user__last_name')
    readonly_fields = ('created_at', 'seen_at')
    fieldsets = (
        ('User Information', {
            'fields': ('user',)
        }),
        ('Notification Details', {
            'fields': ('title', 'message', 'notification_type', 'status')
        }),
        ('Metadata', {
            'fields': ('auto_sent', 'created_at', 'seen_at')
        }),
    )
