# transactions/models.py

from django.db import models
from django.utils import timezone
import uuid
import random
import string

class StatutTransaction(models.TextChoices):
    """Enum pour le statut des transactions selon UML"""
    EN_ATTENTE = 'EN_ATTENTE', 'En Attente'
    ACCEPTE = 'ACCEPTE', 'Accepté'
    ENVOYE = 'ENVOYE', 'Envoyé'
    TERMINE = 'TERMINE', 'Terminé'
    ANNULE = 'ANNULE', 'Annulé'

class Transaction(models.Model):
    """Modèle pour les transactions selon UML"""
    
    # UUID comme clé primaire
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    
    idTransaction = models.IntegerField(
        unique=True,
        help_text="Id de la transaction"
    )
    
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
    
    montantRecu = models.FloatField(  # Corrigé: sans ç
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
    
    created_at = models.DateTimeField(auto_now_add=True)  # Corrigé: DateTimeField
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = "Transaction"
        verbose_name_plural = "Transactions"
        ordering = ['-created_at']
    
    def save(self, *args, **kwargs):  # Corrigé: indentation
        """Override save pour générer automatiquement les codes"""
        if not self.codeTransaction:
            self.codeTransaction = self.generate_code_transaction()
        if not self.idTransaction:
            self.idTransaction = self.generate_id_transaction()
        super().save(*args, **kwargs)
    
    def generate_code_transaction(self):  # Corrigé: indentation
        """Génère un code de transaction unique TXN********"""
        year = timezone.now().year
        random_part = ''.join(random.choices(string.digits, k=6))
        return f"TXN{year}{random_part}"
    
    def generate_id_transaction(self):
        """Génère un ID transaction numérique unique"""
        # Récupérer le dernier ID + 1
        last_transaction = Transaction.objects.order_by('-idTransaction').last()
        if last_transaction and last_transaction.idTransaction:
            return last_transaction.idTransaction + 1
        else:
            return 100000001  # Premier ID (commence à 100000001)
    
    def __str__(self):  # Corrigé: indentation
        return f"Transaction {self.codeTransaction} - {self.montantEnvoye} {self.deviseEnvoi}"

class Beneficiaire(models.Model):  # Corrigé: nom de classe
    """Bénéficiaire/Destinataire"""
    
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    
    first_name = models.CharField(max_length=50)  # Corrigé: indentation
    last_name = models.CharField(max_length=50)
    phone = models.CharField(max_length=50)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = "Bénéficiaire"
        verbose_name_plural = "Bénéficiaires"  # Corrigé: orthographe
    
    def __str__(self):
        return f"{self.first_name} {self.last_name} - {self.phone}"  # Corrigé: complet

class CanalPaiement(models.Model):
    """Méthodes de paiement disponibles"""
    
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
    
    def __str__(self):
        return f"{self.canal_name} ({self.type_canal})"