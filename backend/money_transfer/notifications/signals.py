from django.db.models.signals import post_save
from django.dispatch import receiver
from kyc.models import KYCDocument
from .views import NotificationChannelFactory


@receiver(post_save, sender=KYCDocument)
def send_kyc_notification(sender, instance, created, **kwargs):
    """
    Signal pour envoyer des notifications lorsque le statut d'un document KYC change.
    """
    user = instance.user
    
    # Si un document est vérifié, envoyer une notification de succès
    if instance.status == KYCDocument.Status.VERIFIED:
        notification_channel = NotificationChannelFactory.get_channel('database')
        notification_channel.send(
            user=user,
            title="Vérification KYC réussie",
            message=f"Votre {instance.get_document_type_display()} a été vérifié avec succès.",
            notification_type='INFO'
        )
    
    # Si un document est rejeté, envoyer une notification d'alerte
    elif instance.status == KYCDocument.Status.REJECTED:
        notification_channel = NotificationChannelFactory.get_channel('database')
        notification_channel.send(
            user=user,
            title="Échec de la vérification KYC",
            message=f"La vérification de votre {instance.get_document_type_display()} a été rejetée. Veuillez soumettre un nouveau document.",
            notification_type='ALERT'
        )
    
    # Si un nouveau document est créé avec un statut en attente, envoyer une notification d'information
    elif created and instance.status == KYCDocument.Status.PENDING:
        notification_channel = NotificationChannelFactory.get_channel('database')
        notification_channel.send(
            user=user,
            title="Document KYC soumis",
            message=f"Votre {instance.get_document_type_display()} a été soumis pour vérification. Nous vous informerons une fois la vérification terminée.",
            notification_type='INFO'
        )
