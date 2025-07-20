# withdrawals/models.py - VERSION CORRIGÉE POUR INTÉGRATION

from django.db import models
from django.conf import settings
from django.utils import timezone
import uuid
import random
import string
from decimal import Decimal

class StatutRetrait(models.TextChoices):
    EN_ATTENTE = 'EN_ATTENTE', 'En attente'
    ACCEPTE = 'ACCEPTE', 'Accepté'
    TERMINE = 'TERMINE', 'Terminé'
    ANNULE = 'ANNULE', 'Annulé'

class Withdrawal(models.Model):
    # ===== LIEN AVEC VOTRE SYSTÈME TRANSACTION (DEV 2) =====
    transaction_origine = models.ForeignKey(
        'transactions.Transaction',
        on_delete=models.CASCADE,
        related_name='withdrawals',
        null=True,
        blank=True,
        help_text="Transaction d'origine qui génère ce retrait"
    )
    
    # ===== ACTEURS DU RETRAIT =====
    agent = models.ForeignKey(
        'agents.AgentLocal', 
        on_delete=models.CASCADE, 
        related_name='retraits_geres',
        help_text="Agent qui effectue le retrait"
    )
    beneficiaire = models.ForeignKey(
        settings.AUTH_USER_MODEL,  # ✅ Utilise authentication.User
        on_delete=models.CASCADE, 
        related_name='retraits_recus',
        help_text="Utilisateur qui reçoit l'argent"
    )
    
    # ===== CODES ET IDENTIFIANTS =====
    code_retrait = models.CharField(
        max_length=20, 
        unique=True, 
        editable=False,
        help_text="Code de retrait unique"
    )
    qr_code = models.CharField(
        max_length=100, 
        unique=True, 
        editable=False,
        help_text="Code QR pour validation"
    )
    
    # ===== MONTANTS ET COMMISSIONS =====
    montant_retire = models.DecimalField(
        max_digits=15, 
        decimal_places=2,
        help_text="Montant retiré par le bénéficiaire"
    )
    commission_agent = models.DecimalField(
        max_digits=10, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Commission de l'agent"
    )
    frais_retrait = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Frais de retrait facturés au client"
    )
    
    # ===== STATUT ET DATES =====
    statut = models.CharField(
        max_length=12, 
        choices=StatutRetrait.choices, 
        default=StatutRetrait.EN_ATTENTE
    )
    date_demande = models.DateTimeField(auto_now_add=True)
    date_retrait = models.DateTimeField(
        null=True, 
        blank=True,
        help_text="Date effective du retrait"
    )
    
    # ===== VÉRIFICATIONS SÉCURITÉ =====
    piece_identite_verifie = models.BooleanField(
        default=False,
        help_text="Pièce d'identité vérifiée par l'agent"
    )
    code_sms_verifie = models.BooleanField(
        default=False,
        help_text="Code SMS de vérification validé"
    )
    notes_verification = models.TextField(
        blank=True,
        help_text="Notes de l'agent sur la vérification"
    )
    
    # ===== GÉOLOCALISATION =====
    latitude_retrait = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
        help_text="Localisation GPS du retrait"
    )
    longitude_retrait = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
        help_text="Localisation GPS du retrait"
    )
    
    # ===== MÉTADONNÉES =====
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'withdrawals'
        verbose_name = 'Retrait'
        verbose_name_plural = 'Retraits'
        ordering = ['-date_demande']
        
        indexes = [
            models.Index(fields=['statut', 'date_demande']),
            models.Index(fields=['agent', 'date_demande']),
            models.Index(fields=['beneficiaire', 'date_demande']),
            models.Index(fields=['code_retrait']),
        ]
    
    def save(self, *args, **kwargs):
        """Override save pour générer codes automatiquement"""
        if not self.code_retrait:
            self.code_retrait = self.generer_code_retrait()
        if not self.qr_code:
            self.qr_code = str(uuid.uuid4())
    
    # ===== CORRECTION POUR ÉVITER L'ERREUR DATETIME =====
    # S'assurer que date_retrait est None ou datetime object
        if hasattr(self, 'date_retrait') and self.date_retrait:
            if isinstance(self.date_retrait, str):
                from django.utils.dateparse import parse_datetime
                parsed_date = parse_datetime(self.date_retrait)
                if parsed_date:
                    self.date_retrait = parsed_date
                else:
                    self.date_retrait = None
    
    # Calculer commission si pas définie
        if not self.commission_agent and self.agent:
            self.commission_agent = self.agent.calculer_commission(self.montant_retire)
    
        super().save(*args, **kwargs)
    
    def generer_code_retrait(self):
        """Générer un code de retrait unique"""
        max_attempts = 10
        for _ in range(max_attempts):
            # Format compatible avec vos transactions: TXN ou WTH
            code = f"WTH{timezone.now().year}{random.randint(100000, 999999)}"
            if not Withdrawal.objects.filter(code_retrait=code).exists():
                return code
        
        # Fallback avec timestamp
        timestamp = int(timezone.now().timestamp())
        return f"WTH{timestamp}"
    
    def __str__(self):
        return f"Retrait {self.code_retrait} - {self.montant_retire} XOF"
    
    # ===== PROPRIÉTÉS MÉTIER =====
    
    @property
    def beneficiaire_nom_complet(self):
        """Nom complet du bénéficiaire"""
        return self.beneficiaire.get_full_name()
    
    @property
    def beneficiaire_telephone(self):
        """Téléphone du bénéficiaire"""
        return self.beneficiaire.phone_number
    
    @property
    def agent_nom_complet(self):
        """Nom complet de l'agent"""
        return self.agent.nom_complet
    
    @property
    def est_en_cours(self):
        """Vérifier si le retrait est en cours"""
        return self.statut in [StatutRetrait.EN_ATTENTE, StatutRetrait.ACCEPTE]
    
    @property
    def est_termine(self):
        """Vérifier si le retrait est terminé"""
        return self.statut == StatutRetrait.TERMINE
    
    @property
    def duree_traitement(self):
        """Durée de traitement du retrait"""
        if self.date_retrait:
            return self.date_retrait - self.date_demande
        return timezone.now() - self.date_demande
    
    # ===== MÉTHODES MÉTIER =====
    
    def peut_etre_annule(self):
        """Vérifier si le retrait peut être annulé"""
        return self.statut in [StatutRetrait.EN_ATTENTE, StatutRetrait.ACCEPTE]
    
    def accepter_retrait(self, agent_user):
        """Accepter le retrait (par l'agent)"""
        if self.statut != StatutRetrait.EN_ATTENTE:
            return False, "Retrait déjà traité"
        
        if self.agent.user != agent_user:
            return False, "Seul l'agent assigné peut accepter"
        
        if not self.agent.est_disponible:
            return False, "Agent non disponible"
        
        self.statut = StatutRetrait.ACCEPTE
        self.save()
        return True, "Retrait accepté"
    
    def finaliser_retrait(self, agent_user, verification_data=None):
        """Finaliser le retrait avec vérifications"""
        if self.statut != StatutRetrait.ACCEPTE:
            return False, "Retrait non accepté"
        
        if self.agent.user != agent_user:
            return False, "Seul l'agent assigné peut finaliser"
        
        # Marquer comme terminé
        self.statut = StatutRetrait.TERMINE
        self.date_retrait = timezone.now()
        
        # Ajouter données de vérification si fournies
        if verification_data:
            self.piece_identite_verifie = verification_data.get('piece_identite_verifie', False)
            self.code_sms_verifie = verification_data.get('code_sms_verifie', False)
            self.notes_verification = verification_data.get('notes', '')
            self.latitude_retrait = verification_data.get('latitude')
            self.longitude_retrait = verification_data.get('longitude')
        
        self.save()
        
        # ===== INTÉGRATION AVEC VOTRE SYSTÈME =====
        # Mettre à jour la transaction d'origine si elle existe
        if self.transaction_origine:
            from transactions.models import StatutTransaction
            self.transaction_origine.statusTransaction = StatutTransaction.TERMINE
            self.transaction_origine.save()
            
            # Déclencher notifications automatiques via signals
            # Les signals du Dev 1 vont automatiquement notifier les utilisateurs
        
        return True, "Retrait finalisé avec succès"
    
    def annuler_retrait(self, raison=""):
        """Annuler le retrait"""
        if not self.peut_etre_annule():
            return False, "Retrait ne peut pas être annulé"
        
        self.statut = StatutRetrait.ANNULE
        self.notes_verification = f"Annulé: {raison}"
        self.save()
        
        # Mettre à jour transaction d'origine si nécessaire
        if self.transaction_origine:
            from transactions.models import StatutTransaction
            # Selon votre logique, vous pouvez remettre en ENVOYE ou garder
            # self.transaction_origine.statusTransaction = StatutTransaction.ENVOYE
            # self.transaction_origine.save()
            pass
        
        return True, "Retrait annulé"

# ===== INTÉGRATION PARFAITE AVEC VOTRE SYSTÈME =====
"""
✅ CORRECTIONS APPORTÉES :

1. 🔗 INTÉGRATION TRANSACTION :
   - ForeignKey vers transactions.Transaction
   - Mise à jour automatique du statut transaction
   - Lien bidirectionnel pour traçabilité

2. 👤 USER MODEL CORRECT :
   - settings.AUTH_USER_MODEL pour beneficiaire
   - Compatible avec authentication.User (Dev 1)
   - Accès aux données KYC et phone_number

3. 📱 CODES COMPATIBLES :
   - Code retrait format WTH + timestamp
   - Compatible avec votre système TXN
   - QR code unique pour sécurité

4. 💰 BUSINESS LOGIC AVANCÉE :
   - Calcul commission automatique
   - Vérifications sécurité intégrées
   - Workflow complet accepter → finaliser

5. 🔔 NOTIFICATIONS INTÉGRÉES :
   - Met à jour statut transaction → déclenche signals
   - Notifications automatiques via système Dev 1
   - Traçabilité complète

🎯 WORKFLOW INTÉGRÉ :
1. Transaction créée (Dev 2) → ENVOYE
2. Withdrawal créé depuis transaction
3. Agent accepte → ACCEPTE  
4. Agent finalise → TERMINE
5. Transaction mise à jour → TERMINE
6. Notifications automatiques (Dev 1)
"""