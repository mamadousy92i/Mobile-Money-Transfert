from django.db import models
from django.utils.translation import gettext_lazy as _
from authentication.models import User


class KYCDocument(models.Model):
    """Modèle pour les documents de vérification d'identité des utilisateurs."""
    
    # ... (les classes DocumentType et Status ne changent pas)
    class DocumentType(models.TextChoices):
        CNI = 'CNI', _('Carte Nationale d\'Identité')
        PASSPORT = 'PASSPORT', _('Passeport')
    
    class Status(models.TextChoices):
        PENDING = 'PENDING', _('En attente')
        VERIFIED = 'VERIFIED', _('Vérifié')
        REJECTED = 'REJECTED', _('Rejeté')

    user = models.ForeignKey(
        User, 
        on_delete=models.CASCADE, 
        related_name='kyc_documents',
        verbose_name=_('Utilisateur')
    )
    document_type = models.CharField(
        _('Type de Document'),
        max_length=10,
        choices=DocumentType.choices
    )
    document_number = models.CharField(
        _('Numéro de Document'),
        max_length=50
    )
    
    document_front_image = models.ImageField(
        _('Image du Document (Recto)'),
        upload_to='kyc_docs/'
    )
    document_back_image = models.ImageField(
        _('Image du Document (Verso)'),
        upload_to='kyc_docs/',
        blank=True, # Le verso est optionnel (ex: pour un passeport)
        null=True
    )
    selfie_image = models.ImageField(
        _('Selfie avec le Document'),
        upload_to='kyc_selfies/'
    )
    
    status = models.CharField(
        _('Statut'),
        max_length=10,
        choices=Status.choices,
        default=Status.PENDING
    )
    submitted_at = models.DateTimeField(
        _('Soumis le'),
        auto_now_add=True
    )
    
    class Meta:
        verbose_name = _('Document KYC')
        verbose_name_plural = _('Documents KYC')
        ordering = ['-submitted_at']
    
    def __str__(self):
        return f"{self.user.get_full_name()} - {self.get_document_type_display()}"
