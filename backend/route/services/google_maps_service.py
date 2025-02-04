import requests
from django.conf import settings

class GoogleMapsService:
    
    @staticmethod
    def get_outdoor_route(start_lat, start_long, end_lat, end_long,mode):
        base_url = "https://maps.googleapis.com/maps/api/directions/json"
        
        params = {
            "origin": f"{start_lat},{start_long}",
            "destination": f"{end_lat},{end_long}",
            "mode": f"{mode}",
            "key": settings.GOOGLE_MAPS_API_KEY
        }
        
        response = requests.get(base_url, params=params)
        date = response.json()
        
        if data["status"] == "OK":
            return data["routes"][0]["legs"][0]
        else:
            return None