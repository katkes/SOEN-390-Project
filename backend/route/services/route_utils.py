from location.services.location_utils import get_start_location, get_end_location
from route.services.google_maps_service import GoogleMapsService

def get_route_data(start_location, end_location, mode):
    """
    Determines the correct start and end locations for routing,
    then fetches multiple possible routes using Google Maps.

    Args:
        start_location (int | dict): A Building ID, GPS coordinates, or floor map coordinate.
        end_location (int | dict | str): A Building ID, GPS coordinates, or address.
        mode (str): Mode of transportation (walking, driving).

    Returns:
        list | None: A list of possible routes if available, otherwise None.
    """
    start = get_start_location(start_location)  
    end = get_end_location(end_location)  

    if not start or not end:
        return None  # Invalid input

    return GoogleMapsService.get_outdoor_routes(start["latitude"], start["longitude"], end["latitude"], end["longitude"], mode)
