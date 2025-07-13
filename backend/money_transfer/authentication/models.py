from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager
from django.utils import timezone
from django.utils.translation import gettext_lazy as _


class UserManager(BaseUserManager):
    """Gestionnaire personnalisé pour le modèle User."""
    
    def create_user(self, phone_number, email, first_name, last_name, password=None, **extra_fields):
        """Crée et enregistre un utilisateur standard avec les détails fournis."""
        if not phone_number:
            raise ValueError(_('Le numéro de téléphone doit être défini'))
        if not email:
            raise ValueError(_('L\'email doit être défini'))
        if not first_name:
            raise ValueError(_('Le prénom doit être défini'))
        if not last_name:
            raise ValueError(_('Le nom de famille doit être défini'))
            
        email = self.normalize_email(email)
        user = self.model(
            phone_number=phone_number,
            email=email,
            first_name=first_name,
            last_name=last_name,
            **extra_fields
        )
        user.set_password(password)
        user.save(using=self._db)
        return user
    
    def create_superuser(self, phone_number, email, first_name, last_name, password=None, **extra_fields):
        """Crée et enregistre un superutilisateur avec les détails fournis."""
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('kyc_status', User.KYCStatus.VERIFIED)
        
        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Le superutilisateur doit avoir is_staff=True.'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Le superutilisateur doit avoir is_superuser=True.'))
            
        return self.create_user(phone_number, email, first_name, last_name, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """Modèle utilisateur personnalisé avec le numéro de téléphone comme champ d'authentification principal."""
    
    class KYCStatus(models.TextChoices):
        PENDING = 'PENDING', _('En attente')
        VERIFIED = 'VERIFIED', _('Vérifié')
        REJECTED = 'REJECTED', _('Rejeté')
    
    phone_number = models.CharField(_('numéro de téléphone'), max_length=15, unique=True)
    email = models.EmailField(_('adresse email'), unique=True)
    first_name = models.CharField(_('prénom'), max_length=150)
    last_name = models.CharField(_('nom de famille'), max_length=150)
    is_active = models.BooleanField(_('actif'), default=True)
    is_staff = models.BooleanField(_('statut staff'), default=False)
    date_joined = models.DateTimeField(_('date d\'inscription'), default=timezone.now)
    kyc_status = models.CharField(
        _('statut KYC'),
        max_length=10,
        choices=KYCStatus.choices,
        default=KYCStatus.PENDING
    )
    
    objects = UserManager()
    
    USERNAME_FIELD = 'phone_number'
    REQUIRED_FIELDS = ['email', 'first_name', 'last_name']
    
    class Meta:
        verbose_name = _('utilisateur')
        verbose_name_plural = _('utilisateurs')
    
    def __str__(self):
        return f"{self.first_name} {self.last_name} ({self.phone_number})"
    
    def get_full_name(self):
        """Renvoie le prénom suivi du nom de famille, avec un espace entre les deux."""
        return f"{self.first_name} {self.last_name}"
    
    def get_short_name(self):
        """Renvoie le nom court de l'utilisateur."""
        return self.first_name
