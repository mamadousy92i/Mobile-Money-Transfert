from django.core.management.base import BaseCommand
from transactions.models import Pays, ServicePaiementInternational, CorridorTransfert
from decimal import Decimal

class Command(BaseCommand):
    help = 'Créer données de test pour international'

    def handle(self, *args, **options):
        self.stdout.write('🌍 Création des données internationales...')
        
        # ===== CRÉER PAYS =====
        senegal, _ = Pays.objects.get_or_create(
            code_iso='SEN',
            defaults={
                'nom': 'Sénégal',
                'devise': 'XOF',
                'prefixe_tel': '+221',
                'flag_emoji': '🇸🇳',
                'limite_envoi_min': Decimal('100'),
                'limite_envoi_max': Decimal('500000')
            }
        )
        
        congo, _ = Pays.objects.get_or_create(
            code_iso='COG',
            defaults={
                'nom': 'République Démocratique du Congo',
                'devise': 'CDF',
                'prefixe_tel': '+243',
                'flag_emoji': '🇨🇩',
                'limite_envoi_min': Decimal('1000'),
                'limite_envoi_max': Decimal('1000000')
            }
        )
        
        mali, _ = Pays.objects.get_or_create(
            code_iso='MLI',
            defaults={
                'nom': 'Mali',
                'devise': 'XOF',
                'prefixe_tel': '+223',
                'flag_emoji': '🇲🇱',
                'limite_envoi_min': Decimal('100'),
                'limite_envoi_max': Decimal('300000')
            }
        )
        
        # ===== SERVICES SÉNÉGAL =====
        ServicePaiementInternational.objects.get_or_create(
            pays=senegal,
            code_service='WAVE_SN',
            defaults={
                'nom': 'Wave Sénégal',
                'type_service': 'WAVE',
                'frais_percentage': Decimal('1.0'),
                'frais_min': Decimal('25'),
                'frais_max': Decimal('1500'),
                'limite_min': Decimal('100'),
                'limite_max': Decimal('500000'),
                'regex_telephone': r'^\+221(77|78|70|76|75)\d{7}$'
            }
        )
        
        ServicePaiementInternational.objects.get_or_create(
            pays=senegal,
            code_service='OM_SN',
            defaults={
                'nom': 'Orange Money Sénégal',
                'type_service': 'ORANGE_MONEY',
                'frais_percentage': Decimal('1.5'),
                'frais_fixe': Decimal('50'),
                'frais_min': Decimal('100'),
                'frais_max': Decimal('2000'),
                'limite_min': Decimal('500'),
                'limite_max': Decimal('750000'),
                'regex_telephone': r'^\+221(77|78|70|76|75)\d{7}$'
            }
        )
        
        # ===== SERVICES CONGO =====
        ServicePaiementInternational.objects.get_or_create(
            pays=congo,
            code_service='MTN_CG',
            defaults={
                'nom': 'MTN Money Congo',
                'type_service': 'MTN_MONEY',
                'frais_percentage': Decimal('2.0'),
                'frais_min': Decimal('500'),
                'frais_max': Decimal('5000'),
                'limite_min': Decimal('1000'),
                'limite_max': Decimal('500000'),
                'regex_telephone': r'^\+243(81|82|83|84|85|89)\d{7}$'
            }
        )
        
        ServicePaiementInternational.objects.get_or_create(
            pays=congo,
            code_service='AIRTEL_CG',
            defaults={
                'nom': 'Airtel Money Congo',
                'type_service': 'AIRTEL_MONEY',
                'frais_percentage': Decimal('2.2'),
                'frais_min': Decimal('600'),
                'frais_max': Decimal('4500'),
                'limite_min': Decimal('1000'),
                'limite_max': Decimal('400000'),
                'regex_telephone': r'^\+243(99|90|91|92|93|94|95|96|97|98)\d{7}$'
            }
        )
        
        # ===== SERVICES MALI =====
        ServicePaiementInternational.objects.get_or_create(
            pays=mali,
            code_service='OM_ML',
            defaults={
                'nom': 'Orange Money Mali',
                'type_service': 'ORANGE_MONEY',
                'frais_percentage': Decimal('1.8'),
                'frais_min': Decimal('100'),
                'frais_max': Decimal('3000'),
                'limite_min': Decimal('200'),
                'limite_max': Decimal('300000'),
                'regex_telephone': r'^\+223(70|76|77|78|79)\d{6}$'
            }
        )
        
        # ===== CORRIDORS =====
        CorridorTransfert.objects.get_or_create(
            pays_origine=senegal,
            pays_destination=congo,
            defaults={
                'temps_livraison_min': 15,
                'temps_livraison_max': 45,
                'commission_percentage': Decimal('0.8'),
                'commission_fixe': Decimal('1000'),
                'montant_min_corridor': Decimal('10000'),
                'montant_max_corridor': Decimal('500000'),
                'taux_succes': Decimal('89.5')
            }
        )
        
        CorridorTransfert.objects.get_or_create(
            pays_origine=senegal,
            pays_destination=mali,
            defaults={
                'temps_livraison_min': 5,
                'temps_livraison_max': 20,
                'commission_percentage': Decimal('0.5'),
                'commission_fixe': Decimal('500'),
                'montant_min_corridor': Decimal('5000'),
                'montant_max_corridor': Decimal('300000'),
                'taux_succes': Decimal('95.2')
            }
        )
        
        self.stdout.write(
            self.style.SUCCESS('✅ Données internationales créées avec succès!')
        )
        self.stdout.write(
            self.style.SUCCESS('🌍 Pays: Sénégal, Congo, Mali')
        )
        self.stdout.write(
            self.style.SUCCESS('💳 Services: Wave, Orange Money, MTN, Airtel')
        )
        self.stdout.write(
            self.style.SUCCESS('🔄 Corridors: SEN→COG, SEN→MLI')
        )