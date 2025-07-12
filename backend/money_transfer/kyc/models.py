from django.db import models
from django.utils.translation import gettext_lazy as _
from authentication.models import User


class KYCDocument(models.Model):
    """Model for user identity verification documents."""
    
    class DocumentType(models.TextChoices):
        CNI = 'CNI', _('National Identity Card')
        PASSPORT = 'PASSPORT', _('Passport')
    
    class Status(models.TextChoices):
        PENDING = 'PENDING', _('Pending')
        VERIFIED = 'VERIFIED', _('Verified')
        REJECTED = 'REJECTED', _('Rejected')
    
    user = models.ForeignKey(
        User, 
        on_delete=models.CASCADE, 
        related_name='kyc_documents',
        verbose_name=_('User')
    )
    document_type = models.CharField(
        _('Document Type'),
        max_length=10,
        choices=DocumentType.choices
    )
    document_number = models.CharField(
        _('Document Number'),
        max_length=50
    )
    document_image = models.ImageField(
        _('Document Image'),
        upload_to='kyc_docs/'
    )
    status = models.CharField(
        _('Status'),
        max_length=10,
        choices=Status.choices,
        default=Status.PENDING
    )
    submitted_at = models.DateTimeField(
        _('Submitted At'),
        auto_now_add=True
    )
    
    class Meta:
        verbose_name = _('KYC Document')
        verbose_name_plural = _('KYC Documents')
        ordering = ['-submitted_at']
    
    def __str__(self):
        return f"{self.user.get_full_name()} - {self.get_document_type_display()}"
