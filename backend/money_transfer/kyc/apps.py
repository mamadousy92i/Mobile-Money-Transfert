from django.apps import AppConfig


class KycConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'kyc'
    
    def ready(self):
        import kyc.signals  # Import signals when app is ready
