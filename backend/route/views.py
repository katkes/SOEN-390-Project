from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from services.google_maps_service import GoogleMapsService
from backend.location.models import OutdoorLocation
# Create your views here.

@api_view(['POST'])
def get_outdoor_route(request):
    
    start_id = request.data.get('start_location')
    end_id = request.data.get('end_location')
    mode = request.data.get('mode')
    
    start_location = OutdoorLocation.objects.get(id=start_id)
    end_location = OutdoorLocation.objects.get(id=end_id)
    
    route_data = GoogleMapsService.get_outdoor_route(start_location.x, start_location.y, end_location.x, end_location.y, mode)
    
    if route_data:
        return Response({
            "distance": route_data["distance"]["text"],
            "duration": route_data["duration"]["text"],
            "steps": route_data["steps"]
        })
    else:
        return Response({
            "error": "Could not find route"
        }, status=400)