# payment_gateways/services.py - VERSION CORRIGÉE

import time
import random
import uuid
from decimal import Decimal
from datetime import datetime, timedelta
from typing import Dict, Any, Optional
from dataclasses import dataclass
from enum import Enum
import logging

logger = logging.getLogger(__name__)

class PaymentStatus(Enum):
    """Statuts des paiements pour simulation"""
    PENDING = "PENDING"
    SUCCESS = "SUCCESS" 
    FAILED = "FAILED"
    CANCELLED = "CANCELLED"
    TIMEOUT = "TIMEOUT"

@dataclass
class PaymentResponse:
    """Réponse standardisée des gateways"""
    success: bool
    transaction_id: str
    gateway_reference: str
    status: PaymentStatus
    amount: Decimal
    currency: str
    message: str
    fees: Decimal = Decimal('0')
    gateway_data: Dict[str, Any] = None
    error_code: Optional[str] = None

class BasePaymentGateway:
    """Classe de base pour tous les gateways de paiement"""
    
    def __init__(self):
        self.name = "Base Gateway"
        self.is_active = True
        self.timeout_seconds = 30
        
    def process_payment(self, phone: str, amount: Decimal, reference: str) -> PaymentResponse:
        """Traiter un paiement - à implémenter par chaque gateway"""
        raise NotImplementedError
        
    def check_status(self, gateway_reference: str) -> PaymentResponse:
        """Vérifier le statut d'un paiement"""
        raise NotImplementedError
        
    def validate_phone(self, phone: str) -> bool:
        """Valider le format du numéro selon le gateway"""
        raise NotImplementedError

class WaveSimulator(BasePaymentGateway):
    """Simulateur de l'API Wave Sénégal"""
    
    def __init__(self):
        super().__init__()
        self.name = "Wave"
        self.api_base = "https://api.wave.com/v1"
        self.success_rate = 0.85  # 85% de succès
        self.average_processing_time = 2.5  # secondes
        
        # Frais Wave réels (approximatifs) - TOUT EN DECIMAL
        self.fee_structure = {
            'percentage': Decimal('1.0'),  # 1%
            'fixed': Decimal('0'),
            'min_fee': Decimal('25'),
            'max_fee': Decimal('1500')
        }
    
    def validate_phone(self, phone: str) -> bool:
        """Valider numéro sénégalais (Wave accepte tous les numéros sénégalais)"""
        import re
        # Normaliser le numéro
        phone = phone.replace(' ', '').replace('-', '')
        # Wave accepte TOUS les numéros sénégalais
        pattern = r'^(\+221|221)?(77|78|70|76|75)\d{7}$'
        return bool(re.match(pattern, phone))
    
    def calculate_fees(self, amount: Decimal) -> Decimal:
        """Calculer les frais Wave - TOUT EN DECIMAL"""
        # Convertir amount en Decimal si ce n'est pas déjà fait
        if not isinstance(amount, Decimal):
            amount = Decimal(str(amount))
            
        fee = (amount * self.fee_structure['percentage']) / Decimal('100')
        fee = max(fee, self.fee_structure['min_fee'])
        fee = min(fee, self.fee_structure['max_fee'])
        return fee.quantize(Decimal('0.01'))
    
    def process_payment(self, phone: str, amount: Decimal, reference: str) -> PaymentResponse:
        """Simuler un paiement Wave"""
        logger.info(f"🌊 Wave API: Processing payment {reference} - {amount} XOF to {phone}")
        
        # Convertir amount en Decimal
        if not isinstance(amount, Decimal):
            amount = Decimal(str(amount))
        
        # Validation du numéro
        if not self.validate_phone(phone):
            logger.warning(f"🌊 Wave API: Invalid phone number {phone}")
            return PaymentResponse(
                success=False,
                transaction_id=reference,
                gateway_reference="",
                status=PaymentStatus.FAILED,
                amount=amount,
                currency="XOF",
                message="Numéro de téléphone invalide pour Wave",
                error_code="INVALID_PHONE_NUMBER"
            )
        
        # Validation du montant
        if amount < Decimal('100') or amount > Decimal('500000'):
            logger.warning(f"🌊 Wave API: Amount {amount} out of range")
            return PaymentResponse(
                success=False,
                transaction_id=reference,
                gateway_reference="",
                status=PaymentStatus.FAILED,
                amount=amount,
                currency="XOF",
                message="Montant hors limites Wave (100 - 500,000 XOF)",
                error_code="AMOUNT_OUT_OF_RANGE"
            )
        
        # Simuler le temps de traitement réseau
        processing_time = random.uniform(1.5, 4.0)
        logger.info(f"🌊 Wave API: Processing time: {processing_time:.2f}s")
        time.sleep(processing_time)
        
        # Générer référence Wave
        wave_ref = f"WAVE_{datetime.now().strftime('%Y%m%d')}_{uuid.uuid4().hex[:8].upper()}"
        
        # Calculer les frais
        fees = self.calculate_fees(amount)
        
        # Simuler différents scénarios selon la logique Wave
        scenario = random.random()
        
        if scenario <= self.success_rate:
            # 🟢 SUCCÈS - Simulation d'une réponse Wave réussie
            logger.info(f"🌊 Wave API: Payment SUCCESS for {reference}")
            return PaymentResponse(
                success=True,
                transaction_id=reference,
                gateway_reference=wave_ref,
                status=PaymentStatus.SUCCESS,
                amount=amount,
                currency="XOF",
                message="Paiement Wave effectué avec succès",
                fees=fees,
                gateway_data={
                    'wave_transaction_id': wave_ref,
                    'sender_phone': phone,
                    'processing_time': processing_time,
                    'wave_fees': str(fees),
                    'timestamp': datetime.now().isoformat(),
                    'api_response_time': f"{processing_time:.2f}s",
                    'wave_status': 'COMPLETED'
                }
            )
        
        elif scenario <= 0.95:
            # 🔴 ÉCHEC - Différents types d'erreurs Wave
            error_scenarios = [
                ("INSUFFICIENT_FUNDS", "Solde Wave insuffisant"),
                ("ACCOUNT_SUSPENDED", "Compte Wave temporairement suspendu"),
                ("DAILY_LIMIT_EXCEEDED", "Limite quotidienne Wave dépassée"),
                ("INVALID_PIN", "Code PIN Wave incorrect"),
                ("NETWORK_ERROR", "Erreur réseau Wave")
            ]
            error_code, error_message = random.choice(error_scenarios)
            
            logger.warning(f"🌊 Wave API: Payment FAILED for {reference} - {error_code}")
            return PaymentResponse(
                success=False,
                transaction_id=reference,
                gateway_reference=wave_ref,
                status=PaymentStatus.FAILED,
                amount=amount,
                currency="XOF",
                message=error_message,
                error_code=error_code,
                gateway_data={
                    'wave_error_time': datetime.now().isoformat(),
                    'wave_error_code': error_code,
                    'processing_time': processing_time
                }
            )
        
        else:
            # ⏱️ TIMEOUT - Simulation timeout réseau
            logger.error(f"🌊 Wave API: Payment TIMEOUT for {reference}")
            return PaymentResponse(
                success=False,
                transaction_id=reference,
                gateway_reference="",
                status=PaymentStatus.TIMEOUT,
                amount=amount,
                currency="XOF",
                message="Timeout de la connexion Wave - Veuillez réessayer",
                error_code="GATEWAY_TIMEOUT"
            )
    
    def check_status(self, gateway_reference: str) -> PaymentResponse:
        """Vérifier le statut d'une transaction Wave"""
        logger.info(f"🌊 Wave API: Checking status for {gateway_reference}")
        
        # Simuler vérification de statut
        time.sleep(random.uniform(0.3, 1.0))
        
        return PaymentResponse(
            success=True,
            transaction_id="",
            gateway_reference=gateway_reference,
            status=PaymentStatus.SUCCESS,
            amount=Decimal('0'),
            currency="XOF",
            message="Transaction Wave confirmée",
            gateway_data={
                'status_check_time': datetime.now().isoformat(),
                'wave_final_status': 'CONFIRMED'
            }
        )

class OrangeMoneySimulator(BasePaymentGateway):
    """Simulateur de l'API Orange Money Sénégal"""
    
    def __init__(self):
        super().__init__()
        self.name = "Orange Money"
        self.api_base = "https://api.orange.sn/omoney/v1"
        self.success_rate = 0.82  # 82% de succès (légèrement moins que Wave)
        self.average_processing_time = 3.2  # Plus lent que Wave
        
        # Frais Orange Money réels (approximatifs) - TOUT EN DECIMAL
        self.fee_structure = {
            'percentage': Decimal('1.5'),  # 1.5%
            'fixed': Decimal('50'),
            'min_fee': Decimal('100'),
            'max_fee': Decimal('2000')
        }
    
    def validate_phone(self, phone: str) -> bool:
        """Valider numéro sénégalais (Orange Money accepte tous les numéros sénégalais)"""
        import re
        # Normaliser le numéro
        phone = phone.replace(' ', '').replace('-', '')
        # Orange Money accepte TOUS les numéros sénégalais
        pattern = r'^(\+221|221)?(77|78|70|76|75)\d{7}$'
        return bool(re.match(pattern, phone))
    
    def calculate_fees(self, amount: Decimal) -> Decimal:
        """Calculer les frais Orange Money - TOUT EN DECIMAL"""
        # Convertir amount en Decimal si ce n'est pas déjà fait
        if not isinstance(amount, Decimal):
            amount = Decimal(str(amount))
            
        fee = (amount * self.fee_structure['percentage']) / Decimal('100')
        fee += self.fee_structure['fixed']
        fee = max(fee, self.fee_structure['min_fee'])
        fee = min(fee, self.fee_structure['max_fee'])
        return fee.quantize(Decimal('0.01'))
    
    def process_payment(self, phone: str, amount: Decimal, reference: str) -> PaymentResponse:
        """Simuler un paiement Orange Money"""
        logger.info(f"🍊 Orange Money API: Processing payment {reference} - {amount} XOF to {phone}")
        
        # Convertir amount en Decimal
        if not isinstance(amount, Decimal):
            amount = Decimal(str(amount))
        
        # Validation du numéro
        if not self.validate_phone(phone):
            logger.warning(f"🍊 Orange Money API: Invalid phone number {phone}")
            return PaymentResponse(
                success=False,
                transaction_id=reference,
                gateway_reference="",
                status=PaymentStatus.FAILED,
                amount=amount,
                currency="XOF",
                message="Numéro de téléphone invalide pour Orange Money",
                error_code="INVALID_MSISDN"
            )
        
        # Validation du montant
        if amount < Decimal('500') or amount > Decimal('750000'):
            logger.warning(f"🍊 Orange Money API: Amount {amount} out of range")
            return PaymentResponse(
                success=False,
                transaction_id=reference,
                gateway_reference="",
                status=PaymentStatus.FAILED,
                amount=amount,
                currency="XOF",
                message="Montant hors limites Orange Money (500 - 750,000 XOF)",
                error_code="AMOUNT_NOT_ALLOWED"
            )
        
        # Simuler le temps de traitement (Orange plus lent)
        processing_time = random.uniform(2.0, 5.5)
        logger.info(f"🍊 Orange Money API: Processing time: {processing_time:.2f}s")
        time.sleep(processing_time)
        
        # Générer référence Orange Money
        om_ref = f"OM{datetime.now().strftime('%Y%m%d%H%M')}{random.randint(1000, 9999)}"
        
        # Calculer les frais
        fees = self.calculate_fees(amount)
        
        # Simuler différents scénarios selon la logique Orange Money
        scenario = random.random()
        
        if scenario <= self.success_rate:
            # 🟢 SUCCÈS - Simulation d'une réponse Orange Money réussie
            logger.info(f"🍊 Orange Money API: Payment SUCCESS for {reference}")
            return PaymentResponse(
                success=True,
                transaction_id=reference,
                gateway_reference=om_ref,
                status=PaymentStatus.SUCCESS,
                amount=amount,
                currency="XOF",
                message="Paiement Orange Money effectué avec succès",
                fees=fees,
                gateway_data={
                    'orange_transaction_id': om_ref,
                    'sender_phone': phone,
                    'processing_time': processing_time,
                    'orange_fees': str(fees),
                    'timestamp': datetime.now().isoformat(),
                    'network': 'ORANGE_SN',
                    'api_response_time': f"{processing_time:.2f}s",
                    'orange_status': 'SUCCESSFUL'
                }
            )
        
        elif scenario <= 0.93:
            # 🔴 ÉCHEC - Différents types d'erreurs Orange Money
            error_scenarios = [
                ("INSUFFICIENT_BALANCE", "Solde Orange Money insuffisant"),
                ("SUBSCRIBER_NOT_FOUND", "Compte Orange Money non trouvé"),
                ("TRANSACTION_LIMIT_EXCEEDED", "Limite de transaction Orange Money dépassée"),
                ("SERVICE_TEMPORARILY_UNAVAILABLE", "Service Orange Money temporairement indisponible"),
                ("AUTHENTICATION_FAILED", "Échec d'authentification Orange Money"),
                ("ACCOUNT_BLOCKED", "Compte Orange Money bloqué")
            ]
            error_code, error_message = random.choice(error_scenarios)
            
            logger.warning(f"🍊 Orange Money API: Payment FAILED for {reference} - {error_code}")
            return PaymentResponse(
                success=False,
                transaction_id=reference,
                gateway_reference=om_ref,
                status=PaymentStatus.FAILED,
                amount=amount,
                currency="XOF",
                message=error_message,
                error_code=error_code,
                gateway_data={
                    'orange_error_time': datetime.now().isoformat(),
                    'orange_error_code': error_code,
                    'processing_time': processing_time,
                    'network': 'ORANGE_SN'
                }
            )
        
        else:
            # ⏱️ TIMEOUT - Simulation timeout réseau
            logger.error(f"🍊 Orange Money API: Payment TIMEOUT for {reference}")
            return PaymentResponse(
                success=False,
                transaction_id=reference,
                gateway_reference="",
                status=PaymentStatus.TIMEOUT,
                amount=amount,
                currency="XOF",
                message="Timeout de la connexion Orange Money - Veuillez réessayer",
                error_code="REQUEST_TIMEOUT"
            )
    
    def check_status(self, gateway_reference: str) -> PaymentResponse:
        """Vérifier le statut d'une transaction Orange Money"""
        logger.info(f"🍊 Orange Money API: Checking status for {gateway_reference}")
        
        # Simuler vérification de statut (plus lent)
        time.sleep(random.uniform(0.5, 1.5))
        
        return PaymentResponse(
            success=True,
            transaction_id="",
            gateway_reference=gateway_reference,
            status=PaymentStatus.SUCCESS,
            amount=Decimal('0'),
            currency="XOF",
            message="Transaction Orange Money confirmée",
            gateway_data={
                'status_check_time': datetime.now().isoformat(),
                'orange_final_status': 'CONFIRMED',
                'network': 'ORANGE_SN'
            }
        )

class PaymentGatewayFactory:
    """Factory pour créer les gateways de paiement"""
    
    _gateways = {
        'WAVE': WaveSimulator,
        'ORANGE_MONEY': OrangeMoneySimulator,
    }
    
    @classmethod
    def create_gateway(cls, gateway_type: str) -> BasePaymentGateway:
        """Créer une instance de gateway"""
        if gateway_type not in cls._gateways:
            raise ValueError(f"Gateway type '{gateway_type}' not supported")
        
        gateway_class = cls._gateways[gateway_type]
        return gateway_class()
    
    @classmethod
    def get_available_gateways(cls) -> list:
        """Obtenir la liste des gateways disponibles"""
        return list(cls._gateways.keys())

class PaymentProcessingService:
    """Service principal pour traiter les paiements via différents gateways"""
    
    def __init__(self):
        self.gateways = {}
        self._load_gateways()
    
    def _load_gateways(self):
        """Charger tous les gateways disponibles"""
        for gateway_type in PaymentGatewayFactory.get_available_gateways():
            try:
                gateway = PaymentGatewayFactory.create_gateway(gateway_type)
                self.gateways[gateway_type] = gateway
                logger.info(f"✅ Payment Gateway {gateway_type} loaded successfully")
            except Exception as e:
                logger.error(f"❌ Failed to load gateway {gateway_type}: {e}")
    
    def process_payment(self, gateway_type: str, phone: str, amount: Decimal, reference: str) -> PaymentResponse:
        """Traiter un paiement via le gateway spécifié"""
        if gateway_type not in self.gateways:
            logger.error(f"Gateway {gateway_type} not available")
            return PaymentResponse(
                success=False,
                transaction_id=reference,
                gateway_reference="",
                status=PaymentStatus.FAILED,
                amount=amount,
                currency="XOF",
                message=f"Gateway {gateway_type} non disponible",
                error_code="GATEWAY_NOT_AVAILABLE"
            )
        
        gateway = self.gateways[gateway_type]
        
        try:
            logger.info(f"🚀 Processing payment via {gateway_type}: {amount} XOF to {phone}")
            return gateway.process_payment(phone, amount, reference)
            
        except Exception as e:
            logger.error(f"❌ Payment processing error in {gateway_type}: {e}")
            return PaymentResponse(
                success=False,
                transaction_id=reference,
                gateway_reference="",
                status=PaymentStatus.FAILED,
                amount=amount,
                currency="XOF",
                message=f"Erreur technique {gateway_type}: {str(e)}",
                error_code="TECHNICAL_ERROR"
            )
    
    def check_payment_status(self, gateway_type: str, gateway_reference: str) -> PaymentResponse:
        """Vérifier le statut d'un paiement"""
        if gateway_type not in self.gateways:
            return PaymentResponse(
                success=False,
                transaction_id="",
                gateway_reference=gateway_reference,
                status=PaymentStatus.FAILED,
                amount=Decimal('0'),
                currency="XOF",
                message=f"Gateway {gateway_type} non disponible",
                error_code="GATEWAY_NOT_AVAILABLE"
            )
        
        gateway = self.gateways[gateway_type]
        return gateway.check_status(gateway_reference)
    
    def get_gateway_info(self, gateway_type: str) -> Dict[str, Any]:
        """Obtenir les informations d'un gateway"""
        if gateway_type not in self.gateways:
            return None
        
        gateway = self.gateways[gateway_type]
        return {
            'name': gateway.name,
            'is_active': gateway.is_active,
            'success_rate': getattr(gateway, 'success_rate', 0.0),
            'fee_structure': getattr(gateway, 'fee_structure', {}),
            'api_base': getattr(gateway, 'api_base', '')
        }

# Instance globale du service
payment_service = PaymentProcessingService()