"""
This module contains the views for the route app
"""
from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view
from rest_framework.response import Response
from route.services.route_utils import get_route_data

# pylint: disable=no-member


@api_view(["POST"])
def get_route(request):
    """
    Get multiple route options between two locations.
    
    Args:
        request (POST): The request object including:
            - "start_location": Can be a Building ID, GPS {"latitude", "longitude"}, or map {"x", "y"}.
            - "end_location": Can be a Building ID, GPS {"latitude", "longitude"}, or a string address.
            - "mode": Mode of transportation (walking, driving).

    Returns:
        Response: A JSON response containing multiple routes with distance, duration, and steps.
    """
    start_location = request.data.get("start_location")
    end_location = request.data.get("end_location")
    mode = request.data.get("mode", "walking")

    # Get multiple routes
    routes = get_route_data(start_location, end_location, mode)

    if routes:
        return Response({"routes": routes})  # ✅ Return multiple routes

    return Response({"error": "Could not find routes"}, status=400)