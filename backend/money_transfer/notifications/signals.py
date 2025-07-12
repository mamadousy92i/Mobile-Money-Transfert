from django.db.models.signals import post_save
from django.dispatch import receiver
from kyc.models import KYCDocument
from .views import NotificationChannelFactory


@receiver(post_save, sender=KYCDocument)
def send_kyc_notification(sender, instance, created, **kwargs):
    """
    Signal to send notifications when a KYC document status changes.
    """
    user = instance.user
    
    # If a document is verified, send a success notification
    if instance.status == KYCDocument.Status.VERIFIED:
        notification_channel = NotificationChannelFactory.get_channel('database')
        notification_channel.send(
            user=user,
            title="KYC Verification Successful",
            message=f"Your {instance.get_document_type_display()} has been verified successfully.",
            notification_type='INFO'
        )
    
    # If a document is rejected, send an alert notification
    elif instance.status == KYCDocument.Status.REJECTED:
        notification_channel = NotificationChannelFactory.get_channel('database')
        notification_channel.send(
            user=user,
            title="KYC Verification Failed",
            message=f"Your {instance.get_document_type_display()} verification has been rejected. Please submit a new document.",
            notification_type='ALERT'
        )
    
    # If a new document is created with pending status, send an info notification
    elif created and instance.status == KYCDocument.Status.PENDING:
        notification_channel = NotificationChannelFactory.get_channel('database')
        notification_channel.send(
            user=user,
            title="KYC Document Submitted",
            message=f"Your {instance.get_document_type_display()} has been submitted for verification. We will notify you once the verification is complete.",
            notification_type='INFO'
        )
