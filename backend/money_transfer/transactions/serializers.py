# transactions/serializers.py

from rest_framework import serializers
from .models import Transaction, Beneficiaire, CanalPaiement, StatutTransaction

class TransactionSerializers(serializers.ModelSerializer):
    beneficiaire_phone = serializers.CharField(max_length=20, write_only=True) 
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
        
    def create(self, validated_data):
        """Créer une transaction avec calculs automatiques"""
        montant_envoye = validated_data['montantEnvoye']
        canal_paiement_id = validated_data.pop('canal_paiement_id')
        beneficiaire_phone = validated_data.pop('beneficiaire_phone') 
    
        # Récupération du canal de paiement pour appliquer les frais
        canal = CanalPaiement.objects.get(id=canal_paiement_id)     
    
        # CORRECTION : Convertir en Decimal pour éviter l'erreur
        from decimal import Decimal
    
        # Calcul des frais (conversion en Decimal)
        frais_percentage = (Decimal(str(montant_envoye)) * canal.fees_percentage) / 100
        frais_fixe = canal.fees_fixed
        frais_total = frais_percentage + frais_fixe
        
        # Calcul du montant converti 
        montant_converti = Decimal(str(montant_envoye)) - frais_total
        montant_recu = montant_converti
        
        # Créer une transaction
        transaction = Transaction.objects.create(
            montantEnvoye=montant_envoye,
            montantConverti=float(montant_converti),  # Reconvertir en float pour le modèle
            montantRecu=float(montant_recu),
            frais=f"{frais_total:.2f} XOF",
            deviseEnvoi=validated_data.get('deviseEnvoi', 'XOF'),
            deviseReception=validated_data.get('deviseReception', 'XOF'),
            statusTransaction=StatutTransaction.EN_ATTENTE,
        )
        return transaction

class TransactionDetailSerializer(serializers.ModelSerializer):
    status_display = serializers.CharField(source='get_statusTransaction_display', read_only=True)
    
    class Meta:
        model = Transaction
        fields = [
            'id',
            'idTransaction',
            'codeTransaction',
            'montantEnvoye',
            'montantConverti',
            'montantRecu',
            'frais',
            'deviseEnvoi',
            'deviseReception',
            'statusTransaction',
            'status_display',
            'dateTraitement',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id', 'idTransaction', 'codeTransaction', 'montantConverti',
            'montantRecu', 'frais', 'dateTraitement', 'created_at', 'updated_at'
        ]
                
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

class SendMoneyResponseSerializer(serializers.Serializer):
    """Serializer pour la réponse d'envoi d'argent"""
    
    success = serializers.BooleanField()
    message = serializers.CharField()
    transaction_id = serializers.UUIDField(required=False)
    code_transaction = serializers.CharField(required=False)
    montant_total = serializers.DecimalField(max_digits=10, decimal_places=2, required=False)
    frais = serializers.CharField(required=False)

class BeneficiaireSerializer(serializers.ModelSerializer):
    """Serializer pour les bénéficiaires"""
    
    class Meta:
        model = Beneficiaire
        fields = [
            'id',
            'first_name',
            'last_name', 
            'phone',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def validate_phone(self, value):
        """Validation du numéro de téléphone"""
        if not value.startswith(('+221', '77', '78', '70', '76')):
            raise serializers.ValidationError(
                "Le numéro doit être un numéro sénégalais valide"
            )
        return value

class CanalPaiementSerializer(serializers.ModelSerializer):
    """Serializer pour les canaux de paiement"""
    
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
            'created_at'
        ]
        read_only_fields = ['id', 'created_at']