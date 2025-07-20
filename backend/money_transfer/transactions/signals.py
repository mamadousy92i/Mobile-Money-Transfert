# transactions/signals.py - NOUVEAU FICHIER POUR NOTIFICATIONS AUTOMATIQUES

from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Transaction, StatutTransaction
import logging

logger = logging.getLogger(__name__)

@receiver(post_save, sender=Transaction)
def send_transaction_notifications(sender, instance, created, **kwargs):
    """
    Signal pour envoyer des notifications automatiques lors des changements de transaction.
    S'intègre avec le système de notifications du Dev 1.
    """
    try:
        # Import dynamique pour éviter les problèmes de dépendances circulaires
        from notifications.views import NotificationChannelFactory
        
        # Créer le canal de notification
        notification_channel = NotificationChannelFactory.get_channel('database')
        
        if created:
            # ===== NOTIFICATION CRÉATION DE TRANSACTION =====
            logger.info(f"📨 Envoi notification création transaction {instance.codeTransaction}")
            
            # Notification à l'expéditeur
            notification_channel.send(
                user=instance.expediteur,
                title="💸 Transaction initiée",
                message=f"Votre transaction de {instance.montantEnvoye:,.0f} {instance.deviseEnvoi} vers {instance.destinataire_phone} a été créée. Code: {instance.codeTransaction}",
                notification_type='TRANSACTION'
            )
            
            # Notification au destinataire (si inscrit)
            if instance.destinataire:
                notification_channel.send(
                    user=instance.destinataire,
                    title="💰 Argent reçu",
                    message=f"Vous avez reçu {instance.montantRecu:,.0f} {instance.deviseReception} de {instance.expediteur.get_full_name()}. Code de retrait: {instance.codeTransaction}",
                    notification_type='TRANSACTION'
                )
        
        else:
            # ===== NOTIFICATIONS CHANGEMENT DE STATUT =====
            
            if instance.statusTransaction == StatutTransaction.ENVOYE:
                logger.info(f"📨 Notification transaction envoyée {instance.codeTransaction}")
                
                # Notification à l'expéditeur
                notification_channel.send(
                    user=instance.expediteur,
                    title="✅ Transaction envoyée",
                    message=f"Votre transaction {instance.codeTransaction} a été traitée avec succès via {instance.canal_paiement.canal_name}. Le destinataire peut maintenant retirer l'argent.",
                    notification_type='TRANSACTION'
                )
                
                # Notification au destinataire (si inscrit)
                if instance.destinataire:
                    notification_channel.send(
                        user=instance.destinataire,
                        title="💰 Retrait disponible",
                        message=f"L'argent de {instance.expediteur.get_full_name()} est maintenant disponible pour retrait. Montant: {instance.montantRecu:,.0f} {instance.deviseReception}. Code: {instance.codeTransaction}",
                        notification_type='TRANSACTION'
                    )
            
            elif instance.statusTransaction == StatutTransaction.TERMINE:
                logger.info(f"📨 Notification transaction terminée {instance.codeTransaction}")
                
                # Notification à l'expéditeur
                notification_channel.send(
                    user=instance.expediteur,
                    title="🎉 Transaction terminée",
                    message=f"Votre transaction {instance.codeTransaction} a été retirée avec succès. L'argent a été remis au destinataire.",
                    notification_type='TRANSACTION'
                )
                
                # Notification au destinataire (si inscrit)
                if instance.destinataire:
                    notification_channel.send(
                        user=instance.destinataire,
                        title="✅ Retrait confirmé",
                        message=f"Vous avez retiré avec succès {instance.montantRecu:,.0f} {instance.deviseReception} de {instance.expediteur.get_full_name()}.",
                        notification_type='TRANSACTION'
                    )
            
            elif instance.statusTransaction == StatutTransaction.ANNULE:
                logger.info(f"📨 Notification transaction annulée {instance.codeTransaction}")
                
                # Notification à l'expéditeur
                notification_channel.send(
                    user=instance.expediteur,
                    title="❌ Transaction annulée",
                    message=f"Votre transaction {instance.codeTransaction} a été annulée. Si des frais ont été prélevés, ils seront remboursés sous 24h.",
                    notification_type='ALERT'
                )
                
                # Notification au destinataire (si inscrit)
                if instance.destinataire:
                    notification_channel.send(
                        user=instance.destinataire,
                        title="ℹ️ Transaction annulée",
                        message=f"La transaction de {instance.expediteur.get_full_name()} ({instance.codeTransaction}) a été annulée.",
                        notification_type='INFO'
                    )
    
    except Exception as e:
        # Ne pas faire échouer la transaction si les notifications échouent
        logger.error(f"❌ Erreur envoi notification pour transaction {instance.codeTransaction}: {e}")


@receiver(post_save, sender=Transaction)
def log_transaction_gateway_info(sender, instance, created, **kwargs):
    """
    Signal pour logger les informations de gateway pour monitoring.
    """
    if not created and instance.statusTransaction in [StatutTransaction.ENVOYE, StatutTransaction.ANNULE]:
        gateway_name = instance.canal_paiement.canal_name
        status = "SUCCESS" if instance.statusTransaction == StatutTransaction.ENVOYE else "FAILED"
        
        logger.info(f"🏦 Gateway {gateway_name}: Transaction {instance.codeTransaction} → {status}")
        logger.info(f"💰 Montant: {instance.montantEnvoye} {instance.deviseEnvoi}, Frais: {instance.frais}")


# ===== INTEGRATION AVEC LE SYSTÈME DE NOTIFICATIONS DU DEV 1 =====
"""
Ce fichier s'intègre parfaitement avec le travail du Dev 1 :

1. ✅ Utilise NotificationChannelFactory du Dev 1
2. ✅ Créé des notifications en base de données automatiquement
3. ✅ Suit les types de notification définis (TRANSACTION, ALERT, INFO)
4. ✅ Notifications pour expéditeur ET destinataire
5. ✅ Logging pour monitoring

WORKFLOW COMPLET :
Transaction créée → Signal → Notification automatique → Utilisateur notifié

PROCHAINES ÉTAPES (futures) :
- SMS notifications (Dev 1 peut ajouter SMSNotificationChannel)
- Push notifications (Dev 1 peut ajouter FCMNotificationChannel)
- Email notifications (Dev 1 peut ajouter EmailNotificationChannel)
"""