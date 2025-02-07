"""
This module contains the views for the route app
"""

from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from location.models import Building  # ✅ Correct import order
from .services.google_maps_service import GoogleMapsService

# pylint: disable=no-member

@api_view(['POST'])
def get_outdoor_route(request):
    """
    Get the outdoor route between two locations
    Args:
        request (POST): The request object including the start and end locations and the mode of transportation

    Returns:
        "Response": A JSON response containing the distance, duration and steps of the route
    """
    
    start_id = request.data.get('start_location')
    end_id = request.data.get('end_location')
    mode = request.data.get('mode')
    
    start_location = Building.objects.get(id=start_id)
    end_location = Building.objects.get(id=end_id)
    
    route_data = GoogleMapsService.get_outdoor_route(start_location.x, start_location.y, end_location.x, end_location.y, mode)
    
    if route_data:
        return Response({
            "distance": route_data["distance"]["text"],
            "duration": route_data["duration"]["text"],
            "steps": route_data["steps"]
        })
    return Response({
        "error": "Could not find route"
    }, status=400)