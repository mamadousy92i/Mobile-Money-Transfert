# transactions/management/commands/populate_10_countries.py - VERSION CORRIGÉE

from django.core.management.base import BaseCommand
from transactions.models import Pays, ServicePaiementInternational, CorridorTransfert, TauxChange
from decimal import Decimal
import logging

logger = logging.getLogger(__name__)

class Command(BaseCommand):
    help = 'Populate database with 10 countries and their payment services - FIXED VERSION'
    
    def handle(self, *args, **options):
        self.stdout.write("🌍 Expansion à 10 pays - DÉBUT (Version corrigée)...")
        
        try:
            # 1. Créer tous les pays
            pays_data = self.create_countries()
            
            # 2. Créer services de paiement par pays
            self.create_payment_services(pays_data)
            
            # 3. Créer tous les corridors depuis le Sénégal
            self.create_corridors(pays_data)
            
            # 4. Initialiser les taux de change
            self.create_exchange_rates()
            
            self.stdout.write(
                self.style.SUCCESS("✅ Expansion terminée ! 10 pays, 28+ services, 9 corridors")
            )
            
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f"❌ Erreur lors de l'expansion: {e}")
            )
            raise e
    
    def create_countries(self):
        """Créer ou mettre à jour les 10 pays - VERSION CORRIGÉE"""
        
        pays_config = [
            # Pays existants (mise à jour)
            {
                'code_iso': 'SEN', 'nom': 'Sénégal', 'devise': 'XOF', 
                'prefixe_tel': '+221', 'flag_emoji': '🇸🇳',
                'limite_envoi_min': 100, 'limite_envoi_max': 500000
            },
            {
                'code_iso': 'MLI', 'nom': 'Mali', 'devise': 'XOF',
                'prefixe_tel': '+223', 'flag_emoji': '🇲🇱',
                'limite_envoi_min': 500, 'limite_envoi_max': 400000
            },
            {
                'code_iso': 'COG', 'nom': 'Congo RDC', 'devise': 'CDF',
                'prefixe_tel': '+243', 'flag_emoji': '🇨🇩',
                'limite_envoi_min': 2000, 'limite_envoi_max': 800000
            },
            
            # NOUVEAUX PAYS (7)
            {
                'code_iso': 'CIV', 'nom': 'Côte d\'Ivoire', 'devise': 'XOF',
                'prefixe_tel': '+225', 'flag_emoji': '🇨🇮',
                'limite_envoi_min': 200, 'limite_envoi_max': 600000
            },
            {
                'code_iso': 'BFA', 'nom': 'Burkina Faso', 'devise': 'XOF',
                'prefixe_tel': '+226', 'flag_emoji': '🇧🇫',
                'limite_envoi_min': 300, 'limite_envoi_max': 300000
            },
            {
                'code_iso': 'GIN', 'nom': 'Guinée', 'devise': 'GNF',
                'prefixe_tel': '+224', 'flag_emoji': '🇬🇳',
                'limite_envoi_min': 5000, 'limite_envoi_max': 2000000  # GNF plus faible
            },
            {
                'code_iso': 'MAR', 'nom': 'Maroc', 'devise': 'MAD',
                'prefixe_tel': '+212', 'flag_emoji': '🇲🇦',
                'limite_envoi_min': 50, 'limite_envoi_max': 20000  # MAD plus fort
            },
            {
                'code_iso': 'CMR', 'nom': 'Cameroun', 'devise': 'XAF',
                'prefixe_tel': '+237', 'flag_emoji': '🇨🇲',
                'limite_envoi_min': 500, 'limite_envoi_max': 500000
            },
            {
                'code_iso': 'NGA', 'nom': 'Nigeria', 'devise': 'NGN',
                'prefixe_tel': '+234', 'flag_emoji': '🇳🇬',
                'limite_envoi_min': 1000, 'limite_envoi_max': 1000000
            },
            {
                'code_iso': 'GHA', 'nom': 'Ghana', 'devise': 'GHS',
                'prefixe_tel': '+233', 'flag_emoji': '🇬🇭',
                'limite_envoi_min': 20, 'limite_envoi_max': 50000
            },
        ]
        
        pays_objects = {}
        
        for pays_info in pays_config:
            try:
                pays, created = Pays.objects.update_or_create(
                    code_iso=pays_info['code_iso'],
                    defaults=pays_info
                )
                pays_objects[pays_info['code_iso']] = pays
                
                status = "✅ Créé" if created else "🔄 Mis à jour"
                self.stdout.write(f"{status} {pays_info['flag_emoji']} {pays_info['nom']}")
                
            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(f"❌ Erreur pour {pays_info['nom']}: {e}")
                )
                # Continuer même si un pays échoue
                continue
        
        return pays_objects
    
    def create_payment_services(self, pays_objects):
        """Créer services de paiement pour chaque pays"""
        
        services_config = [
            # SÉNÉGAL (Base)
            {
                'pays': 'SEN', 'nom': 'Wave Sénégal', 'type': 'WAVE', 'code': 'WAVE_SN',
                'frais_pct': 1.0, 'frais_fixe': 0, 'frais_min': 25, 'frais_max': 1500,
                'limite_min': 100, 'limite_max': 500000,
                'regex': r'^(\+221|221)?(77|78|70|76|75)\d{7}$'
            },
            {
                'pays': 'SEN', 'nom': 'Orange Money Sénégal', 'type': 'ORANGE_MONEY', 'code': 'OM_SN',
                'frais_pct': 1.5, 'frais_fixe': 50, 'frais_min': 100, 'frais_max': 2000,
                'limite_min': 500, 'limite_max': 750000,
                'regex': r'^(\+221|221)?(77|78|70|76|75)\d{7}$'
            },
            
            # MALI
            {
                'pays': 'MLI', 'nom': 'Orange Money Mali', 'type': 'ORANGE_MONEY', 'code': 'OM_ML',
                'frais_pct': 1.8, 'frais_fixe': 100, 'frais_min': 150, 'frais_max': 2500,
                'limite_min': 500, 'limite_max': 400000,
                'regex': r'^(\+223|223)?(70|76|77|78|79)\d{6}$'
            },
            
            # CONGO RDC
            {
                'pays': 'COG', 'nom': 'MTN Money Congo', 'type': 'MTN_MONEY', 'code': 'MTN_CG',
                'frais_pct': 2.2, 'frais_fixe': 500, 'frais_min': 800, 'frais_max': 15000,
                'limite_min': 2000, 'limite_max': 800000,
                'regex': r'^(\+243|243)?(81|82|83|84|85|89)\d{7}$'
            },
            
            # CÔTE D'IVOIRE
            {
                'pays': 'CIV', 'nom': 'Orange Money Côte d\'Ivoire', 'type': 'ORANGE_MONEY', 'code': 'OM_CI',
                'frais_pct': 1.6, 'frais_fixe': 60, 'frais_min': 120, 'frais_max': 3000,
                'limite_min': 200, 'limite_max': 600000,
                'regex': r'^(\+225|225)?(07|08|09|01|02|03)\d{8}$'
            },
            
            # BURKINA FASO
            {
                'pays': 'BFA', 'nom': 'Orange Money Burkina', 'type': 'ORANGE_MONEY', 'code': 'OM_BF',
                'frais_pct': 2.1, 'frais_fixe': 50, 'frais_min': 80, 'frais_max': 1500,
                'limite_min': 300, 'limite_max': 300000,
                'regex': r'^(\+226|226)?(70|71|72|73|76|77|78)\d{6}$'
            },
            
            # GUINÉE
            {
                'pays': 'GIN', 'nom': 'MTN Money Guinée', 'type': 'MTN_MONEY', 'code': 'MTN_GN',
                'frais_pct': 2.0, 'frais_fixe': 2000, 'frais_min': 5000, 'frais_max': 50000,
                'limite_min': 5000, 'limite_max': 2000000,
                'regex': r'^(\+224|224)?(62|65|66|67)\d{7}$'
            },
            
            # MAROC
            {
                'pays': 'MAR', 'nom': 'Orange Money Maroc', 'type': 'ORANGE_MONEY', 'code': 'OM_MA',
                'frais_pct': 1.2, 'frais_fixe': 5, 'frais_min': 10, 'frais_max': 200,
                'limite_min': 50, 'limite_max': 20000,
                'regex': r'^(\+212|212)?(6|7)\d{8}$'
            },
            
            # CAMEROUN
            {
                'pays': 'CMR', 'nom': 'MTN Money Cameroun', 'type': 'MTN_MONEY', 'code': 'MTN_CM',
                'frais_pct': 1.8, 'frais_fixe': 200, 'frais_min': 400, 'frais_max': 8000,
                'limite_min': 500, 'limite_max': 500000,
                'regex': r'^(\+237|237)?(67|68|69|65|66)\d{7}$'
            },
            
            # NIGERIA
            {
                'pays': 'NGA', 'nom': 'MTN Nigeria', 'type': 'MTN_MONEY', 'code': 'MTN_NG',
                'frais_pct': 1.5, 'frais_fixe': 100, 'frais_min': 200, 'frais_max': 5000,
                'limite_min': 1000, 'limite_max': 1000000,
                'regex': r'^(\+234|234)?(703|706|803|806|810|813|814|816|903|906)\d{7}$'
            },
            
            # GHANA
            {
                'pays': 'GHA', 'nom': 'MTN Money Ghana', 'type': 'MTN_MONEY', 'code': 'MTN_GH',
                'frais_pct': 1.4, 'frais_fixe': 5, 'frais_min': 10, 'frais_max': 500,
                'limite_min': 20, 'limite_max': 50000,
                'regex': r'^(\+233|233)?(24|25|53|54|55|59)\d{7}$'
            },
        ]
        
        # Créer les services
        for service_info in services_config:
            try:
                if service_info['pays'] not in pays_objects:
                    self.stdout.write(f"⚠️ Pays {service_info['pays']} non trouvé, skip service {service_info['nom']}")
                    continue
                
                pays = pays_objects[service_info['pays']]
                
                service, created = ServicePaiementInternational.objects.update_or_create(
                    pays=pays,
                    code_service=service_info['code'],
                    defaults={
                        'nom': service_info['nom'],
                        'type_service': service_info['type'],
                        'frais_percentage': Decimal(str(service_info['frais_pct'])),
                        'frais_fixe': Decimal(str(service_info['frais_fixe'])),
                        'frais_min': Decimal(str(service_info['frais_min'])),
                        'frais_max': Decimal(str(service_info['frais_max'])),
                        'limite_min': Decimal(str(service_info['limite_min'])),
                        'limite_max': Decimal(str(service_info['limite_max'])),
                        'regex_telephone': service_info['regex'],
                        'is_active': True
                    }
                )
                
                status = "✅ Créé" if created else "🔄 Mis à jour"
                self.stdout.write(f"  {status} {service_info['nom']}")
                
            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(f"❌ Erreur service {service_info['nom']}: {e}")
                )
                continue
    
    def create_corridors(self, pays_objects):
        """Créer corridors depuis Sénégal vers les autres pays"""
        
        if 'SEN' not in pays_objects:
            self.stdout.write(self.style.ERROR("❌ Sénégal non trouvé, impossible de créer les corridors"))
            return
        
        senegal = pays_objects['SEN']
        
        corridors_config = [
            # Corridors existants (mise à jour)
            {'dest': 'MLI', 'commission_pct': 0.5, 'commission_fixe': 500, 'temps_min': 5, 'temps_max': 20, 'min_amt': 500, 'max_amt': 400000},
            {'dest': 'COG', 'commission_pct': 0.8, 'commission_fixe': 1000, 'temps_min': 15, 'temps_max': 45, 'min_amt': 2000, 'max_amt': 300000},
            
            # NOUVEAUX CORRIDORS (7)
            {'dest': 'CIV', 'commission_pct': 0.4, 'commission_fixe': 300, 'temps_min': 3, 'temps_max': 15, 'min_amt': 200, 'max_amt': 500000},
            {'dest': 'BFA', 'commission_pct': 0.6, 'commission_fixe': 400, 'temps_min': 8, 'temps_max': 25, 'min_amt': 300, 'max_amt': 250000},
            {'dest': 'GIN', 'commission_pct': 1.2, 'commission_fixe': 2000, 'temps_min': 20, 'temps_max': 60, 'min_amt': 5000, 'max_amt': 200000},
            {'dest': 'MAR', 'commission_pct': 1.5, 'commission_fixe': 50, 'temps_min': 30, 'temps_max': 120, 'min_amt': 1000, 'max_amt': 100000},
            {'dest': 'CMR', 'commission_pct': 1.0, 'commission_fixe': 800, 'temps_min': 25, 'temps_max': 90, 'min_amt': 1000, 'max_amt': 400000},
            {'dest': 'NGA', 'commission_pct': 1.3, 'commission_fixe': 1500, 'temps_min': 20, 'temps_max': 75, 'min_amt': 2000, 'max_amt': 500000},
            {'dest': 'GHA', 'commission_pct': 1.1, 'commission_fixe': 200, 'temps_min': 15, 'temps_max': 50, 'min_amt': 500, 'max_amt': 150000},
        ]
        
        for corridor_info in corridors_config:
            try:
                if corridor_info['dest'] not in pays_objects:
                    self.stdout.write(f"⚠️ Pays destination {corridor_info['dest']} non trouvé, skip corridor")
                    continue
                
                destination = pays_objects[corridor_info['dest']]
                
                corridor, created = CorridorTransfert.objects.update_or_create(
                    pays_origine=senegal,
                    pays_destination=destination,
                    defaults={
                        'commission_percentage': Decimal(str(corridor_info['commission_pct'])),
                        'commission_fixe': Decimal(str(corridor_info['commission_fixe'])),
                        'temps_livraison_min': corridor_info['temps_min'],
                        'temps_livraison_max': corridor_info['temps_max'],
                        'montant_min_corridor': Decimal(str(corridor_info['min_amt'])),
                        'montant_max_corridor': Decimal(str(corridor_info['max_amt'])),
                        'is_active': True,
                        'taux_succes': Decimal('95.0'),
                        'nb_transactions': 0,
                        'volume_total': Decimal('0.00')
                    }
                )
                
                status = "✅ Créé" if created else "🔄 Mis à jour"
                self.stdout.write(f"  {status} Corridor SEN → {corridor_info['dest']}")
                
            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(f"❌ Erreur corridor SEN → {corridor_info['dest']}: {e}")
                )
                continue
    
    def create_exchange_rates(self):
        """Initialiser les taux de change de base"""
        
        # Taux depuis XOF (base Sénégal)
        taux_config = [
            {'origine': 'XOF', 'dest': 'XOF', 'taux': 1.0},  # Identique (Mali, Burkina, Côte d'Ivoire)
            {'origine': 'XOF', 'dest': 'CDF', 'taux': 3.8},  # Congo
            {'origine': 'XOF', 'dest': 'GNF', 'taux': 15.2}, # Guinée
            {'origine': 'XOF', 'dest': 'MAD', 'taux': 0.017}, # Maroc
            {'origine': 'XOF', 'dest': 'XAF', 'taux': 1.0},  # Cameroun (parité officielle)
            {'origine': 'XOF', 'dest': 'NGN', 'taux': 1.8},  # Nigeria
            {'origine': 'XOF', 'dest': 'GHS', 'taux': 0.024}, # Ghana
        ]
        
        for taux_info in taux_config:
            try:
                taux = Decimal(str(taux_info['taux']))
                taux_inverse = Decimal('1') / taux if taux != 0 else Decimal('1')
                
                taux_obj, created = TauxChange.objects.update_or_create(
                    devise_origine=taux_info['origine'],
                    devise_destination=taux_info['dest'],
                    defaults={
                        'taux': taux,
                        'taux_inverse': taux_inverse,
                        'source': 'manual_init',
                        'is_active': True,
                        'marge_achat': Decimal('0.02'),
                        'marge_vente': Decimal('0.02')
                    }
                )
                
                status = "✅ Créé" if created else "🔄 Mis à jour"
                self.stdout.write(f"  {status} Taux {taux_info['origine']} → {taux_info['dest']}: {taux}")
                
            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(f"❌ Erreur taux {taux_info['origine']} → {taux_info['dest']}: {e}")
                )
                continue