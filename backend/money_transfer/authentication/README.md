# Application d'Authentification

Cette application fournit un modèle d'utilisateur personnalisé et une authentification JWT pour le projet de Transfert d'Argent Mobile.

## Description

L'application d'authentification gère l'ensemble du processus d'authentification des utilisateurs dans le système. Elle utilise un modèle d'utilisateur personnalisé avec le numéro de téléphone comme champ d'authentification principal et implémente l'authentification JWT (JSON Web Token) pour sécuriser les API.

## Fonctionnalités

- Modèle d'utilisateur personnalisé avec numéro de téléphone comme champ d'authentification principal
- Authentification JWT utilisant SimpleJWT
- Points d'API pour l'inscription, la connexion, la déconnexion, le rafraîchissement de token et la gestion de profil
- Suivi du statut KYC (Know Your Customer) pour les utilisateurs
- Permissions personnalisées pour contrôler l'accès aux ressources

## Structure

L'application est organisée comme suit :
- `models.py` : Définit le modèle d'utilisateur personnalisé et son gestionnaire
- `views.py` : Contient les vues API pour l'authentification et la gestion des utilisateurs
- `serializers.py` : Définit les sérialiseurs pour la validation et la transformation des données utilisateur
- `permissions.py` : Implémente des permissions personnalisées pour contrôler l'accès
- `signals.py` : Configure les signaux pour interagir avec d'autres applications
- `urls.py` : Définit les routes d'API pour l'application

## Dépendances

- Django REST Framework
- SimpleJWT pour l'authentification par token
- Django Signals pour la communication inter-applications

## Points d'API

- `/api/auth/register/` : Inscription d'un nouvel utilisateur
- `/api/auth/login/` : Connexion et obtention des tokens JWT
- `/api/auth/logout/` : Déconnexion et mise en liste noire du token de rafraîchissement
- `/api/auth/refresh/` : Rafraîchissement du token d'accès
- `/api/auth/profile/` : Consultation ou mise à jour du profil utilisateur
- `/api/auth/change-password/` : Modification du mot de passe utilisateur

## Utilisation dans d'autres applications

### Importation du modèle utilisateur

Pour utiliser le modèle utilisateur dans d'autres applications, importez-le en utilisant la fonction `get_user_model()` de Django :

```python
from django.contrib.auth import get_user_model

User = get_user_model()
```

### Utilisation des signaux

L'application d'authentification fournit des signaux auxquels d'autres applications peuvent se connecter :

- Signal `post_save` lorsqu'un utilisateur est créé ou mis à jour

Exemple de connexion à ces signaux dans une autre application :

```python
# Dans le fichier signals.py de votre application
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model

User = get_user_model()

@receiver(post_save, sender=User)
def gerer_creation_utilisateur(sender, instance, created, **kwargs):
    if created:
        # Créer des enregistrements associés dans votre application lorsqu'un utilisateur est créé
        pass
```

### Statut KYC

Le modèle utilisateur inclut un champ `kyc_status` avec les choix suivants :
- `PENDING` : Statut par défaut pour les nouveaux utilisateurs
- `VERIFIED` : L'utilisateur a complété la vérification KYC
- `REJECTED` : La vérification KYC de l'utilisateur a été rejetée

Vous pouvez vérifier le statut KYC d'un utilisateur comme ceci :

```python
user = User.objects.get(phone_number='1234567890')
if user.kyc_status == User.KYCStatus.VERIFIED:
    # Autoriser l'accès aux fonctionnalités nécessitant une vérification KYC
    pass
```

## Bonnes pratiques

- Toujours utiliser `get_user_model()` plutôt que d'importer directement le modèle User
- Utiliser les permissions appropriées pour protéger les points d'API sensibles
- Vérifier le statut KYC avant d'autoriser l'accès aux fonctionnalités restreintes
- Utiliser les signaux pour maintenir la cohérence des données entre les applications

## Contributeurs

- Équipe de développement du projet Mobile Money Transfer
