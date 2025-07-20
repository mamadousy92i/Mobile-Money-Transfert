from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Q
from math import cos, radians
from .models import AgentLocal
from .serializers import AgentLocalSerializer

class AgentLocalViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = AgentLocal.objects.all()
    serializer_class = AgentLocalSerializer
     
    def get_queryset(self):
        queryset = AgentLocal.objects.filter(statut_agent='ACTIF')
        
        # Filtrage par proximité
        lat = self.request.query_params.get('lat')
        lon = self.request.query_params.get('lon')
        radius = self.request.query_params.get('radius', 10)
        
        if lat and lon:
            lat_range = float(radius) / 111
            lon_range = float(radius) / (111 * cos(radians(float(lat))))
            
            queryset = queryset.filter(
                latitude__range=[float(lat) - lat_range, float(lat) + lat_range],
                longitude__range=[float(lon) - lon_range, float(lon) + lon_range]
            )
        
        # Filtrage par recherche
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(nom__icontains=search) |
                Q(prenom__icontains=search) |
                Q(adresse__icontains=search)
            )
        
        return queryset.order_by('nom')