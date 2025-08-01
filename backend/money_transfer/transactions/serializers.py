# transactions/serializers.py - VERSION CORRIGÉE

from rest_framework import serializers
from .models import Transaction, Beneficiaire, CanalPaiement, TypeTransaction, StatutTransaction,  Pays, ServicePaiementInternational, CorridorTransfert, TransactionInternationale
from django.contrib.auth import get_user_model
from django.db.models import Q
from decimal import Decimal
import logging

# Import du service de paiement simulé
from payment_gateways.services import payment_service, PaymentStatus

logger = logging.getLogger(__name__)
User = get_user_model()

class TransactionSerializers(serializers.ModelSerializer):
    beneficiaire_phone = serializers.CharField(max_length=20, write_only=True) 
    """beneficiaire_phone"""
    canal_paiement_id = serializers.UUIDField(write_only=True)  
    
    class Meta:
        model = Transaction
        fields = [
            'montantEnvoye',
            'deviseEnvoi',
            'deviseReception',
            'beneficiaire_phone',
            'canal_paiement_id',  
        ]
    
    def validate_montantEnvoye(self, value):  
        """Vérifier si le montant envoyé est valide"""
        if value <= 0:
            raise serializers.ValidationError("Le montant envoyé doit être supérieur à 0")
        if value > 500000:
            raise serializers.ValidationError("Le montant envoyé doit être inférieur à 500000")
        if value < 100:
            raise serializers.ValidationError("Le montant envoyé doit être supérieur à 100")
        return value
    
    def validate_canal_paiement_id(self, value):  
        """Vérifier si le canal de paiement existe ou est actif"""
        try:
            canal = CanalPaiement.objects.get(id=value, is_active=True)
            return value
        except CanalPaiement.DoesNotExist:
            raise serializers.ValidationError("Le canal de paiement n'existe pas ou est inactif")
    
    def _get_gateway_type(self, canal_type):
        """Mapper le type de canal vers le type de gateway"""
        mapping = {
            'WAVE': 'WAVE',
            'ORANGE_MONEY': 'ORANGE_MONEY',
        }
        return mapping.get(canal_type)
        
    def create(self, validated_data):
        """Créer une transaction avec simulation gateway INTÉGRÉE - VERSION CORRIGÉE"""
        # Récupérer l'utilisateur depuis le context
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            raise serializers.ValidationError("Utilisateur non authentifié")
        
        montant_envoye = validated_data['montantEnvoye']
        canal_paiement_id = validated_data.pop('canal_paiement_id')
        beneficiaire_phone = validated_data.pop('beneficiaire_phone') 
    
        # Récupération du canal de paiement
        canal = CanalPaiement.objects.get(id=canal_paiement_id)     
    
        # Vérifier si le destinataire est un utilisateur inscrit
        destinataire_user = None
        try:
            destinataire_user = User.objects.get(phone_number=beneficiaire_phone)
        except User.DoesNotExist:
            pass
        
        # Obtenir le nom du destinataire
        destinataire_nom = ""
        if destinataire_user:
            destinataire_nom = destinataire_user.get_full_name()
        else:
            # Chercher dans les bénéficiaires de l'expéditeur
            try:
                beneficiaire = Beneficiaire.objects.get(
                    proprietaire=request.user,
                    phone=beneficiaire_phone
                )
                destinataire_nom = beneficiaire.nom_complet
            except Beneficiaire.DoesNotExist:
                destinataire_nom = f"Contact {beneficiaire_phone}"
        
        # ===== INTÉGRATION GATEWAY SIMULÉ - VERSION CORRIGÉE =====
        
        # 1. Créer la transaction en statut EN_ATTENTE
        transaction = Transaction.objects.create(
            expediteur=request.user,
            destinataire=destinataire_user,
            destinataire_phone=beneficiaire_phone,
            destinataire_nom=destinataire_nom,
            canal_paiement=canal,
            typeTransaction=TypeTransaction.ENVOI,
            montantEnvoye=montant_envoye,
            montantConverti=0,  # Sera calculé après gateway
            montantRecu=0,      # Sera calculé après gateway
            frais="0 XOF",      # Sera calculé après gateway
            deviseEnvoi=validated_data.get('deviseEnvoi', 'XOF'),
            deviseReception=validated_data.get('deviseReception', 'XOF'),
            statusTransaction=StatutTransaction.EN_ATTENTE,
        )
        
        logger.info(f"💫 Transaction {transaction.codeTransaction} créée, début simulation gateway")
        
        # 2. Déterminer le type de gateway
        gateway_type = self._get_gateway_type(canal.type_canal)
        
        if not gateway_type:
            # Gateway non supporté
            transaction.statusTransaction = StatutTransaction.ANNULE
            transaction.save()
            raise serializers.ValidationError(f"Type de gateway {canal.type_canal} non supporté")
        
        try:
            # 3. Appeler le simulateur de gateway
            logger.info(f"🔄 Appel {gateway_type} pour transaction {transaction.codeTransaction}")
            
            # CORRECTION: Convertir le montant en Decimal
            montant_decimal = Decimal(str(montant_envoye))
            
            payment_response = payment_service.process_payment(
                gateway_type=gateway_type,
                phone=beneficiaire_phone,
                amount=montant_decimal,  # UTILISER DECIMAL
                reference=transaction.codeTransaction
            )
            
            # 4. Traiter la réponse du gateway - VERSION CORRIGÉE
            if payment_response.success:
                # ✅ SUCCÈS - Calculer les frais réels du gateway
                frais_gateway = payment_response.fees if payment_response.fees else Decimal('0')
                
                # CORRECTION: Tous les calculs en Decimal
                montant_envoye_decimal = Decimal(str(montant_envoye))
                montant_converti = montant_envoye_decimal - frais_gateway
                
                # Mettre à jour la transaction avec les données du gateway
                transaction.montantConverti = float(montant_converti)
                transaction.montantRecu = float(montant_converti)
                transaction.frais = f"{frais_gateway:.2f} XOF"
                transaction.statusTransaction = StatutTransaction.ENVOYE  # Prêt pour retrait
                transaction.save()
                
                logger.info(f"✅ {gateway_type}: Transaction {transaction.codeTransaction} SUCCESS")
                logger.info(f"💰 Frais {gateway_type}: {frais_gateway} XOF")
                
            else:
                # ❌ ÉCHEC - Gateway a refusé
                # Calculer les frais prévus pour information
                frais_calcules_decimal = canal.calculate_fees(Decimal(str(montant_envoye)))
                montant_envoye_decimal = Decimal(str(montant_envoye))
                montant_converti = montant_envoye_decimal - frais_calcules_decimal
                
                transaction.montantConverti = float(montant_converti)
                transaction.montantRecu = float(montant_converti)
                transaction.frais = f"{frais_calcules_decimal:.2f} XOF (calculé)"
                transaction.statusTransaction = StatutTransaction.ANNULE
                transaction.save()
                
                logger.warning(f"❌ {gateway_type}: Transaction {transaction.codeTransaction} FAILED")
                logger.warning(f"🚫 Raison: {payment_response.message}")
                
        except Exception as e:
            # 🔥 ERREUR TECHNIQUE
            logger.error(f"💥 Erreur technique gateway pour {transaction.codeTransaction}: {e}")
            
            # Calculer les frais prévus pour information
            frais_calcules_decimal = canal.calculate_fees(Decimal(str(montant_envoye)))
            montant_envoye_decimal = Decimal(str(montant_envoye))
            montant_converti = montant_envoye_decimal - frais_calcules_decimal
            
            transaction.montantConverti = float(montant_converti)
            transaction.montantRecu = float(montant_converti)
            transaction.frais = f"{frais_calcules_decimal:.2f} XOF (calculé)"
            transaction.statusTransaction = StatutTransaction.ANNULE
            transaction.save()
        
        # 5. Mettre à jour ou créer le bénéficiaire si nécessaire
        if not destinataire_user:
            beneficiaire, created = Beneficiaire.objects.get_or_create(
                proprietaire=request.user,
                phone=beneficiaire_phone,
                defaults={
                    'first_name': destinataire_nom.split(' ')[0] if destinataire_nom else '',
                    'last_name': ' '.join(destinataire_nom.split(' ')[1:]) if len(destinataire_nom.split(' ')) > 1 else '',
                }
            )
            beneficiaire.marquer_transaction()
        
        logger.info(f"🏁 Transaction {transaction.codeTransaction} finalisée: {transaction.statusTransaction}")
        return transaction


class TransactionDetailSerializer(serializers.ModelSerializer):
    status_display = serializers.CharField(source='get_statusTransaction_display', read_only=True)
    type_display = serializers.CharField(source='get_typeTransaction_display', read_only=True)
    
    # Informations utilisateurs avec fallback
    expediteur_nom = serializers.SerializerMethodField()
    expediteur_phone = serializers.SerializerMethodField()
    destinataire_nom = serializers.SerializerMethodField()
    destinataire_phone = serializers.CharField(read_only=True)
    destinataire_est_inscrit = serializers.BooleanField(read_only=True)
    
    # Informations canal et gateway
    canal_paiement_nom = serializers.CharField(source='canal_paiement.canal_name', read_only=True)
    canal_paiement_type = serializers.CharField(source='canal_paiement.type_canal', read_only=True)
    gateway_utilise = serializers.SerializerMethodField()
    pays_origine = serializers.SerializerMethodField()
    pays_destination = serializers.SerializerMethodField()
    
    class Meta:
        model = Transaction
        fields = [
            'id',
            'idTransaction',
            'codeTransaction',
            'typeTransaction',
            'montantEnvoye',
            'montantConverti',
            'montantRecu',
            'frais',
            'deviseEnvoi',
            'deviseReception',
            'statusTransaction',
            'status_display',
            'type_display',
            'dateTraitement',
            'created_at',
            'updated_at',
            # Informations utilisateurs
            'expediteur_nom',
            'expediteur_phone',
            'destinataire_nom',
            'destinataire_phone',
            'destinataire_est_inscrit',
            # Informations canal et gateway
            'canal_paiement_nom',
            'canal_paiement_type',
            'gateway_utilise',
            'pays_origine',
            'pays_destination',
        ]
        read_only_fields = [
            'id', 'idTransaction', 'codeTransaction', 'montantConverti',
            'montantRecu', 'frais', 'dateTraitement', 'created_at', 'updated_at'
        ]

    def get_expediteur_nom(self, obj):
        """Nom de l'expéditeur"""
        return obj.expediteur_nom_complet

    def get_expediteur_phone(self, obj):
        """Téléphone de l'expéditeur"""
        return obj.expediteur.phone_number if obj.expediteur else None

    def get_destinataire_nom(self, obj):
        """Nom du destinataire"""
        return obj.destinataire_nom_complet
    
    def get_gateway_utilise(self, obj):
        """Gateway utilisé pour la transaction"""
        gateway_mapping = {
            'WAVE': 'Wave',
            'ORANGE_MONEY': 'Orange Money',
        }
        return gateway_mapping.get(obj.canal_paiement.type_canal, obj.canal_paiement.type_canal)

    def to_representation(self, instance):
        """Assurer que typeTransaction n'est jamais null"""
        representation = super().to_representation(instance)
        if not representation.get('typeTransaction'):
            representation['typeTransaction'] = 'ENVOI'
        return representation
    def get_pays_origine(self, obj):
        if hasattr(obj, 'extension_internationale'):
            return obj.extension_internationale.pays_origine.nom
        return "Sénégal" # Valeur par défaut pour les transactions nationales

    def get_pays_destination(self, obj):
        if hasattr(obj, 'extension_internationale'):
            return obj.extension_internationale.pays_destination.nom
        return "Sénégal" # Valeur par défaut pour les transactions nationales


class TransactionUpdateStatusSerializer(serializers.ModelSerializer):
    """Serializer pour mettre à jour le statut d'une transaction"""
    
    class Meta:
        model = Transaction
        fields = ['statusTransaction']
    
    def validate_statusTransaction(self, value):
        """Validation des transitions de statut"""
        current_status = self.instance.statusTransaction
        
        # Règles de transition
        valid_transitions = {
            StatutTransaction.EN_ATTENTE: [StatutTransaction.ACCEPTE, StatutTransaction.ANNULE],
            StatutTransaction.ACCEPTE: [StatutTransaction.ENVOYE, StatutTransaction.ANNULE],
            StatutTransaction.ENVOYE: [StatutTransaction.TERMINE],
            StatutTransaction.TERMINE: [],  # État final
            StatutTransaction.ANNULE: []   # État final
        }
        
        if value not in valid_transitions.get(current_status, []):
            raise serializers.ValidationError(
                f"Transition invalide de {current_status} vers {value}"
            )
        
        return value


class TransactionStatsSerializer(serializers.Serializer):
    """Serializer pour les statistiques des transactions"""
    
    total_transactions = serializers.IntegerField()
    total_amount = serializers.DecimalField(max_digits=15, decimal_places=2)
    completed_transactions = serializers.IntegerField()
    pending_transactions = serializers.IntegerField()
    cancelled_transactions = serializers.IntegerField()
    average_amount = serializers.DecimalField(max_digits=10, decimal_places=2)
    
    # Stats par type et gateway
    envois_count = serializers.IntegerField()
    receptions_count = serializers.IntegerField()
    retraits_count = serializers.IntegerField()
    wave_transactions = serializers.IntegerField()
    orange_money_transactions = serializers.IntegerField()


class SendMoneyRequestSerializer(serializers.Serializer):
    """Serializer pour la requête d'envoi d'argent (endpoint spécial)"""
    
    beneficiaire_phone = serializers.CharField(max_length=20)
    montant = serializers.DecimalField(max_digits=10, decimal_places=2)
    canal_paiement = serializers.UUIDField()
    devise_envoi = serializers.CharField(max_length=10, default='XOF')
    devise_reception = serializers.CharField(max_length=10, default='XOF')
    
    def validate_montant(self, value):
        if value <= 0:
            raise serializers.ValidationError("Le montant doit être positif")
        return value
    
    def validate_beneficiaire_phone(self, value):
        """Validation du format du numéro - CORRIGÉ pour accepter tous les numéros sénégalais"""
        import re
        # Normaliser le numéro
        value = value.replace(' ', '').replace('-', '')
        
        # Vérifier le format sénégalais (tous les préfixes)
        pattern = r'^(\+221|221)?(77|78|70|76|75)\d{7}$'
        if not re.match(pattern, value):
            raise serializers.ValidationError(
                "Format de numéro invalide. Utilisez +221XXXXXXXX avec préfixes: 77, 78, 70, 76, 75"
            )
        
        # Normaliser au format +221
        if not value.startswith('+221'):
            if value.startswith('221'):
                value = '+' + value
            else:
                value = '+221' + value
        
        return value


class SendMoneyResponseSerializer(serializers.Serializer):
    """Serializer pour la réponse d'envoi d'argent avec gateway"""
    
    success = serializers.BooleanField()
    message = serializers.CharField()
    transaction_id = serializers.UUIDField(required=False)
    code_transaction = serializers.CharField(required=False)
    montant_total = serializers.DecimalField(max_digits=10, decimal_places=2, required=False)
    frais = serializers.CharField(required=False)
    status = serializers.CharField(required=False)
    status_display = serializers.CharField(required=False)
    gateway_utilise = serializers.CharField(required=False)
    ready_for_withdrawal = serializers.BooleanField(required=False)
    destinataire_nom = serializers.CharField(required=False)


# Dans transactions/serializers.py - CORRECTION BeneficiaireSerializer

class BeneficiaireSerializer(serializers.ModelSerializer):
    """Serializer pour les bénéficiaires"""
    
    # Informations sur l'utilisateur correspondant
    est_utilisateur_inscrit = serializers.BooleanField(read_only=True)  # ✅ CORRIGÉ - supprimé source
    nom_utilisateur_inscrit = serializers.SerializerMethodField()
    
    class Meta:
        model = Beneficiaire
        fields = [
            'id',
            'first_name',
            'last_name', 
            'phone',
            'nb_transactions',
            'derniere_transaction',
            'est_utilisateur_inscrit',
            'nom_utilisateur_inscrit',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'nb_transactions', 'derniere_transaction']
    
    def get_nom_utilisateur_inscrit(self, obj):
        """Nom de l'utilisateur inscrit correspondant"""
        if obj.user_correspondant:
            return obj.user_correspondant.get_full_name()
        return None
    
    def validate_phone(self, value):
        """Validation du numéro de téléphone - CORRIGÉ"""
        import re
        # Normaliser le numéro
        value = value.replace(' ', '').replace('-', '')
        
        # Accepter tous les numéros sénégalais
        pattern = r'^(\+221|221)?(77|78|70|76|75)\d{7}$'
        if not re.match(pattern, value):
            raise serializers.ValidationError(
                "Le numéro doit être un numéro sénégalais valide (+221XXXXXXXX) avec préfixes: 77, 78, 70, 76, 75"
            )
        
        # Normaliser au format +221
        if not value.startswith('+221'):
            if value.startswith('221'):
                value = '+' + value
            else:
                value = '+221' + value
        
        return value
    
    def create(self, validated_data):
        """Créer un bénéficiaire avec le propriétaire"""
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            raise serializers.ValidationError("Utilisateur non authentifié")
        
        # Vérifier si l'utilisateur correspondant existe
        user_correspondant = None
        try:
            User = get_user_model()
            user_correspondant = User.objects.get(phone_number=validated_data['phone'])
        except User.DoesNotExist:
            pass
        
        # Créer le bénéficiaire
        beneficiaire = Beneficiaire.objects.create(
            proprietaire=request.user,
            user_correspondant=user_correspondant,
            **validated_data
        )
        
        return beneficiaire


class CanalPaiementSerializer(serializers.ModelSerializer):
    """Serializer pour les canaux de paiement avec info gateway"""
    
    gateway_info = serializers.SerializerMethodField()
    
    class Meta:
        model = CanalPaiement
        fields = [
            'id',
            'canal_name',
            'type_canal',
            'is_active',
            'country',
            'fees_percentage',
            'fees_fixed',
            'min_amount',
            'max_amount',
            'created_at',
            'gateway_info'
        ]
        read_only_fields = ['id', 'created_at']
    
    def get_gateway_info(self, obj):
        """Obtenir les informations du gateway simulé"""
        try:
            from payment_gateways.services import payment_service
            gateway_type = obj.type_canal
            info = payment_service.get_gateway_info(gateway_type)
            if info:
                return {
                    'gateway_name': info['name'],
                    'success_rate': info.get('success_rate', 0.0),
                    'api_base': info.get('api_base', ''),
                    'is_simulation': True,
                    'accepted_phone_prefixes': 'Tous les numéros sénégalais (77, 78, 70, 76, 75)'
                }
        except:
            pass
        
        return {
            'gateway_name': obj.canal_name,
            'success_rate': 0.0,
            'api_base': '',
            'is_simulation': False,
            'accepted_phone_prefixes': 'Inconnu'
        }


# Serializers pour les retraits (inchangés)
class TransactionRetraitSerializer(serializers.ModelSerializer):
    """Serializer pour les transactions que l'utilisateur peut retirer"""
    
    expediteur_nom = serializers.CharField(source='expediteur_nom_complet', read_only=True)
    expediteur_phone = serializers.CharField(source='expediteur.phone_number', read_only=True)
    peut_retirer = serializers.SerializerMethodField()
    gateway_utilise = serializers.SerializerMethodField()
    
    class Meta:
        model = Transaction
        fields = [
            'id',
            'codeTransaction',
            'montantRecu',
            'deviseReception',
            'statusTransaction',
            'status_display',
            'dateTraitement',
            'expediteur_nom',
            'expediteur_phone',
            'peut_retirer',
            'gateway_utilise',
        ]
    
    def get_peut_retirer(self, obj):
        """Vérifier si l'utilisateur actuel peut retirer cette transaction"""
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            return False
        
        return obj.peut_etre_retiree_par(request.user)
    
    def get_gateway_utilise(self, obj):
        """Gateway utilisé pour cette transaction"""
        gateway_mapping = {
            'WAVE': 'Wave',
            'ORANGE_MONEY': 'Orange Money',
        }
        return gateway_mapping.get(obj.canal_paiement.type_canal, obj.canal_paiement.type_canal)


class ValidationCodeRetraitSerializer(serializers.Serializer):
    """Serializer pour valider un code de retrait"""
    
    code = serializers.CharField(max_length=20)
    phone = serializers.CharField(max_length=20, required=False)
    
    def validate_code(self, value):
        """Valider le format du code"""
        if not value.startswith(('TXN', 'RCP', 'RET', 'RCH')):
            raise serializers.ValidationError("Format de code invalide")
        return value


class CompleteRetraitSerializer(serializers.Serializer):
    """Serializer pour compléter un retrait"""
    
    code = serializers.CharField(max_length=20)
    method = serializers.ChoiceField(choices=[
        ('ACCOUNT', 'Vers le compte'),
        ('AGENT', 'Chez un agent'),
        ('MOBILE', 'Mobile money')
    ])
    phone = serializers.CharField(max_length=20, required=False)
    
    def validate(self, data):
        """Validation globale"""
        code = data.get('code')
        
        # Vérifier que la transaction existe et peut être retirée
        try:
            transaction = Transaction.objects.get(
                codeTransaction=code,
                statusTransaction=StatutTransaction.ENVOYE
            )
        except Transaction.DoesNotExist:
            raise serializers.ValidationError("Transaction non trouvée ou non disponible pour retrait")
        
        # Ajouter la transaction aux données validées
        data['transaction'] = transaction
        return data
    
    
# transactions/serializers.py - AJOUTS INTERNATIONAUX

class SendMoneyInternationalSerializer(serializers.Serializer):
    """Serializer pour envoi international"""
    
    # Destinataire
    destinataire_phone = serializers.CharField(max_length=20)
    destinataire_nom = serializers.CharField(max_length=100, required=False)
    
    # Montant et devise
    montant = serializers.DecimalField(max_digits=10, decimal_places=2)
    devise_envoi = serializers.CharField(max_length=3, default='XOF')
    
    # Destination
    pays_destination = serializers.CharField(max_length=3)  # Code ISO
    service_destination = serializers.CharField(max_length=20)
    
    # Canal de paiement local
    canal_paiement_id = serializers.UUIDField()
    
    def validate(self, data):
        """Validation complète transaction internationale"""
        # Vérifier corridor actif
        try:
            corridor = CorridorTransfert.objects.get(
                pays_origine__code_iso='SEN',  # Votre pays de base
                pays_destination__code_iso=data['pays_destination'],
                is_active=True
            )
        except CorridorTransfert.DoesNotExist:
            raise serializers.ValidationError("Corridor non disponible")
        
        # Vérifier service destination
        try:
            service = ServicePaiementInternational.objects.get(
                pays__code_iso=data['pays_destination'],
                code_service=data['service_destination'],
                is_active=True
            )
        except ServicePaiementInternational.DoesNotExist:
            raise serializers.ValidationError("Service de destination non disponible")
        
        # Vérifier limites
        if not (corridor.montant_min_corridor <= data['montant'] <= corridor.montant_max_corridor):
            raise serializers.ValidationError(
                f"Montant doit être entre {corridor.montant_min_corridor} et {corridor.montant_max_corridor}"
            )
        
        # Valider numéro destinataire
        if not service.validate_phone(data['destinataire_phone']):
            raise serializers.ValidationError("Numéro destinataire invalide pour ce service")
        
        data['corridor'] = corridor
        data['service_destination_obj'] = service
        return data

class CalculateurFraisInternationalSerializer(serializers.Serializer):
    """Calculer frais pour transaction internationale"""
    
    montant = serializers.DecimalField(max_digits=10, decimal_places=2)
    corridor = serializers.CharField(max_length=10)  # SEN_TO_COG
    service_destination = serializers.CharField(max_length=20)
    
    def calculate_all_fees(self):
        """Calculer tous les frais et retourner détail"""
        from .services.exchange_rates import ExchangeRateService
        
        data = self.validated_data
        corridor_code = data['corridor']
        
        # Obtenir objets
        origine_code, dest_code = corridor_code.split('_TO_')
        corridor = CorridorTransfert.objects.get(
            pays_origine__code_iso=origine_code,
            pays_destination__code_iso=dest_code
        )
        
        service_dest = ServicePaiementInternational.objects.get(
            pays__code_iso=dest_code,
            code_service=data['service_destination']
        )
        
        # Calculs
        montant = data['montant']
        
        # 1. Frais service origine (Wave/OM Sénégal)
        canal_origine = CanalPaiement.objects.filter(
            country="Sénégal", is_active=True
        ).first()
        frais_origine = canal_origine.calculate_fees(montant)
        
        # 2. Commission corridor
        commission = (montant * corridor.commission_percentage / 100) + corridor.commission_fixe
        
        # 3. Taux de change
        exchange_service = ExchangeRateService()
        devise_orig = corridor.pays_origine.devise
        devise_dest = corridor.pays_destination.devise
        
        if devise_orig != devise_dest:
            taux = exchange_service.get_rate(devise_orig, devise_dest)
            montant_converti = exchange_service.calculate_conversion(
                montant - frais_origine - commission, 
                devise_orig, devise_dest
            )
            frais_change = montant_converti * Decimal('0.02')  # 2% frais change
        else:
            montant_converti = montant - frais_origine - commission
            frais_change = Decimal('0')
            taux = Decimal('1')
        
        # 4. Frais service destination
        frais_destination = service_dest.calculate_fees(montant_converti)
        
        # Montant final reçu
        montant_final = montant_converti - frais_destination
        
        return {
            'montant_envoye': montant,
            'frais_origine': frais_origine,
            'commission_corridor': commission,
            'frais_change': frais_change,
            'frais_destination': frais_destination,
            'frais_total': frais_origine + commission + frais_change,
            'taux_applique': taux,
            'montant_converti': montant_converti,
            'montant_recu': montant_final,
            'devise_origine': devise_orig,
            'devise_destination': devise_dest,
            'temps_estime': f"{corridor.temps_livraison_min}-{corridor.temps_livraison_max} min"
        }