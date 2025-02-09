import requests
import os
from dotenv import load_dotenv

class BuildingPopUps:
    def __init__(self):
        load_dotenv()
        self.API_KEY = os.getenv('GOOGLE_MAPS_API_KEY')
        
        if not self.API_KEY:
            raise ValueError("Google Maps API key is missing. Make sure it's set in the .env file.")
    
    def get_location_info(self, latitude, longitude, location_name):
        url = "https://maps.googleapis.com/maps/api/place/details/json"
        place_search_url = "https://maps.googleapis.com/maps/api/geocode/json"
        
        # Searching for place id based on coordinates
        search_params = {
            "latlng": f"{latitude},{longitude}",
            "key": self.API_KEY
        }
        search_response = requests.get(place_search_url, params=search_params)
        search_data = search_response.json()
        
        if not search_data.get("results"):
            raise ValueError("No results found for the given coordinates.")
        
        place_id = search_data["results"][0]["place_id"]
        
        # Fetching detailed information about the place
        params = {
            "place_id": place_id,
            "key": self.API_KEY,
            "fields": "formatted_phone_number,website,rating,opening_hours,types"
        }
        
        response = requests.get(url, params=params)
        data = response.json()
        result = data.get("result", {})
        
        # Collecting and returning location information
        location_info = {
            "name": location_name,
            "phone": result.get("formatted_phone_number"),
            "website": result.get("website"),
            "rating": result.get("rating"),
            "opening_hours": result.get("opening_hours", {}).get("weekday_text", []),
            "types": result.get("types", [])
        }
        
        print(f"Location Info for {location_name} ({latitude}, {longitude}):")
        print(location_info)
        
        return location_info


# Example of using the class
if __name__ == "__main__":
    building_popup = BuildingPopUps()
    location_name = "H Building, Concordia University"
    latitude = 45.4973223
    longitude = -73.5790288
    building_popup.get_location_info(latitude, longitude, location_name)
