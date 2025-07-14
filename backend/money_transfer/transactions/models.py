# transactions/models.py - MODÈLE COMPLET AVEC CORRECTIONS

from django.db import models, IntegrityError
from django.utils import timezone
from django.conf import settings
import uuid
import random
import string
from decimal import Decimal
from decimal import Decimal
from datetime import timedelta
import re

# Assurez-vous que ces imports sont présents
from django.core.validators import RegexValidator

class StatutTransaction(models.TextChoices):
    """Enum pour le statut des transactions selon UML"""
    EN_ATTENTE = 'EN_ATTENTE', 'En Attente'
    ACCEPTE = 'ACCEPTE', 'Accepté'
    ENVOYE = 'ENVOYE', 'Envoyé'
    TERMINE = 'TERMINE', 'Terminé'
    ANNULE = 'ANNULE', 'Annulé'

class TypeTransaction(models.TextChoices):
    """Enum pour le type de transaction"""
    ENVOI = 'ENVOI', 'Envoi'
    RECEPTION = 'RECEPTION', 'Réception'
    RETRAIT = 'RETRAIT', 'Retrait'
    RECHARGE = 'RECHARGE', 'Recharge'

class CanalPaiement(models.Model):
    """Méthodes de paiement disponibles - AVEC CALCULS CORRIGÉS"""
    
    PAYMENT_TYPES = [
        ('WAVE', 'Wave'),
        ('ORANGE_MONEY', 'Orange Money'),
        ('KPAY', 'Kpay')
    ]
    
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    
    canal_name = models.CharField(max_length=50)
    type_canal = models.CharField(max_length=50, choices=PAYMENT_TYPES)
    is_active = models.BooleanField(default=True)
    country = models.CharField(max_length=50)
    fees_percentage = models.DecimalField(max_digits=5, decimal_places=2)
    fees_fixed = models.DecimalField(max_digits=5, decimal_places=2, default=2.5)
    min_amount = models.DecimalField(max_digits=10, decimal_places=2, default=100.00)
    max_amount = models.DecimalField(max_digits=10, decimal_places=2, default=500000.00)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Canal de Paiement"
        verbose_name_plural = "Canaux de Paiement"
        ordering = ['canal_name']
    
    def __str__(self):
        return f"{self.canal_name} ({self.type_canal})"
    
    def calculate_fees(self, amount):
        """Calcule les frais pour un montant donné - VERSION CORRIGÉE"""
        # Convertir amount en Decimal si nécessaire
        if not isinstance(amount, Decimal):
            amount = Decimal(str(amount))
        
        # Calcul des frais en Decimal
        percentage_fee = (amount * self.fees_percentage) / Decimal('100')
        total_fee = percentage_fee + self.fees_fixed
        
        return total_fee.quantize(Decimal('0.01'))
    
    def calculate_total_amount(self, amount):
        """Calcule le montant total avec frais - VERSION CORRIGÉE"""
        if not isinstance(amount, Decimal):
            amount = Decimal(str(amount))
            
        fees = self.calculate_fees(amount)
        return amount + fees
    
    def is_amount_valid(self, amount):
        """Vérifie si le montant est dans les limites - VERSION CORRIGÉE"""
        if not isinstance(amount, Decimal):
            amount = Decimal(str(amount))
            
        return self.min_amount <= amount <= self.max_amount


class Transaction(models.Model):
    """Modèle pour les transactions selon UML - AVEC RELATIONS USER"""
    
    # UUID comme clé primaire
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    
    # ID numérique unique
    idTransaction = models.PositiveIntegerField(
        unique=True,
        help_text="Id numérique unique de la transaction",
        editable=False
    )
    
    # Type de transaction
    typeTransaction = models.CharField(
        max_length=15,
        choices=TypeTransaction.choices,
        default=TypeTransaction.ENVOI,
        help_text="Le type de la transaction"
    )
    
    # ===== RELATIONS USER =====
    
    # Expéditeur (celui qui envoie l'argent)
    expediteur = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='transactions_envoyees',
        help_text="L'utilisateur qui envoie l'argent"
    )
    
    # Destinataire (celui qui reçoit) - Optionnel si pas encore inscrit
    destinataire = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name='transactions_recues',
        null=True,
        blank=True,
        help_text="L'utilisateur qui reçoit l'argent (si inscrit)"
    )
    
    # Téléphone du destinataire (toujours présent)
    destinataire_phone = models.CharField(
        max_length=20,
        help_text="Numéro de téléphone du destinataire"
    )
    
    # Nom du destinataire (pour l'affichage)
    destinataire_nom = models.CharField(
        max_length=100,
        blank=True,
        help_text="Nom d'affichage du destinataire"
    )
    
    # ===== MONTANTS =====
    
    montantEnvoye = models.FloatField(
        help_text="Le montant envoyé"
    )
    
    montantConverti = models.FloatField(
        help_text="Le montant après conversion/frais"
    )
    
    statusTransaction = models.CharField(
        max_length=15,
        choices=StatutTransaction.choices,
        default=StatutTransaction.EN_ATTENTE,
        help_text="Le statut de la transaction"
    )
    
    montantRecu = models.FloatField(
        help_text="Le montant reçu par le bénéficiaire"
    )
    
    deviseEnvoi = models.CharField(
        max_length=10,
        default="XOF",
        help_text="La devise de l'envoi"
    )
    
    deviseReception = models.CharField(
        max_length=10,
        default="XOF",
        help_text="La devise du reçu"
    )
    
    codeTransaction = models.CharField(
        max_length=20,
        unique=True,
        help_text="Le code de la transaction"
    )
    
    frais = models.CharField(
        max_length=50,
        help_text="Frais de la transaction"
    )
    
    dateTraitement = models.DateField(
        auto_now_add=True,
        help_text="Date de traitement de la transaction"
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # ===== RELATION CANAL DE PAIEMENT =====
    canal_paiement = models.ForeignKey(
        'CanalPaiement',
        on_delete=models.PROTECT,
        related_name='transactions',
        help_text="Canal de paiement utilisé"
    )
    
    class Meta:
        verbose_name = "Transaction"
        verbose_name_plural = "Transactions"
        ordering = ['-created_at']
        # Index pour les requêtes fréquentes
        indexes = [
            models.Index(fields=['typeTransaction', 'statusTransaction']),
            models.Index(fields=['expediteur', 'created_at']),
            models.Index(fields=['destinataire', 'created_at']),
            models.Index(fields=['destinataire_phone']),
            models.Index(fields=['created_at']),
        ]
    
    def save(self, *args, **kwargs):
        """Override save pour générer automatiquement les codes"""
        max_attempts = 5
        
        for attempt in range(max_attempts):
            # Générer le code transaction si nécessaire
            if not self.codeTransaction:
                self.codeTransaction = self.generate_code_transaction()
            
            # Générer l'ID transaction si nécessaire
            if not self.idTransaction:
                self.idTransaction = self.generate_id_transaction()
            
            try:
                super().save(*args, **kwargs)
                break
                
            except IntegrityError as e:
                error_message = str(e).lower()
                
                if 'idtransaction' in error_message and attempt < max_attempts - 1:
                    self.idTransaction = self.generate_id_transaction()
                    continue
                    
                elif 'codetransaction' in error_message and attempt < max_attempts - 1:
                    self.codeTransaction = self.generate_code_transaction()
                    continue
                    
                else:
                    raise e
    
    def generate_code_transaction(self):
        """Génère un code de transaction unique avec préfixe selon le type"""
        max_attempts = 10
        for attempt in range(max_attempts):
            year = timezone.now().year
            random_part = ''.join(random.choices(string.digits, k=8))
            
            # Préfixe selon le type
            prefix = self.get_code_prefix()
            code = f"{prefix}{year}{random_part}"
            
            if not Transaction.objects.filter(codeTransaction=code).exists():
                return code
        
        # Fallback avec timestamp
        timestamp = int(timezone.now().timestamp())
        prefix = self.get_code_prefix()
        return f"{prefix}{year}{timestamp}"
    
    def get_code_prefix(self):
        """Retourne le préfixe du code selon le type"""
        prefixes = {
            TypeTransaction.ENVOI: 'TXN',
            TypeTransaction.RECEPTION: 'RCP',
            TypeTransaction.RETRAIT: 'RET',
            TypeTransaction.RECHARGE: 'RCH',
        }
        return prefixes.get(self.typeTransaction, 'TXN')
    
    def generate_id_transaction(self):
        """Génère un ID transaction numérique unique"""
        from django.db import transaction
        
        with transaction.atomic():
            max_id = Transaction.objects.select_for_update().aggregate(
                max_id=models.Max('idTransaction')
            )['max_id']
            
            if max_id:
                new_id = max_id + 1
            else:
                new_id = 100000001
            
            while Transaction.objects.filter(idTransaction=new_id).exists():
                new_id += 1
                
                if new_id > max_id + 1000 if max_id else 100001000:
                    timestamp_part = int(timezone.now().timestamp()) % 1000000
                    new_id = 100000000 + timestamp_part
                    break
            
            return new_id
    
    def __str__(self):
        return f"Transaction {self.codeTransaction} - {self.get_typeTransaction_display()} - {self.montantEnvoye} {self.deviseEnvoi}"
    
    # ===== MÉTHODES AVEC USER =====
    
    @property
    def expediteur_nom_complet(self):
        """Nom complet de l'expéditeur"""
        if self.expediteur:
            return self.expediteur.get_full_name()
        return "Utilisateur inconnu"
    
    @property
    def destinataire_nom_complet(self):
        """Nom complet du destinataire"""
        if self.destinataire:
            return self.destinataire.get_full_name()
        elif self.destinataire_nom:
            return self.destinataire_nom
        else:
            return f"Contact {self.destinataire_phone}"
    
    @property
    def destinataire_est_inscrit(self):
        """Vrai si le destinataire est un utilisateur inscrit"""
        return self.destinataire is not None
    
    def peut_etre_retiree_par(self, user):
        """Vérifie si un utilisateur peut retirer cette transaction"""
        # Le destinataire inscrit peut retirer
        if self.destinataire and self.destinataire == user:
            return True
        
        # Ou un utilisateur avec le même numéro de téléphone
        if user.phone_number == self.destinataire_phone:
            return True
        
        return False
    
    # Méthodes utilitaires existantes
    @property
    def is_sending_money(self):
        """Vrai si c'est un envoi d'argent"""
        return self.typeTransaction == TypeTransaction.ENVOI
    
    @property
    def is_receiving_money(self):
        """Vrai si c'est une réception d'argent"""
        return self.typeTransaction == TypeTransaction.RECEPTION
    
    @property
    def is_withdrawal(self):
        """Vrai si c'est un retrait"""
        return self.typeTransaction == TypeTransaction.RETRAIT
    
    @property
    def is_recharge(self):
        """Vrai si c'est une recharge"""
        return self.typeTransaction == TypeTransaction.RECHARGE


class Beneficiaire(models.Model):
    """Bénéficiaire/Destinataire - AVEC RELATION USER"""
    
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    
    # Propriétaire du carnet d'adresses
    proprietaire = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='beneficiaires',
        help_text="L'utilisateur qui possède ce contact"
    )
    
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    phone = models.CharField(max_length=50)
    
    # Utilisateur correspondant (si inscrit)
    user_correspondant = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name='beneficiaire_entries',
        null=True,
        blank=True,
        help_text="L'utilisateur correspondant à ce contact (si inscrit)"
    )
    
    # Fréquence d'utilisation pour les favoris
    nb_transactions = models.PositiveIntegerField(default=0)
    derniere_transaction = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = "Bénéficiaire"
        verbose_name_plural = "Bénéficiaires"
        ordering = ['-derniere_transaction', '-nb_transactions', 'first_name']
        
        # Un utilisateur ne peut pas avoir le même contact deux fois
        unique_together = ['proprietaire', 'phone']
        
        indexes = [
            models.Index(fields=['proprietaire', 'phone']),
            models.Index(fields=['proprietaire', '-derniere_transaction']),
        ]
    
    def __str__(self):
        return f"{self.first_name} {self.last_name} - {self.phone} (de {self.proprietaire.get_full_name()})"
    
    @property
    def nom_complet(self):
        """Nom complet du bénéficiaire"""
        return f"{self.first_name} {self.last_name}".strip()
    
    @property
    def est_utilisateur_inscrit(self):
        """Vrai si ce contact correspond à un utilisateur inscrit"""
        return self.user_correspondant is not None
    
    def marquer_transaction(self):
        """Marquer une nouvelle transaction avec ce bénéficiaire"""
        self.nb_transactions += 1
        self.derniere_transaction = timezone.now()
        self.save(update_fields=['nb_transactions', 'derniere_transaction'])
        
        

# transactions/models.py - AJOUTS INTERNATIONAUX

# transactions/models.py - AJOUTS INTERNATIONAUX

# Dans transactions/models.py - CORRIGER le modèle Pays

class Pays(models.Model):
    """Pays supportés pour transferts internationaux - VERSION CORRIGÉE"""
    code_iso = models.CharField(max_length=3, unique=True)  # SEN, COG, MLI, CIV
    nom = models.CharField(max_length=50)
    devise = models.CharField(max_length=3)  # XOF, CDF, XAF, EUR
    prefixe_tel = models.CharField(max_length=5)  # +221, +243, +223
    is_active = models.BooleanField(default=True)
    flag_emoji = models.CharField(max_length=10, default="🇸🇳")
    
    # ===== CHAMPS QUI MANQUAIENT =====
    limite_envoi_min = models.DecimalField(
        max_digits=10, 
        decimal_places=2, 
        default=100,
        help_text="Montant minimum pour envoi vers ce pays"
    )
    limite_envoi_max = models.DecimalField(
        max_digits=10, 
        decimal_places=2, 
        default=500000,
        help_text="Montant maximum pour envoi vers ce pays"
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Pays"
        verbose_name_plural = "Pays"
    
    def __str__(self):
        return f"{self.flag_emoji} {self.nom} ({self.devise})"

# Dans transactions/models.py - Mettre à jour ServicePaiementInternational

class ServicePaiementInternational(models.Model):
    """Services de paiement mobile par pays - VERSION ÉTENDUE 10 PAYS"""
    
    TYPE_CHOICES = [
        # Services existants
        ('MTN_MONEY', 'MTN Money'),
        ('AIRTEL_MONEY', 'Airtel Money'), 
        ('ORANGE_MONEY', 'Orange Money'),
        ('WAVE', 'Wave'),
        ('MOOV_MONEY', 'Moov Money'),
        ('WESTERN_UNION', 'Western Union'),
        ('MONEYGRAM', 'MoneyGram'),
        
        # NOUVEAUX SERVICES POUR LES 10 PAYS
        ('INWI_MONEY', 'Inwi Money'),           # Maroc
        ('OPAY', 'Opay'),                       # Nigeria
        ('VODAFONE_CASH', 'Vodafone Cash'),     # Ghana
        ('AIRTELTIGO_MONEY', 'AirtelTigo Money'), # Ghana
        ('TIGO_CASH', 'Tigo Cash'),             # Ghana (alternative)
        ('ECOBANK_MOBILE', 'Ecobank Mobile'),   # Multi-pays
        ('UBA_MOBILE', 'UBA Mobile'),           # Multi-pays
        ('ZENITH_MOBILE', 'Zenith Mobile'),     # Nigeria
        ('ACCESS_MOBILE', 'Access Mobile'),     # Nigeria
        ('FIDELITY_MOBILE', 'Fidelity Mobile'), # Nigeria
    ]
    
    
    pays = models.ForeignKey(Pays, on_delete=models.CASCADE, related_name='services')
    nom = models.CharField(max_length=50)  # "MTN Money Congo", "Orange Mali"
    type_service = models.CharField(max_length=20, choices=TYPE_CHOICES)
    code_service = models.CharField(max_length=10)  # MTN_CG, OM_ML, WAVE_SN
    
    # Configuration technique
    api_url = models.URLField(blank=True)
    is_active = models.BooleanField(default=True)
    
    # Configuration financière
    frais_percentage = models.DecimalField(max_digits=5, decimal_places=2)
    frais_fixe = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    frais_min = models.DecimalField(max_digits=8, decimal_places=2)
    frais_max = models.DecimalField(max_digits=8, decimal_places=2)
    
    # Limites de transaction
    limite_min = models.DecimalField(max_digits=10, decimal_places=2)
    limite_max = models.DecimalField(max_digits=10, decimal_places=2)
    
    # Validation numéros
    regex_telephone = models.CharField(max_length=100, help_text="Regex pour valider les numéros")
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    def validate_phone(self, phone_number):
        """Valider le numéro selon le service"""
        import re
        return bool(re.match(self.regex_telephone, phone_number))
    
    def calculate_fees(self, amount):
        """Calculer frais selon la configuration du service"""
        from decimal import Decimal
        if not isinstance(amount, Decimal):
            amount = Decimal(str(amount))
            
        fee = (amount * self.frais_percentage) / Decimal('100') + self.frais_fixe
        return max(min(fee, self.frais_max), self.frais_min)
class TauxChange(models.Model):
    """Taux de change temps réel entre devises"""
    devise_origine = models.CharField(max_length=3)  # XOF
    devise_destination = models.CharField(max_length=3)  # CDF, XAF, EUR
    
    taux = models.DecimalField(max_digits=12, decimal_places=6)
    taux_inverse = models.DecimalField(max_digits=12, decimal_places=6)  # Optimisation
    
    # Source et fiabilité
    source = models.CharField(max_length=20, default="xe.com")
    last_updated = models.DateTimeField(auto_now=True)
    is_active = models.BooleanField(default=True)
    
    # Marges business
    marge_achat = models.DecimalField(max_digits=5, decimal_places=4, default=0.02)  # 2%
    marge_vente = models.DecimalField(max_digits=5, decimal_places=4, default=0.02)
    
    class Meta:
        unique_together = ['devise_origine', 'devise_destination']
        indexes = [
            models.Index(fields=['devise_origine', 'devise_destination']),
            models.Index(fields=['last_updated']),
        ]
    
    def get_taux_client(self, type_operation='vente'):
        """Taux avec marge pour client"""
        if type_operation == 'vente':
            return self.taux * (1 + self.marge_vente)
        else:
            return self.taux * (1 - self.marge_achat)
        
        
class CorridorTransfert(models.Model):
    """Corridors de transfert entre pays"""
    pays_origine = models.ForeignKey(Pays, on_delete=models.CASCADE, related_name='corridors_sortants')
    pays_destination = models.ForeignKey(Pays, on_delete=models.CASCADE, related_name='corridors_entrants')
    
    # Configuration business
    is_active = models.BooleanField(default=True)
    temps_livraison_min = models.PositiveIntegerField(help_text="Minutes minimum")
    temps_livraison_max = models.PositiveIntegerField(help_text="Minutes maximum")
    
    # Commission corridor (en plus des frais services)
    commission_percentage = models.DecimalField(max_digits=5, decimal_places=2, default=0.5)
    commission_fixe = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    
    # Limites spécifiques au corridor
    montant_min_corridor = models.DecimalField(max_digits=10, decimal_places=2)
    montant_max_corridor = models.DecimalField(max_digits=10, decimal_places=2)
    
    # Statistiques
    nb_transactions = models.PositiveIntegerField(default=0)
    volume_total = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    taux_succes = models.DecimalField(max_digits=5, decimal_places=2, default=95.0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ['pays_origine', 'pays_destination']
    
    def __str__(self):
        return f"{self.pays_origine.nom} → {self.pays_destination.nom}"
    
    @property
    def code_corridor(self):
        return f"{self.pays_origine.code_iso}_TO_{self.pays_destination.code_iso}"
class TransactionInternationale(models.Model):
    """Extension internationale des transactions existantes"""
    # Lien avec transaction locale
    transaction_locale = models.OneToOneField(
        Transaction, 
        on_delete=models.CASCADE,
        related_name='extension_internationale'
    )
    
    # Géographie
    pays_origine = models.ForeignKey(Pays, on_delete=models.PROTECT, related_name='envois')
    pays_destination = models.ForeignKey(Pays, on_delete=models.PROTECT, related_name='receptions')
    corridor = models.ForeignKey(CorridorTransfert, on_delete=models.PROTECT)
    
    # Services utilisés
    service_origine = models.ForeignKey(
        ServicePaiementInternational, 
        on_delete=models.PROTECT,
        related_name='transactions_origine'
    )
    service_destination = models.ForeignKey(
        ServicePaiementInternational,
        on_delete=models.PROTECT, 
        related_name='transactions_destination'
    )
    
    # Calculs financiers
    taux_applique = models.DecimalField(max_digits=12, decimal_places=6)
    montant_origine = models.DecimalField(max_digits=10, decimal_places=2)
    montant_destination = models.DecimalField(max_digits=10, decimal_places=2)
    
    # Frais détaillés
    frais_service_origine = models.DecimalField(max_digits=8, decimal_places=2)
    frais_service_destination = models.DecimalField(max_digits=8, decimal_places=2)
    commission_corridor = models.DecimalField(max_digits=8, decimal_places=2)
    frais_change = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    
    # Tracking et timing
    reference_externe = models.CharField(max_length=50, blank=True)
    temps_traitement_estime = models.PositiveIntegerField()  # Minutes
    date_livraison_estimee = models.DateTimeField()
    date_livraison_reelle = models.DateTimeField(null=True, blank=True)
    
    # Métadonnées
    metadata = models.JSONField(default=dict, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    @property
    def est_livre_dans_les_temps(self):
        """Vérifier si livré dans les SLA"""
        if not self.date_livraison_reelle:
            return None
        return self.date_livraison_reelle <= self.date_livraison_estimee
    
    def calculer_temps_reel(self):
        """Temps réel de traitement en minutes"""
        if self.date_livraison_reelle:
            delta = self.date_livraison_reelle - self.created_at
            return int(delta.total_seconds() / 60)
        return None