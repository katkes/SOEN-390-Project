import requests
import time
import json
from typing import Dict, List, Optional
import pandas as pandas
from datetime import datetime
from dotenv import load_dotenv
import os

class BuildingPopUpInfoCollector:
    def __init__(self, api_key: str):
        """Initialize collector with Google API key"""
        self.api_key = api_key
        self.base_url = "https://maps.googleapis.com/maps/api/place"

    def find_place_by_address(self, address: str) -> Optional[Dict]:
        """
        Find a specific place using its address

        The Find Place endpoint is optimized for finding exact matches and uses Google's text 
        search capabilities to handle variations in address format.

        Args: 
            address: Complete address of the building
        
        Returns: 
            Dictionary containing place id
        """
        find_place_params = {
            'input': address,
            'inputtype': 'textquery',
            'fields': 'place_id',
            'key': self.api_key
        }

        url = f"{self.base_url}/findplacefromtext/json"

        try: 
            response = requests.get(url, params=find_place_params)
            response.raise_for_status()
            candidates = response.json().get('candidates', [])

            if not candidates:
                print(f"No exact match found for address: {address}")
                return None
            
            if candidates:
                return candidates[0].get("place_id")

        except requests.exceptions.RequestException as e:
            print(f"Error during address search: {e}")
            return None
        
    def get_place_details(self, place_id: str) -> Optional[Dict]:
        """
        Get detailed information about a specific place.

        Args:
            place_id: The Google Places ID for the location

        Returns: 
            Dictionary containing information that will be found in pop up
        """

        params = {
            'place_id': place_id,
            'fields': 'formatted_phone_number,website,rating,opening_hours',
            'key': self.api_key
        }

        url = f"{self.base_url}/details/json"

        try:
            response = requests.get(url, params=params)
            response.raise_for_status()
            result = response.json().get('result', {})

            building_info = {
                'phone': result.get('formatted_phone_number'),
                'website': result.get('website'),
                'rating': result.get('rating'),
                'opening_hours': result.get('opening_hours', {}).get('weekday_text', []),
                'types': result.get('types', [])
            }

            return building_info
        
        except requests.exceptions.RequestException as e:
            print(f"Error fetching details for place {place_id}: {e}")
            return None

    def process_building_list(self) -> List[str]:
        """
        Process a list of buildings using either their addresses or coordinates.

        Returns:
            List of strings representing the address of each buildings
        """
        with open('../../geojson_files/building_list.geojson', 'r') as file:
            data = json.loads(file)
            buildings = data['features']
            addresses = []
            for building in buildings:
                addresses.append(building['properties']['Address'] + ", Montreal")
            return addresses


# Quick Test
if __name__ == "__main__":

    load_dotenv()
    api_key = os.getenv("GOOGLE_PLACES_API_KEY")

    collector = BuildingPopUpInfoCollector(api_key)

    # Test address lookup
    test_address = "1455 DeMaisonneuve W, Montreal"
    place_id = collector.find_place_by_address(test_address)
    print(f"Place ID: {place_id}")

