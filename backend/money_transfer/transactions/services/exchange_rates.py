# transactions/services/exchange_rates.py
import requests
from decimal import Decimal
from django.core.cache import cache
from django.utils import timezone
from ..models import TauxChange

class ExchangeRateService:
    """Service pour gérer les taux de change temps réel"""
    
    def __init__(self):
        self.api_key = "YOUR_XE_API_KEY"  # Remplacer par vraie clé
        self.base_url = "https://api.exchangerate-api.com/v4/latest"
        self.cache_timeout = 300  # 5 minutes
    
    def get_rate(self, from_currency, to_currency):
        """Obtenir taux temps réel avec cache"""
        cache_key = f"exchange_rate_{from_currency}_{to_currency}"
        cached_rate = cache.get(cache_key)
        
        if cached_rate:
            return Decimal(str(cached_rate))
        
        # Appel API externe
        try:
            response = requests.get(f"{self.base_url}/{from_currency}", timeout=10)
            data = response.json()
            rate = data['rates'].get(to_currency)
            
            if rate:
                rate_decimal = Decimal(str(rate))
                cache.set(cache_key, float(rate_decimal), self.cache_timeout)
                
                # Sauvegarder en base pour historique
                self.save_rate_to_db(from_currency, to_currency, rate_decimal)
                return rate_decimal
                
        except Exception as e:
            # Fallback vers base de données
            return self.get_rate_from_db(from_currency, to_currency)
    
    def save_rate_to_db(self, from_curr, to_curr, rate):
        """Sauvegarder taux en base"""
        TauxChange.objects.update_or_create(
            devise_origine=from_curr,
            devise_destination=to_curr,
            defaults={
                'taux': rate,
                'taux_inverse': 1 / rate,
                'last_updated': timezone.now()
            }
        )
    
    def calculate_conversion(self, amount, from_curr, to_curr, include_margin=True):
        """Convertir montant avec marge business"""
        rate = self.get_rate(from_curr, to_curr)
        
        if include_margin:
            # Ajouter marge business 2%
            rate = rate * Decimal('0.98')
        
        return amount * rate
    
    def get_supported_currencies(self):
        """Liste des devises supportées"""
        return ['XOF', 'CDF', 'XAF', 'EUR', 'USD', 'GBP', 'CAD', 'MAD']