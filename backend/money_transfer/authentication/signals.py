from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model

User = get_user_model()

# This file is prepared for signals that will be used by other apps
# For example, when a user is created, we might want to create related records in other apps

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """
    Signal to handle user creation events.
    This can be used by other apps like 'kyc' to create a KYC record when a user is created.
    """
    if created:
        # Example of how other apps can hook into user creation
        # This is a placeholder and will be implemented by other apps
        pass

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    """
    Signal to handle user update events.
    This can be used by other apps to update related records when a user is updated.
    """
    # Example of how other apps can hook into user updates
    # This is a placeholder and will be implemented by other apps
    pass
