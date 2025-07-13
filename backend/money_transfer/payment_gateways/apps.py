# payment_gateways/apps.py

from django.apps import AppConfig
import logging

logger = logging.getLogger(__name__)

class PaymentGatewaysConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'payment_gateways'
    verbose_name = 'Payment Gateways Simulators'
    
    def ready(self):
        """Initialiser les simulateurs au démarrage de Django"""
        try:
            from .services import payment_service
            logger.info("🔄 Initialisation des simulateurs de gateways...")
            
            # Vérifier que les simulateurs sont chargés
            available_gateways = payment_service.gateways.keys()
            logger.info(f"✅ Gateways simulés chargés: {list(available_gateways)}")
            
            # Afficher les infos de chaque gateway
            for gateway_type, gateway in payment_service.gateways.items():
                info = payment_service.get_gateway_info(gateway_type)
                if info:
                    logger.info(f"  📡 {gateway_type}: {info['name']} (Succès: {info.get('success_rate', 0)*100:.0f}%)")
            
        except Exception as e:
            logger.error(f"❌ Erreur lors de l'initialisation des gateways: {e}")