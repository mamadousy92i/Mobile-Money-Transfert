from rest_framework import serializers
from .models import AgentLocal
from math import radians, cos, sin, asin, sqrt

class AgentLocalSerializer(serializers.ModelSerializer):
    distance = serializers.SerializerMethodField()
    est_ouvert = serializers.ReadOnlyField()
    est_disponible = serializers.ReadOnlyField()
    nom_complet = serializers.SerializerMethodField()
    
    class Meta:
        model = AgentLocal
        fields = [
            'id', 'nom', 'prenom', 'telephone', 'email', 'adresse',
            'statut_agent', 'solde_compte', 'latitude', 'longitude',
            'heure_ouverture', 'heure_fermeture', 'limite_retrait_journalier',
            'commission_pourcentage', 'distance', 'est_ouvert', 'est_disponible',
            'nom_complet', 'date_creation'
        ]
        read_only_fields = ['solde_compte', 'date_creation']
    
    def get_nom_complet(self, obj):
        return f"{obj.prenom} {obj.nom}"
    
    def get_distance(self, obj):
        request = self.context.get('request')
        if not request:
            return None
            
        user_lat = request.query_params.get('lat')
        user_lon = request.query_params.get('lon')
        
        if not (user_lat and user_lon and obj.latitude and obj.longitude):
            return None
        
        return self.haversine_distance(
            float(user_lat), float(user_lon),
            float(obj.latitude), float(obj.longitude)
        )
    
    def haversine_distance(self, lat1, lon1, lat2, lon2):
        R = 6371  # Rayon de la Terre en km
        lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
        c = 2 * asin(sqrt(a))
        return round(R * c, 2)