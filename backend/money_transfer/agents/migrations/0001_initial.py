# Generated by Django 5.2.3 on 2025-07-14 09:42

from decimal import Decimal
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='AgentLocal',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('nom', models.CharField(max_length=200)),
                ('prenom', models.CharField(max_length=200)),
                ('telephone', models.CharField(help_text="Numéro de téléphone professionnel de l'agent", max_length=15)),
                ('email', models.EmailField(help_text="Email professionnel de l'agent", max_length=254)),
                ('adresse', models.TextField(help_text='Adresse physique du point de retrait')),
                ('statut_agent', models.CharField(choices=[('ACTIF', 'Actif'), ('SUSPENDU', 'Suspendu'), ('INACTIF', 'Inactif')], default='ACTIF', max_length=10)),
                ('heure_ouverture', models.TimeField(default='08:00', help_text="Heure d'ouverture du point de retrait")),
                ('heure_fermeture', models.TimeField(default='18:00', help_text='Heure de fermeture du point de retrait')),
                ('latitude', models.DecimalField(blank=True, decimal_places=6, help_text='Latitude GPS du point de retrait', max_digits=9, null=True)),
                ('longitude', models.DecimalField(blank=True, decimal_places=6, help_text='Longitude GPS du point de retrait', max_digits=9, null=True)),
                ('solde_compte', models.DecimalField(decimal_places=2, default=Decimal('0.00'), help_text='Solde disponible pour les retraits', max_digits=15)),
                ('limite_retrait_journalier', models.DecimalField(decimal_places=2, default=Decimal('1000000.00'), help_text='Limite maximum de retraits par jour', max_digits=12)),
                ('commission_pourcentage', models.DecimalField(decimal_places=2, default=Decimal('2.0'), help_text='Commission en pourcentage sur les retraits', max_digits=5)),
                ('kyc_agent_verifie', models.BooleanField(default=False, help_text='KYC spécifique agent validé (licence, etc.)')),
                ('document_licence', models.FileField(blank=True, help_text='Document de licence commerciale', null=True, upload_to='agents_licences/')),
                ('date_creation', models.DateTimeField(auto_now_add=True)),
                ('date_modification', models.DateTimeField(auto_now=True)),
            ],
            options={
                'verbose_name': 'Agent Local',
                'verbose_name_plural': 'Agents Locaux',
                'db_table': 'agents_local',
                'ordering': ['-date_creation'],
            },
        ),
    ]
