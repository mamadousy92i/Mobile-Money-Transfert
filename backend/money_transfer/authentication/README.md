# Authentication App

This app provides a custom User model and JWT authentication for the Money Transfer project.

## Features

- Custom User model with phone number as the primary authentication field
- JWT authentication using SimpleJWT
- API endpoints for registration, login, logout, token refresh, and profile management
- KYC status tracking for users

## Usage in Other Apps

### Importing the User Model

To use the User model in other apps, import it using Django's get_user_model():

```python
from django.contrib.auth import get_user_model

User = get_user_model()
```

### Using Signals

The authentication app provides signals that other apps can connect to:

- `post_save` signal when a user is created or updated

Example of connecting to these signals in another app:

```python
# In your app's signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model

User = get_user_model()

@receiver(post_save, sender=User)
def handle_user_creation(sender, instance, created, **kwargs):
    if created:
        # Create related records in your app when a user is created
        pass
```

### KYC Status

The User model includes a `kyc_status` field with the following choices:
- `PENDING`: Default status for new users
- `VERIFIED`: User has completed KYC verification
- `REJECTED`: User's KYC verification was rejected

You can check a user's KYC status like this:

```python
user = User.objects.get(phone_number='1234567890')
if user.kyc_status == User.KYCStatus.VERIFIED:
    # Allow access to features that require KYC verification
    pass
```

## API Endpoints

- `/api/auth/register/`: Register a new user
- `/api/auth/login/`: Login and get JWT tokens
- `/api/auth/logout/`: Logout and blacklist refresh token
- `/api/auth/refresh/`: Refresh access token
- `/api/auth/profile/`: Get or update user profile
- `/api/auth/change-password/`: Change user password
