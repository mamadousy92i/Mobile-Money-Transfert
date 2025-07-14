# money_transfer/settings.py - CONFIGURATION FUSIONNÉE TOUS LES DEVS

import os
from decouple import config, Csv
from pathlib import Path
from datetime import timedelta

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# ===== SÉCURITÉ =====
SECRET_KEY = config('SECRET_KEY', default='django-insecure-^2__=xq8mkb#@9)ksy&f12dg_!w!&u8luy%(a_k1yv&2f-ym9y')
DEBUG = config('DEBUG', default=True, cast=bool)

# ALLOWED_HOSTS configuration - FUSIONNÉ
ALLOWED_HOSTS = [
    'localhost', 
    '127.0.0.1',
    '10.0.2.2',              # Android emulator (Dev 3)
    '0.0.0.0',               # Pour tests réseau (Dev 3)
    '1d280c1eed5e.ngrok-free.app',
    '*.ngrok-free.app',
] + config('ADDITIONAL_HOSTS', default='', cast=Csv())

# ===== APPLICATIONS INTÉGRÉES - TOUS LES DEVS =====
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Third party packages
    'rest_framework',
    'corsheaders',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    
    # ===== APPS DEV 1 (Authentication & KYC & Notifications) =====
    'authentication',           # User model + JWT + KYC status
    'kyc',                      # Upload documents + validation
    'notifications',            # Système notifications + channels
    
    # ===== APPS DEV 2 (Transactions & Payments) =====
    'transactions',             # Core business + gateways simulés + international
    'payment_gateways',         # Simulateurs Wave/Orange Money
    
    # ===== APPS DEV 3 (Agents & Dashboard & Operations) =====
    'agents',                   # Agents locaux + géolocalisation
    'withdrawals',              # Gestion retraits + QR codes
    'dashboard',                # Statistiques + analytics
    'reception',                # Réception d'argent
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    # 'django.middleware.csrf.CsrfViewMiddleware',  # Commenté pour développement API
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'money_transfer.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'money_transfer.wsgi.application'

# ===== BASE DE DONNÉES - CONFIGURATION FLEXIBLE =====
# PostgreSQL pour production, SQLite pour développement
if config('USE_POSTGRESQL', default=False, cast=bool):
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': config('DB_NAME'),
            'USER': config('DB_USER'),
            'PASSWORD': config('DB_PASSWORD'),
            'HOST': config('DB_HOST', default='localhost'),
            'PORT': config('DB_PORT', default='5432'),
            'OPTIONS': {
                'client_encoding': 'UTF8',
            },
        }
    }
else:
    # SQLite pour développement (Dev 3 compatible)
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }

# ===== MODÈLE USER PERSONNALISÉ (CRITIQUE POUR INTÉGRATION) =====
AUTH_USER_MODEL = 'authentication.User'    # ✅ ESSENTIEL pour tous les devs

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Africa/Dakar'
USE_I18N = True
USE_TZ = True

# ===== FICHIERS STATIQUES ET MEDIA =====
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'      # Pour collectstatic

MEDIA_URL = '/media/'                       # Pour uploads KYC + documents agents
MEDIA_ROOT = BASE_DIR / 'media'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# ===== CONFIGURATION CACHE =====
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'TIMEOUT': 300,  # 5 minutes
        'OPTIONS': {
            'MAX_ENTRIES': 1000,
        }
    }
}

# ===== CONFIGURATION CORS - FUSIONNÉE =====
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",          # React/Vue frontend (Dev 2)
    "http://127.0.0.1:3000",
    "http://localhost:8080",          # Vue/dev server
    "http://127.0.0.1:8080",
    "https://1d280c1eed5e.ngrok-free.app",
]

CORS_ALLOW_ALL_ORIGINS = DEBUG  # Tous origins en développement
CORS_ALLOW_CREDENTIALS = True

# Headers autorisés - FUSIONNÉS
CORS_ALLOWED_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',           # CRITIQUE pour JWT
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
    'ngrok-skip-browser-warning',
    'cache-control',
    'pragma',
    'expires',
]

# Méthodes autorisées
CORS_ALLOW_METHODS = [
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
]

# ===== CONFIGURATION CSRF =====
CSRF_TRUSTED_ORIGINS = [
    'https://1d280c1eed5e.ngrok-free.app',
    'http://localhost:8000',
    'http://127.0.0.1:8000',
    'http://10.0.2.2:8000',           # Android emulator (Dev 3)
]

# ===== CONFIGURATION REST FRAMEWORK - INTÉGRÉE =====
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',  # JWT (Dev 1 & 2)
        'rest_framework.authentication.SessionAuthentication',        # Session (Dev 3)
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',  # Par défaut authentifié
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    
    # Gestion d'erreurs
    'EXCEPTION_HANDLER': 'rest_framework.views.exception_handler',
    
    # Format de date/time
    'DATETIME_FORMAT': '%Y-%m-%dT%H:%M:%S.%fZ',
    'DATE_FORMAT': '%Y-%m-%d',
}

# ===== CONFIGURATION JWT (DEV 1) =====
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=24),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': True,
    
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'VERIFYING_KEY': None,
    
    'AUTH_HEADER_TYPES': ('Bearer',),
    'AUTH_HEADER_NAME': 'HTTP_AUTHORIZATION',
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
    'USER_AUTHENTICATION_RULE': 'rest_framework_simplejwt.authentication.default_user_authentication_rule',
    
    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'TOKEN_TYPE_CLAIM': 'token_type',
    'TOKEN_USER_CLASS': 'rest_framework_simplejwt.models.TokenUser',
    
    'JTI_CLAIM': 'jti',
    
    'TOKEN_OBTAIN_SERIALIZER': 'rest_framework_simplejwt.serializers.TokenObtainPairSerializer',
    'TOKEN_REFRESH_SERIALIZER': 'rest_framework_simplejwt.serializers.TokenRefreshSerializer',
    'TOKEN_VERIFY_SERIALIZER': 'rest_framework_simplejwt.serializers.TokenVerifySerializer',
    'TOKEN_BLACKLIST_SERIALIZER': 'rest_framework_simplejwt.serializers.TokenBlacklistSerializer',
}

# ===== LOGGING INTÉGRÉ - TOUS LES MODULES =====
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {message}',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
        'file': {
            'class': 'logging.FileHandler',
            'filename': BASE_DIR / 'logs' / 'django.log',
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        # DEV 1 - Authentication & KYC & Notifications
        'authentication': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'notifications': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'kyc': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        # DEV 2 - Transactions & Payments
        'transactions': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'payment_gateways': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        # DEV 3 - Agents & Dashboard & Operations
        'agents': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'dashboard': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'withdrawals': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'reception': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}

# Créer le répertoire logs s'il n'existe pas
(BASE_DIR / 'logs').mkdir(exist_ok=True)

# ===== CONFIGURATION SESSION =====
SESSION_COOKIE_AGE = 86400  # 24 heures
SESSION_SAVE_EVERY_REQUEST = True

# ===== SÉCURITÉ PRODUCTION =====
if not DEBUG:
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_BROWSER_XSS_FILTER = True
    SECURE_CONTENT_TYPE_NOSNIFF = True
    SECURE_HSTS_SECONDS = 31536000
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True

# ===== CONFIGURATION EMAIL (pour notifications) =====
EMAIL_BACKEND = config('EMAIL_BACKEND', default='django.core.mail.backends.console.EmailBackend')
if EMAIL_BACKEND == 'django.core.mail.backends.smtp.EmailBackend':
    EMAIL_HOST = config('EMAIL_HOST', default='smtp.gmail.com')
    EMAIL_PORT = config('EMAIL_PORT', default=587, cast=int)
    EMAIL_USE_TLS = config('EMAIL_USE_TLS', default=True, cast=bool)
    EMAIL_HOST_USER = config('EMAIL_HOST_USER', default='')
    EMAIL_HOST_PASSWORD = config('EMAIL_HOST_PASSWORD', default='')
    DEFAULT_FROM_EMAIL = config('DEFAULT_FROM_EMAIL', default='noreply@moneytransfer.com')

# ===== CONFIGURATION POUR INTÉGRATION PARFAITE =====
"""
🎯 CONFIGURATION FUSIONNÉE AVEC SUCCÈS :

✅ TOUS LES DEVS INTÉGRÉS :
- DEV 1: AUTH_USER_MODEL + JWT + Notifications
- DEV 2: Transactions + Gateways + International  
- DEV 3: Agents + Withdrawals + Dashboard + Reception

✅ COMPATIBILITÉ TOTALE :
- PostgreSQL pour production
- SQLite pour développement (Dev 3)
- JWT + Session auth simultanées
- CORS configuré pour tous frontends

✅ ENVIRONNEMENTS FLEXIBLES :
- Variables d'environnement avec .env
- Configuration production/développement
- Logging complet pour debug
- Media files pour uploads

🚀 UTILISATION :
1. Créer .env avec vos variables
2. python manage.py makemigrations
3. python manage.py migrate  
4. python manage.py createsuperuser
5. python manage.py runserver

Votre plateforme sera de niveau ENTERPRISE ! 🌟
"""