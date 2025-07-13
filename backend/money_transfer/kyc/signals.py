from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import KYCDocument
from authentication.models import User


@receiver(post_save, sender=KYCDocument)
def update_user_kyc_status(sender, instance, created, **kwargs):
    """
    Signal pour mettre à jour le statut KYC de l'utilisateur lorsque le statut d'un document KYC change.
    """
    user = instance.user
    
    # Si un document est vérifié, définir le statut KYC de l'utilisateur comme vérifié
    if instance.status == KYCDocument.Status.VERIFIED:
        user.kyc_status = User.KYCStatus.VERIFIED
        user.save()
    
    # Si un document est rejeté, définir le statut KYC de l'utilisateur comme rejeté
    elif instance.status == KYCDocument.Status.REJECTED:
        user.kyc_status = User.KYCStatus.REJECTED
        user.save()
    
    # Si un nouveau document est créé avec un statut en attente, s'assurer que le statut de l'utilisateur est en attente
    # Ne faire cela que si l'utilisateur n'a pas déjà un statut vérifié
    elif created and instance.status == KYCDocument.Status.PENDING:
        if user.kyc_status != User.KYCStatus.VERIFIED:
            user.kyc_status = User.KYCStatus.PENDING
            user.save()
