# Application KYC (Know Your Customer)

Cette application gère le processus de vérification d'identité des utilisateurs pour le projet de Transfert d'Argent Mobile.

## Description

L'application KYC (Know Your Customer) est responsable de la gestion des documents d'identité et du processus de vérification des utilisateurs. Elle permet aux utilisateurs de soumettre des documents d'identité qui sont ensuite vérifiés par les administrateurs du système. Cette vérification est essentielle pour assurer la conformité réglementaire et prévenir les fraudes dans les transactions financières.

## Fonctionnalités

- Soumission de documents d'identité par les utilisateurs
- Différents types de documents supportés (carte d'identité, passeport, permis de conduire, etc.)
- Processus de vérification avec statuts (en attente, vérifié, rejeté)
- Intégration avec le modèle utilisateur pour mettre à jour le statut KYC
- Notifications automatiques lors des changements de statut
- API RESTful pour la gestion des documents KYC

## Structure

L'application est organisée comme suit :
- `models.py` : Définit le modèle KYCDocument pour stocker les informations des documents
- `views.py` : Contient les vues API pour la soumission et la gestion des documents
- `serializers.py` : Définit les sérialiseurs pour la validation et la transformation des données
- `signals.py` : Configure les signaux pour mettre à jour le statut KYC de l'utilisateur et envoyer des notifications
- `urls.py` : Définit les routes d'API pour l'application

## Dépendances

- Application d'authentification pour le modèle utilisateur
- Application de notifications pour envoyer des alertes aux utilisateurs
- Django REST Framework pour l'API
- Pillow pour le traitement des images de documents

## Points d'API

- `/api/kyc/documents/` : Liste et création de documents KYC
- `/api/kyc/documents/{id}/` : Détails, mise à jour et suppression d'un document spécifique
- `/api/kyc/documents/{id}/verify/` : Vérification d'un document (admin uniquement)
- `/api/kyc/documents/{id}/reject/` : Rejet d'un document (admin uniquement)
- `/api/kyc/status/` : Consultation du statut KYC global de l'utilisateur

## Utilisation dans d'autres applications

### Vérification du statut KYC

Pour vérifier si un utilisateur a complété son processus KYC avant d'autoriser certaines actions :

```python
from django.contrib.auth import get_user_model

User = get_user_model()

def autoriser_transaction(user_id, montant):
    user = User.objects.get(id=user_id)
    
    # Vérifier si l'utilisateur a un statut KYC vérifié
    if user.kyc_status != User.KYCStatus.VERIFIED:
        raise PermissionError("Veuillez compléter votre vérification KYC avant d'effectuer cette transaction.")
    
    # Continuer avec la transaction
    # ...
```

### Connexion aux signaux KYC

Pour réagir aux changements de statut des documents KYC :

```python
from django.db.models.signals import post_save
from django.dispatch import receiver
from kyc.models import KYCDocument

@receiver(post_save, sender=KYCDocument)
def reagir_changement_statut_kyc(sender, instance, **kwargs):
    if instance.status == KYCDocument.Status.VERIFIED:
        # Exécuter une action lorsqu'un document est vérifié
        pass
```

## Bonnes pratiques

- Toujours vérifier le statut KYC avant d'autoriser des transactions sensibles
- Stocker les documents de manière sécurisée et conforme aux réglementations sur la protection des données
- Implémenter un processus de vérification en plusieurs étapes pour les comptes à haut risque
- Limiter l'accès aux documents KYC aux administrateurs autorisés uniquement
- Utiliser des connexions sécurisées (HTTPS) pour la transmission des documents

## Contributeurs

- Équipe de développement du projet Mobile Money Transfer
