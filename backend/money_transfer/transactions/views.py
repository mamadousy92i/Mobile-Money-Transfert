# transactions/views.py - AVEC INTÉGRATION GATEWAYS SIMULÉS

from rest_framework import viewsets, status
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.db.models import Count, Sum, Avg, Q
from django.shortcuts import get_object_or_404
from django.db import models
from django.utils import timezone
from django.contrib.auth import get_user_model
from decimal import Decimal
import requests
import time
import logging
from datetime import timedelta  # ← AJOUT MANQUANT
from django.utils import timezone

from .models import Transaction, Beneficiaire, CanalPaiement, StatutTransaction, Pays, ServicePaiementInternational, CorridorTransfert, TransactionInternationale,TypeTransaction
from .serializers import (
    TransactionSerializers,
    TransactionDetailSerializer,
    TransactionUpdateStatusSerializer,
    TransactionStatsSerializer,
    BeneficiaireSerializer,
    CanalPaiementSerializer,
    SendMoneyRequestSerializer,
    SendMoneyResponseSerializer,
    TransactionRetraitSerializer,
    ValidationCodeRetraitSerializer,
    CompleteRetraitSerializer,
    SendMoneyInternationalSerializer,
    CalculateurFraisInternationalSerializer,
)

# Import du service de paiement simulé
from payment_gateways.services import payment_service

logger = logging.getLogger(__name__)
User = get_user_model()

class TransactionViewSet(viewsets.ModelViewSet):
    """ViewSet pour les transactions CRUD complet - AVEC GATEWAYS SIMULÉS"""
    
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Filtrer les transactions par utilisateur"""
        if not self.request.user.is_authenticated:
            return Transaction.objects.none()
        
        # L'utilisateur voit ses transactions envoyées ET reçues
        return Transaction.objects.filter(
            Q(expediteur=self.request.user) | Q(destinataire=self.request.user)
        ).order_by('-created_at')
    
    def get_serializer_class(self):
        """Choisir le serializer selon l'action"""
        if self.action == 'create':
            return TransactionSerializers
        elif self.action in ['update', 'partial_update']:
            return TransactionUpdateStatusSerializer
        else:
            return TransactionDetailSerializer
    
    def create(self, request, *args, **kwargs):
        """Créer une nouvelle transaction AVEC SIMULATION GATEWAY"""
        logger.info(f"🚀 Nouvelle transaction initiée par {request.user.phone_number}")
        
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            # Le serializer gère maintenant l'intégration gateway
            transaction = serializer.save()
            
            # Retourner les détails complets avec info gateway
            response_serializer = TransactionDetailSerializer(transaction)
            
            # Déterminer le message selon le statut final
            if transaction.statusTransaction == StatutTransaction.ENVOYE:
                message = f"Transaction {transaction.canal_paiement.canal_name} réussie ✅"
                success = True
                status_code = status.HTTP_201_CREATED
            elif transaction.statusTransaction == StatutTransaction.ANNULE:
                message = f"Transaction {transaction.canal_paiement.canal_name} échouée ❌"
                success = False
                status_code = status.HTTP_400_BAD_REQUEST
            else:
                message = "Transaction en cours de traitement..."
                success = True
                status_code = status.HTTP_201_CREATED
            
            return Response({
                'success': success,
                'message': message,
                'transaction': response_serializer.data
            }, status=status_code)
            
        return Response({
            'success': False,
            'message': 'Données invalides',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
    
    def list(self, request, *args, **kwargs):
        """Lister toutes les transactions de l'utilisateur"""
        queryset = self.get_queryset()
        
        # Filtrage optionnel par statut
        status_filter = request.query_params.get('status', None)
        if status_filter:
            queryset = queryset.filter(Q(statusTransaction=status_filter))
        
        # Filtrage par type (envoyées vs reçues)
        type_filter = request.query_params.get('type', None)
        if type_filter == 'sent':
            queryset = queryset.filter(expediteur=request.user)
        elif type_filter == 'received':
            queryset = queryset.filter(destinataire=request.user)
        
        # Filtrage par gateway
        gateway_filter = request.query_params.get('gateway', None)
        if gateway_filter:
            queryset = queryset.filter(canal_paiement__type_canal=gateway_filter)
        
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
    
    def retrieve(self, request, pk=None):
        """Récupérer une transaction par ID"""
        transaction = get_object_or_404(self.get_queryset(), id=pk)
        serializer = TransactionDetailSerializer(transaction)
        return Response(serializer.data)
    
    @action(detail=True, methods=['patch'])
    def update_status(self, request, pk=None):
        """Endpoint spécial pour changer le statut"""
        transaction = get_object_or_404(self.get_queryset(), id=pk)
        
        # Seul l'expéditeur peut changer le statut (ou admin)
        if transaction.expediteur != request.user and not request.user.is_staff:
            return Response(
                {'error': 'Permission refusée'}, 
                status=status.HTTP_403_FORBIDDEN
            )
        
        serializer = TransactionUpdateStatusSerializer(
            transaction, 
            data=request.data, 
            partial=True
        )
        
        if serializer.is_valid():
            serializer.save()
            
            # Retourner la transaction mise à jour
            response_serializer = TransactionDetailSerializer(transaction)
            return Response(response_serializer.data)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['get'])
    def statistics(self, request):
        """Endpoint pour les statistiques des transactions avec gateways"""
        user_transactions = self.get_queryset()
        
        stats = user_transactions.aggregate(
            total_transactions=Count('id'),
            total_amount=Sum('montantEnvoye'),
            completed_transactions=Count('id', filter=models.Q(statusTransaction='TERMINE')),
            pending_transactions=Count('id', filter=models.Q(statusTransaction='EN_ATTENTE')),
            cancelled_transactions=Count('id', filter=models.Q(statusTransaction='ANNULE')),
            average_amount=Avg('montantEnvoye')
        )
        
        # Stats par type
        stats['envois_count'] = user_transactions.filter(expediteur=request.user).count()
        stats['receptions_count'] = user_transactions.filter(destinataire=request.user).count()
        stats['retraits_count'] = user_transactions.filter(
            typeTransaction='RETRAIT'
        ).count()
        
        # Stats par gateway
        stats['wave_transactions'] = user_transactions.filter(
            canal_paiement__type_canal='WAVE'
        ).count()
        stats['orange_money_transactions'] = user_transactions.filter(
            canal_paiement__type_canal='ORANGE_MONEY'
        ).count()
        
        # Gérer les valeurs nulles
        for key, value in stats.items():
            if value is None:
                stats[key] = 0
        
        serializer = TransactionStatsSerializer(stats)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def mes_retraits_disponibles(self, request):
        """Transactions que l'utilisateur peut retirer"""
        transactions_disponibles = Transaction.objects.filter(
            destinataire_phone=request.user.phone_number,
            statusTransaction=StatutTransaction.ENVOYE
        ).order_by('-created_at')
        
        serializer = TransactionRetraitSerializer(
            transactions_disponibles, 
            many=True,
            context={'request': request}
        )
        return Response(serializer.data)


class BeneficiaireViewSet(viewsets.ModelViewSet):
    """ViewSet pour les bénéficiaires CRUD complet"""
    
    permission_classes = [IsAuthenticated]
    serializer_class = BeneficiaireSerializer
    
    def get_queryset(self):
        """Filtrer les bénéficiaires par propriétaire"""
        if not self.request.user.is_authenticated:
            return Beneficiaire.objects.none()
        
        return Beneficiaire.objects.filter(
            proprietaire=self.request.user
        ).order_by('-derniere_transaction', '-nb_transactions', 'first_name')
    
    def list(self, request, *args, **kwargs):
        """Lister tous les bénéficiaires de l'utilisateur"""
        queryset = self.get_queryset()
        
        # Recherche par nom ou téléphone
        search = request.query_params.get('search', None)
        if search:
            queryset = queryset.filter(
                models.Q(first_name__icontains=search) |
                models.Q(last_name__icontains=search) |
                models.Q(phone__icontains=search)
            )
        
        # Filtrer les favoris (les plus utilisés)
        favoris_only = request.query_params.get('favoris', None)
        if favoris_only:
            queryset = queryset.filter(nb_transactions__gt=0)[:5]
        
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)


class CanalPaiementViewSet(viewsets.ModelViewSet):
    """ViewSet pour les canaux de paiement avec info gateways"""
    
    permission_classes = [AllowAny]  # Public pour récupérer les canaux
    queryset = CanalPaiement.objects.filter(is_active=True).order_by('canal_name')
    serializer_class = CanalPaiementSerializer
    
    def get_permissions(self):
        """Permissions selon l'action"""
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            permission_classes = [IsAuthenticated]  # Seuls les admins peuvent modifier
        else:
            permission_classes = [AllowAny]
        
        return [permission() for permission in permission_classes]
    
    @action(detail=False, methods=['get'])
    def by_country(self, request):
        """Filtrer les canaux par pays"""
        country = request.query_params.get('country', 'Sénégal')
        canaux = self.queryset.filter(country=country)
        serializer = self.get_serializer(canaux, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def gateway_status(self, request):
        """Statut des gateways simulés"""
        gateway_status = {}
        
        for gateway_type in ['WAVE', 'ORANGE_MONEY']:
            info = payment_service.get_gateway_info(gateway_type)
            if info:
                gateway_status[gateway_type] = {
                    'name': info['name'],
                    'is_active': info['is_active'],
                    'success_rate': info.get('success_rate', 0.0),
                    'api_base': info.get('api_base', ''),
                    'status': 'online' if info['is_active'] else 'offline'
                }
        
        return Response({
            'gateway_status': gateway_status,
            'last_check': timezone.now().isoformat()
        })


class SendMoneyView(APIView):
    """Vue pour l'envoi d'argent avec simulation gateway intégrée"""
    
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        """Envoyer de l'argent avec simulation gateway transparente"""
        logger.info(f"💸 Demande d'envoi d'argent de {request.user.phone_number}")
        
        serializer = SendMoneyRequestSerializer(data=request.data)
        
        if not serializer.is_valid():
            return Response({
                'success': False,
                'message': 'Données invalides',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # Convertir les données pour TransactionSerializers
            transaction_data = {
                'montantEnvoye': serializer.validated_data['montant'],
                'beneficiaire_phone': serializer.validated_data['beneficiaire_phone'],
                'canal_paiement_id': serializer.validated_data['canal_paiement'],
                'deviseEnvoi': serializer.validated_data.get('devise_envoi', 'XOF'),
                'deviseReception': serializer.validated_data.get('devise_reception', 'XOF'),
            }
            
            # Créer la transaction avec simulation gateway intégrée
            transaction_serializer = TransactionSerializers(
                data=transaction_data,
                context={'request': request}
            )
            
            if transaction_serializer.is_valid():
                # Le serializer gère maintenant toute la logique gateway
                transaction = transaction_serializer.save()
                
                # Déterminer le message selon le résultat
                canal_nom = transaction.canal_paiement.canal_name
                
                if transaction.statusTransaction == StatutTransaction.ENVOYE:
                    success = True
                    message = f"✅ Transaction {canal_nom} réussie - Prête pour retrait"
                    status_code = status.HTTP_201_CREATED
                elif transaction.statusTransaction == StatutTransaction.ANNULE:
                    success = False
                    message = f"❌ Transaction {canal_nom} échouée - Veuillez réessayer"
                    status_code = status.HTTP_400_BAD_REQUEST
                else:
                    success = True
                    message = f"⏳ Transaction {canal_nom} en cours..."
                    status_code = status.HTTP_201_CREATED
                
                # Réponse unifiée
                response_data = {
                    'success': success,
                    'message': message,
                    'transaction_id': str(transaction.id),
                    'code_transaction': transaction.codeTransaction,
                    'montant_total': float(transaction.montantEnvoye),
                    'frais': transaction.frais,
                    'status': transaction.statusTransaction,
                    'status_display': transaction.get_statusTransaction_display(),
                    'gateway_utilise': canal_nom,
                    'ready_for_withdrawal': transaction.statusTransaction == StatutTransaction.ENVOYE,
                    'destinataire_nom': transaction.destinataire_nom_complet,
                }
                
                logger.info(f"📊 Transaction {transaction.codeTransaction}: {transaction.statusTransaction}")
                return Response(response_data, status=status_code)
            
            else:
                return Response({
                    'success': False,
                    'message': 'Erreur lors de la création de la transaction',
                    'errors': transaction_serializer.errors
                }, status=status.HTTP_400_BAD_REQUEST)
                
        except Exception as e:
            logger.error(f"💥 Erreur lors de l'envoi d'argent: {e}")
            return Response({
                'success': False,
                'message': f'Erreur serveur: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ExchangeRateView(APIView):
    """Vue pour les taux de change universels - PUBLIC"""
    
    permission_classes = [AllowAny]
    
    def get(self, request):
        """Récupérer tous les taux depuis XOF"""
        
        # Paramètres optionnels
        target_currency = request.query_params.get('to', None)
        
        try:
            # Récupérer TOUS les taux depuis XOF
            response = requests.get(
                'https://api.exchangerate-api.com/v4/latest/XOF',
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                
                if target_currency:
                    # Retourner juste une devise spécifique
                    rate = data['rates'].get(target_currency.upper())
                    if rate:
                        return Response({
                            'from': 'XOF',
                            'to': target_currency.upper(),
                            'rate': rate,
                            'last_updated': data.get('date')
                        })
                    else:
                        return Response({
                            'error': f'Devise {target_currency} non supportée'
                        }, status=400)
                
                else:
                    # Retourner les principales devises
                    main_rates = {
                        'XOF_TO_EUR': data['rates'].get('EUR'),
                        'XOF_TO_USD': data['rates'].get('USD'), 
                        'XOF_TO_GBP': data['rates'].get('GBP'),
                        'XOF_TO_CAD': data['rates'].get('CAD'),
                        'XOF_TO_MAD': data['rates'].get('MAD'),
                        'XOF_TO_NGN': data['rates'].get('NGN'),
                        'all_currencies': list(data['rates'].keys()),
                        'total_supported': len(data['rates']),
                        'last_updated': data.get('date')
                    }
                    
                    return Response(main_rates)
        
        except requests.RequestException:
            return Response({'error': 'Service de change temporairement indisponible'}, status=503)


class TransactionSearchView(APIView):
    """Vue pour rechercher des transactions"""
    
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        """Rechercher des transactions par code ou téléphone"""
        query = request.query_params.get('q', '')
        
        if not query:
            return Response({
                'message': 'Paramètre de recherche requis',
                'results': []
            })
        
        # Recherche dans les transactions de l'utilisateur
        transactions = Transaction.objects.filter(
            Q(expediteur=request.user) | Q(destinataire=request.user)
        ).filter(
            Q(codeTransaction__icontains=query) |
            Q(idTransaction__icontains=query) |
            Q(destinataire_phone__icontains=query)
        ).order_by('-created_at')[:10]
        
        serializer = TransactionDetailSerializer(transactions, many=True)
        
        return Response({
            'query': query,
            'count': len(serializer.data),
            'results': serializer.data
        })


# ===== ENDPOINTS POUR GESTION RETRAITS =====

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def validate_transaction_code(request):
    """Valider un code de transaction pour réception avec sécurité"""
    serializer = ValidationCodeRetraitSerializer(data=request.data)
    
    if not serializer.is_valid():
        return Response(serializer.errors, status=400)
    
    try:
        code = serializer.validated_data['code']
        
        # Rechercher la transaction
        transaction = Transaction.objects.get(
            codeTransaction=code,
            statusTransaction=StatutTransaction.ENVOYE
        )
        
        # Vérifier que l'utilisateur peut retirer cette transaction
        if not transaction.peut_etre_retiree_par(request.user):
            return Response({
                'valid': False,
                'error': 'Vous n\'êtes pas autorisé à retirer cette transaction'
            }, status=403)
        
        # Retourner les infos de la transaction
        return Response({
            'valid': True,
            'code': transaction.codeTransaction,
            'montant': transaction.montantRecu,
            'status': transaction.statusTransaction,
            'status_display': transaction.get_statusTransaction_display(),
            'date': transaction.dateTraitement.strftime('%d/%m/%Y'),
            'expediteur_nom': transaction.expediteur_nom_complet,
            'gateway_utilise': transaction.canal_paiement.canal_name,
            'can_withdraw': True,
            'security_check': 'passed'
        })
        
    except Transaction.DoesNotExist:
        return Response({
            'valid': False,
            'error': 'Code invalide, transaction non trouvée ou déjà retirée'
        }, status=404)
    except Exception as e:
        return Response({
            'valid': False,
            'error': f'Erreur: {str(e)}'
        }, status=500)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def complete_transaction_withdrawal(request):
    """Finaliser le retrait d'une transaction"""
    serializer = CompleteRetraitSerializer(data=request.data)
    
    if not serializer.is_valid():
        return Response(serializer.errors, status=400)
    
    try:
        transaction = serializer.validated_data['transaction']
        withdrawal_method = serializer.validated_data['method']
        
        # Vérifier que l'utilisateur peut retirer cette transaction
        if not transaction.peut_etre_retiree_par(request.user):
            return Response({
                'success': False,
                'error': 'Vous n\'êtes pas autorisé à retirer cette transaction'
            }, status=403)
        
        # Marquer comme terminée
        transaction.statusTransaction = StatutTransaction.TERMINE
        transaction.save()
        
        logger.info(f"🏁 Retrait terminé: {transaction.codeTransaction} via {withdrawal_method}")
        
        return Response({
            'success': True,
            'message': 'Retrait effectué avec succès',
            'transaction_code': transaction.codeTransaction,
            'amount_withdrawn': transaction.montantRecu,
            'method': withdrawal_method,
            'gateway_utilise': transaction.canal_paiement.canal_name,
            'completion_date': transaction.updated_at.strftime('%d/%m/%Y %H:%M')
        })
        
    except Exception as e:
        return Response({
            'success': False,
            'error': f'Erreur lors du retrait: {str(e)}'
        }, status=500)


# ===== ENDPOINTS PUBLICS POUR VÉRIFICATION =====

@api_view(['GET'])
@permission_classes([AllowAny])
def transaction_by_code(request, code):
    """Récupérer une transaction par son code - PUBLIC"""
    try:
        transaction = Transaction.objects.get(codeTransaction=code)
        
        # Si l'utilisateur est connecté, vérifier s'il a le droit de voir cette transaction
        if request.user.is_authenticated:
            if transaction.expediteur == request.user or transaction.destinataire == request.user:
                serializer = TransactionDetailSerializer(transaction)
                return Response(serializer.data)
        
        # Informations limitées pour les non-autorisés
        return Response({
            'code': transaction.codeTransaction,
            'status': transaction.statusTransaction,
            'status_display': transaction.get_statusTransaction_display(),
            'date': transaction.dateTraitement,
            'type': transaction.typeTransaction,
            'gateway_utilise': transaction.canal_paiement.canal_name,
            'accessible': False
        })
    except Transaction.DoesNotExist:
        return Response({
            'error': 'Transaction non trouvée'
        }, status=status.HTTP_404_NOT_FOUND)


@api_view(['GET'])
@permission_classes([AllowAny])
def transaction_status_check(request, code):
    """Vérifier le statut d'une transaction par code - PUBLIC"""
    try:
        transaction = Transaction.objects.get(codeTransaction=code)
        return Response({
            'code': transaction.codeTransaction,
            'status': transaction.statusTransaction,
            'status_display': transaction.get_statusTransaction_display(),
            'date': transaction.dateTraitement,
            'gateway_utilise': transaction.canal_paiement.canal_name
        })
    except Transaction.DoesNotExist:
        return Response({
            'error': 'Transaction non trouvée'
        }, status=status.HTTP_404_NOT_FOUND)


# ===== ENDPOINTS DE TEST ET DEBUG =====

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def gateway_info(request):
    """Obtenir les informations des gateways simulés"""
    
    gateway_type = request.query_params.get('type')
    
    if gateway_type:
        # Info d'un gateway spécifique
        info = payment_service.get_gateway_info(gateway_type)
        if info:
            return Response({
                'gateway_type': gateway_type,
                'info': info,
                'is_simulation': True
            })
        else:
            return Response({
                'error': f'Gateway {gateway_type} non trouvé'
            }, status=status.HTTP_404_NOT_FOUND)
    else:
        # Info de tous les gateways
        available_gateways = ['WAVE', 'ORANGE_MONEY']
        gateway_infos = {}
        
        for gw_type in available_gateways:
            info = payment_service.get_gateway_info(gw_type)
            if info:
                gateway_infos[gw_type] = {
                    **info,
                    'is_simulation': True,
                    'simulation_features': [
                        'Temps de réponse réaliste',
                        'Taux de succès configurable',
                        'Différents types d\'erreurs',
                        'Validation des numéros',
                        'Calcul des frais'
                    ]
                }
        
        return Response({
            'available_gateways': available_gateways,
            'gateway_details': gateway_infos,
            'simulation_mode': True,
            'last_check': timezone.now().isoformat()
        })


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def test_gateway_direct(request):
    """Tester directement un gateway (pour debug)"""
    
    gateway_type = request.data.get('gateway_type', 'WAVE')
    phone = request.data.get('phone', '+221771234567')
    amount = Decimal(str(request.data.get('amount', 10000)))
    
    if gateway_type not in ['WAVE', 'ORANGE_MONEY']:
        return Response({
            'error': 'Gateway type non supporté'
        }, status=400)
    
    # Générer une référence de test
    reference = f"TEST_{gateway_type}_{timezone.now().strftime('%Y%m%d_%H%M%S')}"
    
    try:
        # Appeler directement le gateway
        result = payment_service.process_payment(
            gateway_type=gateway_type,
            phone=phone,
            amount=amount,
            reference=reference
        )
        
        return Response({
            'test_type': f'{gateway_type} Direct Test',
            'input': {
                'gateway_type': gateway_type,
                'phone': phone,
                'amount': float(amount),
                'reference': reference
            },
            'result': {
                'success': result.success,
                'status': result.status.value,
                'message': result.message,
                'gateway_reference': result.gateway_reference,
                'fees': float(result.fees) if result.fees else 0,
                'error_code': result.error_code,
                'gateway_data': result.gateway_data
            },
            'simulation_info': 'Ceci est un test direct du simulateur'
        })
        
    except Exception as e:
        return Response({
            'error': f'Erreur lors du test: {str(e)}'
        }, status=500)


# ===== ENDPOINTS DE SIMULATION POUR DÉVELOPPEMENT =====

@api_view(['POST'])
@permission_classes([AllowAny])  # Pour les tests uniquement
def simulate_gateway_scenarios(request):
    """Simuler différents scénarios de gateway (développement)"""
    
    scenario = request.data.get('scenario', 'success')
    gateway_type = request.data.get('gateway_type', 'WAVE')
    phone = request.data.get('phone', '+221771234567')
    amount = Decimal(str(request.data.get('amount', 10000)))
    
    scenarios = {
        'success': 'Transaction réussie',
        'insufficient_funds': 'Solde insuffisant',
        'invalid_phone': 'Numéro invalide',
        'timeout': 'Timeout réseau',
        'service_unavailable': 'Service indisponible'
    }
    
    if scenario not in scenarios:
        return Response({
            'error': 'Scénario non supporté',
            'available_scenarios': list(scenarios.keys())
        }, status=400)
    
    # Pour la simulation, on force certains comportements
    reference = f"SIM_{scenario.upper()}_{timezone.now().strftime('%H%M%S')}"
    
    # Logique de simulation selon le scénario
    if scenario == 'invalid_phone':
        phone = '+221601234567'  # Numéro invalide pour Wave
    elif scenario == 'insufficient_funds':
        # Le simulateur gère cela aléatoirement, on peut juste l'appeler
        pass
    
    try:
        result = payment_service.process_payment(
            gateway_type=gateway_type,
            phone=phone,
            amount=amount,
            reference=reference
        )
        
        return Response({
            'scenario_tested': scenario,
            'scenario_description': scenarios[scenario],
            'gateway_type': gateway_type,
            'result': {
                'success': result.success,
                'status': result.status.value,
                'message': result.message,
                'gateway_reference': result.gateway_reference,
                'fees': float(result.fees) if result.fees else 0,
                'error_code': result.error_code,
                'gateway_data': result.gateway_data
            },
            'note': 'Simulation à des fins de développement'
        })
        
    except Exception as e:
        return Response({
            'error': f'Erreur lors de la simulation: {str(e)}'
        }, status=500)
        
# transactions/views.py - NOUVEAUX ENDPOINTS INTERNATIONAUX

@api_view(['GET'])
@permission_classes([AllowAny])
def pays_disponibles(request):
    """Liste des pays supportés pour transferts internationaux"""
    pays = Pays.objects.filter(is_active=True).order_by('nom')
    
    data = []
    for p in pays:
        data.append({
            'code': p.code_iso,
            'nom': p.nom,
            'devise': p.devise,
            'flag': p.flag_emoji,
            'prefix_tel': p.prefixe_tel,
            'limite_min': p.limite_envoi_min,
            'limite_max': p.limite_envoi_max,
            'nb_services': p.services.filter(is_active=True).count()
        })
    
    return Response({
        'pays': data,
        'total': len(data)
    })

@api_view(['GET']) 
def services_par_pays(request, pays_code):
    """Services de paiement disponibles pour un pays"""
    try:
        pays = Pays.objects.get(code_iso=pays_code, is_active=True)
        services = ServicePaiementInternational.objects.filter(
            pays=pays, is_active=True
        ).order_by('nom')
        
        data = []
        for service in services:
            data.append({
                'code': service.code_service,
                'nom': service.nom,
                'type': service.type_service,
                'frais_min': service.frais_min,
                'frais_max': service.frais_max,
                'limite_min': service.limite_min,
                'limite_max': service.limite_max,
                'logo': f'/static/logos/{service.type_service.lower()}.png'
            })
        
        return Response({
            'pays': {
                'nom': pays.nom,
                'devise': pays.devise,
                'flag': pays.flag_emoji
            },
            'services': data
        })
        
    except Pays.DoesNotExist:
        return Response({'error': 'Pays non trouvé'}, status=404)

@api_view(['POST'])
@permission_classes([AllowAny])
def calculer_frais_international(request):
    """Calculer frais pour transfert international"""
    serializer = CalculateurFraisInternationalSerializer(data=request.data)
    
    if serializer.is_valid():
        try:
            calculs = serializer.calculate_all_fees()
            return Response({
                'success': True,
                'calculs': calculs
            })
        except Exception as e:
            return Response({
                'success': False,
                'error': str(e)
            }, status=400)
    
    return Response({
        'success': False,
        'errors': serializer.errors
    }, status=400)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_money_international(request):
    """Envoyer argent international - VERSION CORRIGÉE"""
    serializer = SendMoneyInternationalSerializer(data=request.data)
    
    if serializer.is_valid():
        try:
            # Récupérer les données validées
            data = serializer.validated_data
            corridor = data['corridor']
            service_dest = data['service_destination_obj']
            
            # ===== CORRECTION 1: PAS DE GATEWAY POUR L'INTERNATIONAL =====
            # Pour l'international, on ne passe PAS par les simulateurs Wave/OM
            # On crée directement la transaction en statut ACCEPTE
            
            # Créer transaction locale de base
            transaction = Transaction.objects.create(
                expediteur=request.user,
                destinataire_phone=data['destinataire_phone'],
                destinataire_nom=data.get('destinataire_nom', f"Contact {data['destinataire_phone']}"),
                typeTransaction=TypeTransaction.ENVOI,
                montantEnvoye=float(data['montant']),
                montantConverti=0,  # Sera calculé
                montantRecu=0,      # Sera calculé  
                frais="0 XOF",      # Sera calculé
                deviseEnvoi=data['devise_envoi'],
                deviseReception=corridor.pays_destination.devise,
                statusTransaction=StatutTransaction.ACCEPTE,  # Pas de gateway, donc ACCEPTE directement
                canal_paiement_id=data['canal_paiement_id'],
            )
            
            # ===== CORRECTION 2: CALCULS FINANCIERS CORRECTS =====
            from decimal import Decimal
            
            montant = Decimal(str(data['montant']))
            
            # 1. Frais canal origine (Wave/OM Sénégal)
            canal_origine = CanalPaiement.objects.get(id=data['canal_paiement_id'])
            frais_origine = canal_origine.calculate_fees(montant)
            
            # 2. Commission corridor
            commission_corridor = (montant * corridor.commission_percentage / 100) + corridor.commission_fixe
            
            # 3. Taux de change (simplifié pour le moment)
            if corridor.pays_origine.devise != corridor.pays_destination.devise:
                # Taux fixe pour simulation (à remplacer par API externe)
                taux_change = Decimal('0.45') if corridor.pays_destination.devise == 'CDF' else Decimal('1.0')
                frais_change = montant * Decimal('0.02')  # 2% frais de change
            else:
                taux_change = Decimal('1.0')
                frais_change = Decimal('0')
            
            # 4. Montant après déduction des frais origine
            montant_net = montant - frais_origine - commission_corridor - frais_change
            
            # 5. Conversion
            montant_destination = montant_net * taux_change
            
            # 6. Frais service destination
            frais_destination = service_dest.calculate_fees(montant_destination)
            
            # 7. Montant final reçu
            montant_final = montant_destination - frais_destination
            
            # Mettre à jour la transaction
            transaction.montantConverti = float(montant_net)
            transaction.montantRecu = float(montant_final) 
            transaction.frais = f"{float(frais_origine + commission_corridor + frais_change):.2f} XOF"
            transaction.statusTransaction = StatutTransaction.ENVOYE  # Prêt pour retrait international
            transaction.save()
            
            # ===== CORRECTION 3: CRÉER EXTENSION INTERNATIONALE =====
            extension = TransactionInternationale.objects.create(
                transaction_locale=transaction,
                pays_origine=corridor.pays_origine,
                pays_destination=corridor.pays_destination, 
                corridor=corridor,
                service_origine=ServicePaiementInternational.objects.filter(
                    pays=corridor.pays_origine, 
                    type_service='WAVE'
                ).first() or ServicePaiementInternational.objects.filter(
                    pays=corridor.pays_origine
                ).first(),
                service_destination=service_dest,
                taux_applique=taux_change,
                montant_origine=montant,
                montant_destination=montant_final,
                frais_service_origine=frais_origine,
                frais_service_destination=frais_destination,
                commission_corridor=commission_corridor,
                frais_change=frais_change,
                temps_traitement_estime=corridor.temps_livraison_max,
                date_livraison_estimee=timezone.now() + timedelta(minutes=corridor.temps_livraison_max),
            )
            
            return Response({
                'success': True,
                'message': f'💰 Transfert international vers {corridor.pays_destination.nom} initialisé',
                'transaction_id': str(transaction.id),
                'code_transaction': transaction.codeTransaction,
                'corridor': corridor.code_corridor,
                'montant_envoye': float(montant),
                'frais_total': float(frais_origine + commission_corridor + frais_change),
                'taux_applique': float(taux_change),
                'montant_recu_destination': float(montant_final),
                'devise_destination': corridor.pays_destination.devise,
                'temps_estime': f"{corridor.temps_livraison_min}-{corridor.temps_livraison_max} minutes",
                'pays_destination': corridor.pays_destination.nom,
                'service_destination': service_dest.nom,
                'status': 'ENVOYE',
                'ready_for_international_withdrawal': True
            })
            
        except Exception as e:
            logger.error(f"💥 Erreur transaction internationale: {e}")
            return Response({
                'success': False,
                'error': f'Erreur lors de la création de la transaction internationale: {str(e)}'
            }, status=500)
    
    return Response({
        'success': False,
        'errors': serializer.errors
    }, status=400)

@api_view(['GET'])
@permission_classes([AllowAny])
def corridors_disponibles(request):
    """Liste des corridors de transfert actifs"""
    corridors = CorridorTransfert.objects.filter(is_active=True)
    
    data = []
    for corridor in corridors:
        data.append({
            'code': corridor.code_corridor,
            'origine': {
                'code': corridor.pays_origine.code_iso,
                'nom': corridor.pays_origine.nom,
                'flag': corridor.pays_origine.flag_emoji,
                'devise': corridor.pays_origine.devise
            },
            'destination': {
                'code': corridor.pays_destination.code_iso,
                'nom': corridor.pays_destination.nom,
                'flag': corridor.pays_destination.flag_emoji,
                'devise': corridor.pays_destination.devise
            },
            'temps_min': corridor.temps_livraison_min,
            'temps_max': corridor.temps_livraison_max,
            'montant_min': corridor.montant_min_corridor,
            'montant_max': corridor.montant_max_corridor,
            'commission': corridor.commission_percentage,
            'taux_succes': corridor.taux_succes,
            'nb_transactions': corridor.nb_transactions
        })
    
    return Response({
        'corridors': data,
        'total': len(data)
    })