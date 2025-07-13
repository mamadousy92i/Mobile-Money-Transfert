from django.db import models
from django.utils.translation import gettext_lazy as _
from authentication.models import User


class Notification(models.Model):
    """Modèle pour les notifications utilisateur."""
    
    class NotificationType(models.TextChoices):
        INFO = 'INFO', _('Information')
        TRANSACTION = 'TRANSACTION', _('Transaction')
        ALERT = 'ALERT', _('Alerte')
    
    class Status(models.TextChoices):
        UNREAD = 'UNREAD', _('Non lu')
        READ = 'READ', _('Lu')
    
    user = models.ForeignKey(
        User, 
        on_delete=models.CASCADE, 
        related_name='notifications',
        verbose_name=_('Utilisateur')
    )
    title = models.CharField(
        _('Titre'),
        max_length=255
    )
    message = models.TextField(
        _('Message')
    )
    notification_type = models.CharField(
        _('Type de Notification'),
        max_length=15,
        choices=NotificationType.choices,
        default=NotificationType.INFO
    )
    status = models.CharField(
        _('Statut'),
        max_length=10,
        choices=Status.choices,
        default=Status.UNREAD
    )
    auto_sent = models.BooleanField(
        _('Envoi Automatique'),
        default=False,
        help_text=_('Indique si cette notification a été générée automatiquement')
    )
    created_at = models.DateTimeField(
        _('Créé le'),
        auto_now_add=True
    )
    seen_at = models.DateTimeField(
        _('Vu le'),
        null=True,
        blank=True,
        help_text=_('Moment où l\'utilisateur a vu cette notification')
    )
    
    class Meta:
        verbose_name = _('Notification')
        verbose_name_plural = _('Notifications')
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.user.get_full_name()} - {self.title}"
    
    def mark_as_read(self):
        """Marquer la notification comme lue et définir l'horodatage de lecture."""
        from django.utils import timezone
        
        self.status = self.Status.READ
        self.seen_at = timezone.now()
        self.save(update_fields=['status', 'seen_at'])
