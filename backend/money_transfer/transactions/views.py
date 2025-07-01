# transactions/views.py

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Count, Sum, Avg
from django.shortcuts import get_object_or_404
from django.db.models import Q
from django.db import models
import requests  

from .models import Transaction, Beneficiaire, CanalPaiement, StatutTransaction
from .serializers import (
    TransactionSerializers,
    TransactionDetailSerializer,
    TransactionUpdateStatusSerializer,
    TransactionStatsSerializer,
    BeneficiaireSerializer,
    CanalPaiementSerializer,
    SendMoneyRequestSerializer,
    SendMoneyResponseSerializer
)

class TransactionViewSet(viewsets.ModelViewSet):
    """ViewSet pour les transactions CRUD complet"""
    
    queryset = Transaction.objects.all().order_by('-created_at')
    
    def get_serializer_class(self):
        """Choisir le serializer selon l'action"""
        if self.action == 'create':
            return TransactionSerializers
        elif self.action in ['update', 'partial_update']:
            return TransactionUpdateStatusSerializer
        else:
            return TransactionDetailSerializer
    
    def create(self, request, *args, **kwargs):
        """Créer une nouvelle transaction"""
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            transaction = serializer.save()
            
            # Retourner les détails complets
            response_serializer = TransactionDetailSerializer(transaction)
            return Response(
                response_serializer.data, 
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def list(self, request, *args, **kwargs):
        """Lister toutes les transactions"""
        queryset = self.get_queryset()
        
        # Filtrage optionnel par statut
        status_filter = request.query_params.get('status', None)
        if status_filter:
            queryset = queryset.filter(Q(statusTransaction=status_filter))
        
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
    
    def retrieve(self, request, pk=None):
        """Récupérer une transaction par ID"""
        transaction = get_object_or_404(Transaction, id=pk)
        serializer = TransactionDetailSerializer(transaction)
        return Response(serializer.data)
    
    @action(detail=True, methods=['patch'])
    def update_status(self, request, pk=None):
        """Endpoint spécial pour changer le statut"""
        transaction = get_object_or_404(Transaction, id=pk)
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
        """Endpoint pour les statistiques des transactions"""
        stats = Transaction.objects.aggregate(
            total_transactions=Count('id'),
            total_amount=Sum('montantEnvoye'),
            completed_transactions=Count('id', filter=models.Q(statusTransaction='TERMINE')),
            pending_transactions=Count('id', filter=models.Q(statusTransaction='EN_ATTENTE')),
            cancelled_transactions=Count('id', filter=models.Q(statusTransaction='ANNULE')),
            average_amount=Avg('montantEnvoye')
        )
        
        # Gérer les valeurs nulles
        for key, value in stats.items():
            if value is None:
                stats[key] = 0
        
        serializer = TransactionStatsSerializer(stats)
        return Response(serializer.data)

class BeneficiaireViewSet(viewsets.ModelViewSet):
    """ViewSet pour les bénéficiaires CRUD complet"""
    
    queryset = Beneficiaire.objects.all().order_by('-created_at')
    serializer_class = BeneficiaireSerializer
    
    def list(self, request, *args, **kwargs):
        """Lister tous les bénéficiaires"""
        queryset = self.get_queryset()
        
        # Recherche par nom ou téléphone
        search = request.query_params.get('search', None)
        if search:
            queryset = queryset.filter(
                models.Q(first_name__icontains=search) |
                models.Q(last_name__icontains=search) |
                models.Q(phone__icontains=search)
            )
        
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

class CanalPaiementViewSet(viewsets.ModelViewSet): #ViewSet a remettre en lecture seule
    """ViewSet en lecture seule pour les canaux de paiement"""
    
    queryset = CanalPaiement.objects.filter(is_active=True).order_by('canal_name')
    serializer_class = CanalPaiementSerializer
    
    @action(detail=False, methods=['get'])
    def by_country(self, request):
        """Filtrer les canaux par pays"""
        country = request.query_params.get('country', 'Sénégal')
        canaux = self.queryset.filter(country=country)
        serializer = self.get_serializer(canaux, many=True)
        return Response(serializer.data)

class SendMoneyView(APIView):
    """Vue spéciale pour l'envoi d'argent (endpoint simplifié)"""
    
    def post(self, request):
        """Envoyer de l'argent - endpoint principal"""
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
            
            # Créer la transaction
            transaction_serializer = TransactionSerializers(data=transaction_data)
            if transaction_serializer.is_valid():
                transaction = transaction_serializer.save()
                
                # Réponse de succès
                response_data = {
                    'success': True,
                    'message': 'Transaction créée avec succès',
                    'transaction_id': transaction.id,
                    'code_transaction': transaction.codeTransaction,
                    'montant_total': transaction.montantEnvoye,
                    'frais': transaction.frais
                }
                
                response_serializer = SendMoneyResponseSerializer(response_data)
                return Response(response_serializer.data, status=status.HTTP_201_CREATED)
            
            else:
                return Response({
                    'success': False,
                    'message': 'Erreur lors de la création de la transaction',
                    'errors': transaction_serializer.errors
                }, status=status.HTTP_400_BAD_REQUEST)
                
        except Exception as e:
            return Response({
                'success': False,
                'message': f'Erreur serveur: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# transactions/views.py

import requests
from django.core.cache import cache

class ExchangeRateView(APIView):
    """Vue pour les taux de change universels"""
    
    def get(self, request):
        """Récupérer tous les taux depuis XOF"""
        
        # Paramètres optionnels
        target_currency = request.query_params.get('to', None)  # Devise cible
        
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
                        'all_currencies': list(data['rates'].keys()),  # Liste complète
                        'total_supported': len(data['rates']),
                        'last_updated': data.get('date')
                    }
                    
                    return Response(main_rates)
        
        except requests.RequestException:
            return Response({'error': 'Service de change temporairement indisponible'}, status=503)

class TransactionSearchView(APIView):
    """Vue pour rechercher des transactions"""
    
    def get(self, request):
        """Rechercher des transactions par code ou téléphone"""
        query = request.query_params.get('q', '')
        
        if not query:
            return Response({
                'message': 'Paramètre de recherche requis',
                'results': []
            })
        
        # Recherche par code transaction ou téléphone bénéficiaire
        transactions = Transaction.objects.filter(
            models.Q(codeTransaction__icontains=query) |
            models.Q(idTransaction__icontains=query)
        ).order_by('-created_at')[:10]  # Limite à 10 résultats
        
        serializer = TransactionDetailSerializer(transactions, many=True)
        
        return Response({
            'query': query,
            'count': len(serializer.data),
            'results': serializer.data
        })

# Vue basée sur les fonctions (alternative plus simple)

from rest_framework.decorators import api_view

@api_view(['GET'])
def transaction_by_code(request, code):
    """Récupérer une transaction par son code"""
    try:
        transaction = Transaction.objects.get(codeTransaction=code)
        serializer = TransactionDetailSerializer(transaction)
        return Response(serializer.data)
    except Transaction.DoesNotExist:
        return Response({
            'error': 'Transaction non trouvée'
        }, status=status.HTTP_404_NOT_FOUND)

@api_view(['GET'])
def transaction_status_check(request, code):
    """Vérifier le statut d'une transaction par code"""
    try:
        transaction = Transaction.objects.get(codeTransaction=code)
        return Response({
            'code': transaction.codeTransaction,
            'status': transaction.statusTransaction,
            'status_display': transaction.get_statusTransaction_display(),
            'montant': transaction.montantEnvoye,
            'date': transaction.dateTraitement
        })
    except Transaction.DoesNotExist:
        return Response({
            'error': 'Transaction non trouvée'
        }, status=status.HTTP_404_NOT_FOUND)