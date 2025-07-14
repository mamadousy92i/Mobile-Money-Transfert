from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext_lazy as _

from .models import User


class UserAdmin(BaseUserAdmin):
    """Custom admin for the User model."""
    
    list_display = ('phone_number', 'email', 'first_name', 'last_name', 'is_staff', 'kyc_status')
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'kyc_status')
    fieldsets = (
        (None, {'fields': ('phone_number', 'password')}),
        (_('Personal info'), {'fields': ('first_name', 'last_name', 'email')}),
        (_('KYC info'), {'fields': ('kyc_status',)}),
        (_('Permissions'), {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        (_('Important dates'), {'fields': ('last_login', 'date_joined')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('phone_number', 'email', 'first_name', 'last_name', 'password1', 'password2'),
        }),
    )
    search_fields = ('phone_number', 'first_name', 'last_name', 'email')
    ordering = ('phone_number',)


admin.site.register(User, UserAdmin)
