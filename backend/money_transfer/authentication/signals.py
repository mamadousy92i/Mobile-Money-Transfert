from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model

User = get_user_model()

# Ce fichier est préparé pour les signaux qui seront utilisés par d'autres applications
# Par exemple, lorsqu'un utilisateur est créé, nous pourrions vouloir créer des enregistrements associés dans d'autres applications

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """
    Signal pour gérer les événements de création d'utilisateur.
    Ceci peut être utilisé par d'autres applications comme 'kyc' pour créer un enregistrement KYC lorsqu'un utilisateur est créé.
    """
    if created:
        # Exemple de comment d'autres applications peuvent s'accrocher à la création d'utilisateur
        # Ceci est un espace réservé et sera implémenté par d'autres applications
        pass

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    """
    Signal pour gérer les événements de mise à jour d'utilisateur.
    Ceci peut être utilisé par d'autres applications pour mettre à jour les enregistrements associés lorsqu'un utilisateur est mis à jour.
    """
    # Exemple de comment d'autres applications peuvent s'accrocher aux mises à jour d'utilisateur
    # Ceci est un espace réservé et sera implémenté par d'autres applications
    pass
