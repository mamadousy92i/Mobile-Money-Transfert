from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import KYCDocument
from authentication.models import User


@receiver(post_save, sender=KYCDocument)
def update_user_kyc_status(sender, instance, created, **kwargs):
    """
    Signal to update the user's KYC status when a KYC document status changes.
    """
    user = instance.user
    
    # If a document is verified, set the user's KYC status to verified
    if instance.status == KYCDocument.Status.VERIFIED:
        user.kyc_status = User.KYCStatus.VERIFIED
        user.save()
    
    # If a document is rejected, set the user's KYC status to rejected
    elif instance.status == KYCDocument.Status.REJECTED:
        user.kyc_status = User.KYCStatus.REJECTED
        user.save()
    
    # If a new document is created with pending status, ensure user status is pending
    # Only do this if the user doesn't already have a verified status
    elif created and instance.status == KYCDocument.Status.PENDING:
        if user.kyc_status != User.KYCStatus.VERIFIED:
            user.kyc_status = User.KYCStatus.PENDING
            user.save()
