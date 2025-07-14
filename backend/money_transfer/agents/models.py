# agents/models.py - VERSION CORRIGÉE POUR INTÉGRATION

from django.db import models
from django.conf import settings  # ✅ CORRECT: Utilise AUTH_USER_MODEL
from django.utils import timezone
from decimal import Decimal

class StatutAgent(models.TextChoices):
    ACTIF = 'ACTIF', 'Actif'
    SUSPENDU = 'SUSPENDU', 'Suspendu'
    INACTIF = 'INACTIF', 'Inactif'

class AgentLocal(models.Model):
    # ===== LIEN AVEC VOTRE SYSTÈME USER (DEV 1) =====
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,  # ✅ Pointe vers authentication.User
        on_delete=models.CASCADE,
        related_name='agent_profile',
        help_text="Lien vers le compte utilisateur de l'agent"
    )
    
    # ===== INFORMATIONS AGENT SPÉCIFIQUES =====
    nom = models.CharField(max_length=200)
    prenom = models.CharField(max_length=200)
    telephone = models.CharField(
        max_length=15,
        help_text="Numéro de téléphone professionnel de l'agent"
    )
    email = models.EmailField(
        help_text="Email professionnel de l'agent"
    )
    adresse = models.TextField(
        help_text="Adresse physique du point de retrait"
    )
    
    # ===== STATUT ET DISPONIBILITÉ =====
    statut_agent = models.CharField(
        max_length=10,
        choices=StatutAgent.choices,
        default=StatutAgent.ACTIF
    )
    heure_ouverture = models.TimeField(
        default='08:00',
        help_text="Heure d'ouverture du point de retrait"
    )
    heure_fermeture = models.TimeField(
        default='18:00',
        help_text="Heure de fermeture du point de retrait"
    )
    
    # ===== GÉOLOCALISATION =====
    latitude = models.DecimalField(
        max_digits=9, 
        decimal_places=6, 
        null=True, 
        blank=True,
        help_text="Latitude GPS du point de retrait"
    )
    longitude = models.DecimalField(
        max_digits=9, 
        decimal_places=6, 
        null=True, 
        blank=True,
        help_text="Longitude GPS du point de retrait"
    )
    
    # ===== CONFIGURATION FINANCIÈRE =====
    solde_compte = models.DecimalField(
        max_digits=15, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Solde disponible pour les retraits"
    )
    limite_retrait_journalier = models.DecimalField(
        max_digits=12, 
        decimal_places=2, 
        default=Decimal('1000000.00'),
        help_text="Limite maximum de retraits par jour"
    )
    commission_pourcentage = models.DecimalField(
        max_digits=5, 
        decimal_places=2, 
        default=Decimal('2.0'),
        help_text="Commission en pourcentage sur les retraits"
    )
    
    # ===== VALIDATION KYC AGENT =====
    kyc_agent_verifie = models.BooleanField(
        default=False,
        help_text="KYC spécifique agent validé (licence, etc.)"
    )
    document_licence = models.FileField(
        upload_to='agents_licences/',
        null=True,
        blank=True,
        help_text="Document de licence commerciale"
    )
    
    # ===== MÉTADONNÉES =====
    date_creation = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'agents_local'
        verbose_name = 'Agent Local'
        verbose_name_plural = 'Agents Locaux'
        ordering = ['-date_creation']
        
        # Index pour les requêtes fréquentes
        indexes = [
            models.Index(fields=['statut_agent', 'latitude', 'longitude']),
            models.Index(fields=['statut_agent', 'heure_ouverture', 'heure_fermeture']),
        ]
    
    def __str__(self):
        return f"{self.prenom} {self.nom} - {self.statut_agent}"
    
    @property
    def nom_complet(self):
        """Nom complet de l'agent"""
        return f"{self.prenom} {self.nom}"
    
    @property
    def est_ouvert(self):
        """Vérifier si l'agent est ouvert selon les horaires"""
        if not self.heure_ouverture or not self.heure_fermeture:
            return False
        
        now = timezone.now().time()
        return self.heure_ouverture <= now <= self.heure_fermeture
    
    @property
    def est_disponible(self):
        """Vérifier si l'agent est disponible pour les retraits"""
        return (
            self.statut_agent == StatutAgent.ACTIF and 
            self.est_ouvert and
            self.user.kyc_status == 'VERIFIED'  # ✅ Utilise KYC du système principal
        )
    
    @property
    def user_phone_number(self):
        """Numéro de téléphone principal de l'utilisateur"""
        return self.user.phone_number
    
    @property
    def user_full_name(self):
        """Nom complet de l'utilisateur principal"""
        return self.user.get_full_name()
    
    def peut_effectuer_retrait(self, montant):
        """Vérifier si l'agent peut effectuer un retrait du montant donné"""
        if not self.est_disponible:
            return False, "Agent non disponible"
        
        if montant > self.solde_compte:
            return False, "Solde agent insuffisant"
        
        if montant > self.limite_retrait_journalier:
            return False, "Montant dépasse la limite journalière"
        
        return True, "Retrait possible"
    
    def calculer_commission(self, montant):
        """Calculer la commission de l'agent pour un retrait"""
        return (montant * self.commission_pourcentage) / 100
    
    def save(self, *args, **kwargs):
        """Override save pour validations"""
        # Synchroniser nom/prénom avec User si nécessaire
        if self.user:
            # On peut choisir de synchroniser ou pas
            # self.user.first_name = self.prenom
            # self.user.last_name = self.nom
            # self.user.save()
            pass
        
        super().save(*args, **kwargs)

# ===== INTÉGRATION PARFAITE AVEC VOTRE SYSTÈME =====
"""
✅ CORRECTIONS APPORTÉES :

1. 🔗 RELATION USER :
   - OneToOneField vers settings.AUTH_USER_MODEL
   - Pointe vers authentication.User (Dev 1)
   - related_name='agent_profile'

2. 🎯 INTÉGRATION KYC :
   - Utilise user.kyc_status pour vérifier statut
   - Ajoute kyc_agent_verifie pour validations spécifiques agent
   - Document licence pour compliance

3. 📊 PROPRIÉTÉS INTELLIGENTES :
   - est_disponible() vérifie KYC + horaires + statut
   - user_phone_number accède au téléphone principal
   - Méthodes métier pour retraits

4. 🔧 COMPATIBILITÉ :
   - Compatible avec JWT authentication
   - Utilise permissions du système principal
   - Intégré avec notifications automatiques

5. 📈 BUSINESS LOGIC :
   - peut_effectuer_retrait() avec validations
   - calculer_commission() pour revenus
   - Limites et seuils configurables

🎯 UTILISATION :
# Créer un agent à partir d'un user existant
user = User.objects.get(phone_number='+221771234567')
agent = AgentLocal.objects.create(
    user=user,
    nom=user.last_name,
    prenom=user.first_name,
    telephone=user.phone_number,
    email=user.email,
    adresse="123 Rue Example, Dakar",
    latitude=14.6928,
    longitude=-17.4467
)

# Vérifier disponibilité
if agent.est_disponible:
    can_withdraw, message = agent.peut_effectuer_retrait(50000)
    if can_withdraw:
        commission = agent.calculer_commission(50000)
"""