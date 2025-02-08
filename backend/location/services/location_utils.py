from django.apps import apps
from django.conf import settings
import requests
from django.contrib.gis.geos import Point

def get_start_location(start_location):
    """
    Determines the start location for routing.
    
    Args:
        start_location (int | dict): A Building ID, GPS coordinates, or a floor map coordinate.
    
    Returns:
        dict: Dictionary with latitude and longitude.
    """
    Building = apps.get_model("location", "Building")  # ✅ Load model dynamically

    if isinstance(start_location, int):  
        building = Building.objects.filter(id=start_location).first()
        if building:
            return {"latitude": building.latitude, "longitude": building.longitude}

    elif isinstance(start_location, dict):  
        if "latitude" in start_location and "longitude" in start_location:
            return start_location  

        elif "x" in start_location and "y" in start_location:
            point = Point(start_location["x"], start_location["y"])
            building = Building.objects.filter(boundary__contains=point).first()
            if building:
                return {"latitude": building.latitude, "longitude": building.longitude}
            return {"latitude": start_location["x"], "longitude": start_location["y"]}  

    return None  # Invalid format


def get_end_location(end_location):
    """
    Determines the end location for routing.

    Args:
        end_location (int | dict | str): Can be a Building ID, GPS coordinates, or an address.

    Returns:
        dict | None: Dictionary with latitude and longitude, or None if invalid.
    """
    Building = apps.get_model("location", "Building")  # ✅ Load model dynamically

    if isinstance(end_location, int):
        building = Building.objects.filter(id=end_location).first()
        if building:
            return {"latitude": building.latitude, "longitude": building.longitude}

    elif isinstance(end_location, dict):
        if "latitude" in end_location and "longitude" in end_location:
            return end_location  

    elif isinstance(end_location, str):
        return geocode_address(end_location)

    return None  # Invalid format


def geocode_address(address):
    """
    Converts an address into GPS coordinates using Google Maps API.

    Args:
        address (str): The address to be geocoded.

    Returns:
        dict | None: Dictionary with latitude and longitude, or None if invalid.
    """
    base_url = "https://maps.googleapis.com/maps/api/geocode/json"
    params = {"address": address, "key": settings.GOOGLE_MAPS_API_KEY}
    
    response = requests.get(base_url, params=params)
    data = response.json()

    if data["status"] == "OK":
        location = data["results"][0]["geometry"]["location"]
        return {"latitude": location["lat"], "longitude": location["lng"]}

    return None  # Address not found
