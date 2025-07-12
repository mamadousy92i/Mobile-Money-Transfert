from django.db import models
from django.utils.translation import gettext_lazy as _
from authentication.models import User


class Notification(models.Model):
    """Model for user notifications."""
    
    class NotificationType(models.TextChoices):
        INFO = 'INFO', _('Information')
        TRANSACTION = 'TRANSACTION', _('Transaction')
        ALERT = 'ALERT', _('Alert')
    
    class Status(models.TextChoices):
        UNREAD = 'UNREAD', _('Unread')
        READ = 'READ', _('Read')
    
    user = models.ForeignKey(
        User, 
        on_delete=models.CASCADE, 
        related_name='notifications',
        verbose_name=_('User')
    )
    title = models.CharField(
        _('Title'),
        max_length=255
    )
    message = models.TextField(
        _('Message')
    )
    notification_type = models.CharField(
        _('Notification Type'),
        max_length=15,
        choices=NotificationType.choices,
        default=NotificationType.INFO
    )
    status = models.CharField(
        _('Status'),
        max_length=10,
        choices=Status.choices,
        default=Status.UNREAD
    )
    auto_sent = models.BooleanField(
        _('Auto Sent'),
        default=False,
        help_text=_('Whether this notification was automatically generated')
    )
    created_at = models.DateTimeField(
        _('Created At'),
        auto_now_add=True
    )
    seen_at = models.DateTimeField(
        _('Seen At'),
        null=True,
        blank=True,
        help_text=_('When the user has seen this notification')
    )
    
    class Meta:
        verbose_name = _('Notification')
        verbose_name_plural = _('Notifications')
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.user.get_full_name()} - {self.title}"
    
    def mark_as_read(self):
        """Mark the notification as read and set seen_at timestamp."""
        from django.utils import timezone
        
        self.status = self.Status.READ
        self.seen_at = timezone.now()
        self.save(update_fields=['status', 'seen_at'])
