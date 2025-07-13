# Application de Notifications

Cette application gère le système de notifications pour les utilisateurs du projet de Transfert d'Argent Mobile.

## Description

L'application de Notifications est responsable de la création, de la gestion et de la distribution des notifications aux utilisateurs. Elle permet d'informer les utilisateurs des événements importants comme les changements de statut KYC, les transactions effectuées, et d'autres alertes système. L'application utilise une architecture extensible permettant d'ajouter facilement de nouveaux canaux de notification.

## Fonctionnalités

- Système de notifications en base de données
- Différents types de notifications (information, transaction, alerte)
- Statuts de notification (lu, non lu)
- Architecture extensible avec pattern Factory pour les canaux de notification
- Intégration avec d'autres applications via des signaux Django
- API RESTful pour la gestion des notifications
- Permissions basées sur la propriété des notifications

## Structure

L'application est organisée comme suit :
- `models.py` : Définit le modèle Notification avec ses types et statuts
- `views.py` : Contient les vues API et l'architecture des canaux de notification
- `serializers.py` : Définit les sérialiseurs pour la validation et la transformation des données
- `signals.py` : Configure les signaux pour créer des notifications automatiques
- `urls.py` : Définit les routes d'API pour l'application

## Dépendances

- Application d'authentification pour le modèle utilisateur
- Django REST Framework pour l'API
- Django Signals pour la communication inter-applications

## Points d'API

- `/api/notifications/` : Liste des notifications de l'utilisateur connecté
- `/api/notifications/{id}/` : Détails d'une notification spécifique
- `/api/notifications/{id}/read/` : Marquer une notification comme lue
- `/api/notifications/` (POST, admin uniquement) : Créer une nouvelle notification

## Utilisation dans d'autres applications

### Envoi de notifications

Pour envoyer une notification à un utilisateur depuis une autre application :

```python
from notifications.views import NotificationChannelFactory

def informer_utilisateur(user, titre, message, type_notification='INFO'):
    # Obtenir un canal de notification (par défaut: base de données)
    canal_notification = NotificationChannelFactory.get_channel('database')
    
    # Envoyer la notification
    notification = canal_notification.send(
        user=user,
        title=titre,
        message=message,
        notification_type=type_notification
    )
    
    return notification
```

### Connexion aux signaux

Pour créer des notifications automatiques en réponse à des événements dans d'autres applications :

```python
from django.db.models.signals import post_save
from django.dispatch import receiver
from votre_app.models import VotreModele
from notifications.views import NotificationChannelFactory

@receiver(post_save, sender=VotreModele)
def notifier_changement(sender, instance, created, **kwargs):
    if created:
        # Obtenir l'utilisateur concerné
        user = instance.user
        
        # Créer une notification
        canal_notification = NotificationChannelFactory.get_channel('database')
        canal_notification.send(
            user=user,
            title="Nouveau élément créé",
            message=f"Un nouvel élément a été créé avec succès.",
            notification_type='INFO'
        )
```

## Extension du système de notifications

L'application utilise un pattern Factory qui permet d'ajouter facilement de nouveaux canaux de notification. Pour créer un nouveau canal (par exemple, SMS ou push mobile) :

```python
from notifications.views import NotificationChannel

class SMSNotificationChannel(NotificationChannel):
    """Implémentation du canal de notification par SMS."""
    
    def send(self, user, title, message, notification_type='INFO'):
        """Envoyer une notification par SMS."""
        # Logique d'envoi de SMS
        phone_number = user.phone_number
        sms_message = f"{title}: {message}"
        
        # Appel à un service SMS
        # sms_service.send(phone_number, sms_message)
        
        # Créer également une entrée en base de données
        return Notification.objects.create(
            user=user,
            title=title,
            message=message,
            notification_type=notification_type,
            auto_sent=True
        )

# Ajouter le nouveau canal à la fabrique
# Dans notifications/views.py, ajouter à NotificationChannelFactory.get_channel:
# 'sms': SMSNotificationChannel,
```

## Bonnes pratiques

- Utiliser des messages clairs et concis pour les notifications
- Catégoriser correctement les notifications par type (INFO, TRANSACTION, ALERT)
- Ne pas surcharger les utilisateurs avec trop de notifications
- Implémenter un système de nettoyage pour les anciennes notifications
- Sécuriser l'accès aux notifications pour que les utilisateurs ne puissent voir que leurs propres notifications

## Contributeurs

- Équipe de développement du projet Mobile Money Transfer
