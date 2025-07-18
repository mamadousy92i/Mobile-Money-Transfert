# Generated by Django 5.2.3 on 2025-07-14 09:43

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='KYCDocument',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('document_type', models.CharField(choices=[('CNI', "Carte Nationale d'Identité"), ('PASSPORT', 'Passeport')], max_length=10, verbose_name='Type de Document')),
                ('document_number', models.CharField(max_length=50, verbose_name='Numéro de Document')),
                ('document_image', models.ImageField(upload_to='kyc_docs/', verbose_name='Image du Document')),
                ('status', models.CharField(choices=[('PENDING', 'En attente'), ('VERIFIED', 'Vérifié'), ('REJECTED', 'Rejeté')], default='PENDING', max_length=10, verbose_name='Statut')),
                ('submitted_at', models.DateTimeField(auto_now_add=True, verbose_name='Soumis le')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='kyc_documents', to=settings.AUTH_USER_MODEL, verbose_name='Utilisateur')),
            ],
            options={
                'verbose_name': 'Document KYC',
                'verbose_name_plural': 'Documents KYC',
                'ordering': ['-submitted_at'],
            },
        ),
    ]
