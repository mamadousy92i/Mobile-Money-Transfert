# reception/models.py - VERSION CORRIGÉE POUR INTÉGRATION

from django.db import models
from django.conf import settings
from django.utils import timezone
import random
import string

class StatutReception(models.TextChoices):
    EN_ATTENTE = 'EN_ATTENTE', 'En attente'
    NOTIFIE = 'NOTIFIE', 'Notifié'
    CONFIRME = 'CONFIRME', 'Confirmé'
    RETIRE = 'RETIRE', 'Retiré'

class ModeReception(models.TextChoices):
    WAVE = 'WAVE', 'Wave'
    ORANGE_MONEY = 'ORANGE_MONEY', 'Orange Money'
    WESTERN_UNION = 'WESTERN_UNION', 'Western Union'
    AGENT_LOCAL = 'AGENT_LOCAL', 'Agent Local'

class Reception(models.Model):
    # ===== LIEN AVEC VOTRE SYSTÈME TRANSACTION =====
    transaction_origine = models.OneToOneField(
        'transactions.Transaction',
        on_delete=models.CASCADE,
        related_name='reception',
        null=True,
        blank=True,
        help_text="Transaction qui génère cette réception"
    )
    
    # ===== DESTINATAIRE =====
    destinataire = models.ForeignKey(
        settings.AUTH_USER_MODEL,  # ✅ Utilise authentication.User
        on_delete=models.CASCADE, 
        related_name='receptions',
        help_text="Utilisateur qui reçoit l'argent"
    )
    
    # ===== CODES ET MONTANTS =====
    code_reception = models.CharField(
        max_length=20, 
        unique=True,
        help_text="Code de réception pour le destinataire"
    )
    montant_a_recevoir = models.DecimalField(
        max_digits=15, 
        decimal_places=2,
        help_text="Montant que le destinataire va recevoir"
    )
    devise_reception = models.CharField(
        max_length=3, 
        default='XOF',
        help_text="Devise de réception"
    )
    
    # ===== MODE DE RÉCEPTION =====
    mode_reception = models.CharField(
        max_length=20,
        choices=ModeReception.choices,
        help_text="Mode choisi pour recevoir l'argent"
    )
    canal_paiement = models.ForeignKey(
        'transactions.CanalPaiement',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='receptions',
        help_text="Canal de paiement utilisé pour la réception"
    )
    
    # ===== STATUT ET DATES =====
    statut = models.CharField(
        max_length=12, 
        choices=StatutReception.choices, 
        default=StatutReception.EN_ATTENTE
    )
    date_notification = models.DateTimeField(
        null=True, 
        blank=True,
        help_text="Date d'envoi de la notification"
    )
    date_confirmation = models.DateTimeField(
        null=True, 
        blank=True,
        help_text="Date de confirmation par le destinataire"
    )
    date_retrait = models.DateTimeField(
        null=True, 
        blank=True,
        help_text="Date effective du retrait"
    )
    
    # ===== NOTIFICATIONS =====
    notification_envoyee = models.BooleanField(
        default=False,
        help_text="Notification système envoyée"
    )
    sms_envoye = models.BooleanField(
        default=False,
        help_text="SMS de notification envoyé"
    )
    email_envoye = models.BooleanField(
        default=False,
        help_text="Email de notification envoyé"
    )
    
    # ===== INFORMATIONS EXPÉDITEUR =====
    expediteur_nom = models.CharField(
        max_length=200,
        blank=True,
        help_text="Nom de l'expéditeur pour affichage"
    )
    expediteur_telephone = models.CharField(
        max_length=20,
        blank=True,
        help_text="Téléphone de l'expéditeur"
    )
    message_expediteur = models.TextField(
        blank=True,
        help_text="Message de l'expéditeur au destinataire"
    )
    
    # ===== MÉTADONNÉES =====
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'receptions'
        verbose_name = 'Réception'
        verbose_name_plural = 'Réceptions'
        ordering = ['-created_at']
        
        indexes = [
            models.Index(fields=['statut', 'date_notification']),
            models.Index(fields=['destinataire', 'created_at']),
            models.Index(fields=['code_reception']),
        ]
    
    def save(self, *args, **kwargs):
        """Override save pour générer code automatiquement"""
        if not self.code_reception:
            self.code_reception = self.generer_code_reception()
        
        # Synchroniser avec transaction d'origine si existe
        if self.transaction_origine and not self.expediteur_nom:
            self.expediteur_nom = self.transaction_origine.expediteur.get_full_name()
            self.expediteur_telephone = self.transaction_origine.expediteur.phone_number
        
        super().save(*args, **kwargs)
    
    def generer_code_reception(self):
        """Générer un code de réception unique"""
        max_attempts = 10
        for _ in range(max_attempts):
            code = f"RCP{timezone.now().year}{random.randint(100000, 999999)}"
            if not Reception.objects.filter(code_reception=code).exists():
                return code
        
        # Fallback
        timestamp = int(timezone.now().timestamp())
        return f"RCP{timestamp}"
    
    def __str__(self):
        return f"Réception {self.code_reception} - {self.destinataire.get_full_name()}"
    
    # ===== PROPRIÉTÉS MÉTIER =====
    
    @property
    def destinataire_nom_complet(self):
        """Nom complet du destinataire"""
        return self.destinataire.get_full_name()
    
    @property
    def destinataire_telephone(self):
        """Téléphone du destinataire"""
        return self.destinataire.phone_number
    
    @property
    def est_en_attente_retrait(self):
        """Vérifier si en attente de retrait"""
        return self.statut in [StatutReception.NOTIFIE, StatutReception.CONFIRME]
    
    @property
    def est_termine(self):
        """Vérifier si la réception est terminée"""
        return self.statut == StatutReception.RETIRE
    
    @property
    def duree_traitement(self):
        """Durée depuis la création"""
        if self.date_retrait:
            return self.date_retrait - self.created_at
        return timezone.now() - self.created_at
    
    # ===== MÉTHODES MÉTIER =====
    
    def envoyer_notification(self):
        """Envoyer notification de réception au destinataire"""
        if self.notification_envoyee:
            return False, "Notification déjà envoyée"
        
        try:
            # ===== INTÉGRATION AVEC SYSTÈME NOTIFICATIONS (DEV 1) =====
            from notifications.views import NotificationChannelFactory
            
            notification_channel = NotificationChannelFactory.get_channel('database')
            
            # Créer notification personnalisée
            notification_channel.send(
                user=self.destinataire,
                title="💰 Argent à recevoir",
                message=f"Vous avez reçu {self.montant_a_recevoir:,.0f} {self.devise_reception} de {self.expediteur_nom}. Code de réception: {self.code_reception}",
                notification_type='TRANSACTION'
            )
            
            # Marquer comme envoyée
            self.notification_envoyee = True
            self.date_notification = timezone.now()
            self.statut = StatutReception.NOTIFIE
            self.save()
            
            return True, "Notification envoyée avec succès"
            
        except Exception as e:
            return False, f"Erreur envoi notification: {str(e)}"
    
    def confirmer_reception(self, mode_choisi=None):
        """Confirmer la réception par le destinataire"""
        if self.statut not in [StatutReception.NOTIFIE]:
            return False, "Réception déjà confirmée ou non notifiée"
        
        if mode_choisi:
            self.mode_reception = mode_choisi
        
        self.statut = StatutReception.CONFIRME
        self.date_confirmation = timezone.now()
        self.save()
        
        # Notification de confirmation
        try:
            from notifications.views import NotificationChannelFactory
            notification_channel = NotificationChannelFactory.get_channel('database')
            
            notification_channel.send(
                user=self.destinataire,
                title="✅ Réception confirmée",
                message=f"Votre réception de {self.montant_a_recevoir:,.0f} {self.devise_reception} est confirmée. Mode: {self.get_mode_reception_display()}",
                notification_type='INFO'
            )
        except:
            pass
        
        return True, "Réception confirmée"
    
    def finaliser_retrait(self, verification_data=None):
        """Finaliser le retrait effectif"""
        if self.statut != StatutReception.CONFIRME:
            return False, "Réception non confirmée"
        
        self.statut = StatutReception.RETIRE
        self.date_retrait = timezone.now()
        self.save()
        
        # ===== INTÉGRATION AVEC TRANSACTION (DEV 2) =====
        if self.transaction_origine:
            from transactions.models import StatutTransaction
            self.transaction_origine.statusTransaction = StatutTransaction.TERMINE
            self.transaction_origine.save()
            # Les signals vont automatiquement envoyer les notifications finales
        
        # Notification de finalisation
        try:
            from notifications.views import NotificationChannelFactory
            notification_channel = NotificationChannelFactory.get_channel('database')
            
            notification_channel.send(
                user=self.destinataire,
                title="🎉 Retrait effectué",
                message=f"Vous avez retiré {self.montant_a_recevoir:,.0f} {self.devise_reception} avec succès via {self.get_mode_reception_display()}",
                notification_type='TRANSACTION'
            )
        except:
            pass
        
        return True, "Retrait finalisé"
    
    def annuler_reception(self, raison=""):
        """Annuler la réception"""
        if self.statut == StatutReception.RETIRE:
            return False, "Réception déjà retirée"
        
        # Remettre transaction en statut ENVOYE si nécessaire
        if self.transaction_origine:
            from transactions.models import StatutTransaction
            self.transaction_origine.statusTransaction = StatutTransaction.ENVOYE
            self.transaction_origine.save()
        
        # Supprimer ou marquer comme annulée selon votre logique
        # Pour l'instant on supprime
        self.delete()
        return True, "Réception annulée"
    
    @classmethod
    def creer_depuis_transaction(cls, transaction):
        """Créer une réception à partir d'une transaction"""
        # Vérifier si une réception existe déjà
        if hasattr(transaction, 'reception'):
            return transaction.reception, False
        
        # Créer nouvelle réception
        reception = cls.objects.create(
            transaction_origine=transaction,
            destinataire=transaction.destinataire if transaction.destinataire else None,
            montant_a_recevoir=transaction.montantRecu,
            devise_reception=transaction.deviseReception,
            mode_reception=cls._map_canal_to_mode(transaction.canal_paiement),
            canal_paiement=transaction.canal_paiement,
            expediteur_nom=transaction.expediteur.get_full_name(),
            expediteur_telephone=transaction.expediteur.phone_number
        )
        
        # Envoyer notification automatiquement
        reception.envoyer_notification()
        
        return reception, True
    
    @staticmethod
    def _map_canal_to_mode(canal_paiement):
        """Mapper canal de paiement vers mode de réception"""
        if not canal_paiement:
            return ModeReception.AGENT_LOCAL
        
        mapping = {
            'WAVE': ModeReception.WAVE,
            'ORANGE_MONEY': ModeReception.ORANGE_MONEY,
            'WESTERN_UNION': ModeReception.WESTERN_UNION,
        }
        return mapping.get(canal_paiement.type_canal, ModeReception.AGENT_LOCAL)

# ===== SIGNAL POUR INTÉGRATION AUTOMATIQUE =====
from django.db.models.signals import post_save
from django.dispatch import receiver

@receiver(post_save, sender='transactions.Transaction')
def creer_reception_automatique(sender, instance, created, **kwargs):
    """Signal pour créer automatiquement une réception quand transaction = ENVOYE"""
    # Importer ici pour éviter circular import
    from transactions.models import StatutTransaction
    
    # Créer réception quand transaction devient ENVOYE
    if (instance.statusTransaction == StatutTransaction.ENVOYE and 
        instance.destinataire and 
        not hasattr(instance, 'reception')):
        
        Reception.creer_depuis_transaction(instance)

# ===== INTÉGRATION PARFAITE AVEC VOTRE SYSTÈME =====
"""
✅ CORRECTIONS APPORTÉES :

1. 🔗 INTÉGRATION TRANSACTION :
   - OneToOneField vers transactions.Transaction
   - Création automatique via signal
   - Synchronisation statuts bidirectionnelle

2. 👤 USER MODEL CORRECT :
   - settings.AUTH_USER_MODEL pour destinataire
   - Compatible avec authentication.User
   - Accès phone_number et méthodes User

3. 🔔 NOTIFICATIONS INTÉGRÉES :
   - Utilise NotificationChannelFactory (Dev 1)
   - Notifications automatiques à chaque étape
   - Messages personnalisés selon contexte

4. 📱 WORKFLOW COMPLET :
   - EN_ATTENTE → notification → NOTIFIE
   - Confirmation → CONFIRME
   - Retrait → RETIRE + transaction TERMINE

5. 🎯 BUSINESS LOGIC :
   - Création automatique depuis transaction
   - Mapping canal → mode réception
   - Gestion erreurs et annulations

🔄 WORKFLOW AUTOMATIQUE INTÉGRÉ :
1. Transaction créée (Dev 2) → ENVOYE
2. Signal → Réception automatique
3. Notification envoyée (Dev 1) → NOTIFIE
4. User confirme → CONFIRME  
5. Retrait effectué → RETIRE
6. Transaction → TERMINE + notifications finales

🎯 UTILISATION :
# Création manuelle
reception = Reception.objects.create(
    destinataire=user,
    montant_a_recevoir=50000,
    mode_reception='WAVE'
)
reception.envoyer_notification()

# Création automatique via transaction
transaction.statusTransaction = 'ENVOYE'
transaction.save()  # → Signal crée Reception automatiquement
"""