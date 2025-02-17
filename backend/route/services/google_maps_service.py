"""
This module provides a service to interact with Google Maps API
for retrieving outdoor route directions.
"""

import requests
from django.conf import settings


class GoogleMapsService:
    """
    Service class to interact with Google Maps API
    for retrieving outdoor route directions.
    Returns:
        _type_: _description_
    """

    @staticmethod
    def get_outdoor_routes(start_lat, start_long, end_lat, end_long, mode):
        """
        Fetches an outdoor route from Google Maps API.

        Args:
            start_lat (float): Latitude of the start location.
            start_long (float): Longitude of the start location.
            end_lat (float): Latitude of the end location.
            end_long (float): Longitude of the end location.
            mode (str): Mode of transportation (walking, driving, etc.).

        Returns:
            dict | None: The route data if available, otherwise None.
        """

        base_url = "https://maps.googleapis.com/maps/api/directions/json"

        params = {
            "origin": f"{start_lat},{start_long}",
            "destination": f"{end_lat},{end_long}",
            "mode": f"{mode}",
            "alternatives": "true",
            "key": settings.GOOGLE_MAPS_API_KEY,
        }

        response = requests.get(base_url, params=params, timeout=10)
        data = response.json()

        if data["status"] == "OK":
            routes = []
            for route in data["routes"]:
                route_info = {
                    "distance": route["legs"][0]["distance"]["text"],
                    "duration": route["legs"][0]["duration"]["text"],
                    "steps": [
                        step["html_instructions"] for step in route["legs"][0]["steps"]
                    ],
                }
                routes.append(route_info)
            return routes
        return None
