"""
This file contains the tests for the location app.
"""

from django.test import TestCase
from unittest.mock import patch, Mock
from location.services.building_pop_ups import BuildingPopUps  # Adjust the import to your app structure


class BuildingPopUpsTestCase(TestCase):
    
    @patch('requests.get')
    def test_get_location_info_success(self, mock_get):
        mock_search_response = Mock()
        mock_search_response.json.return_value = {
            "results": [{"place_id": "1234"}]
        }
        
        mock_place_response = Mock()
        mock_place_response.json.return_value = {
            "result": {
                "formatted_phone_number": "+1 555-555-5555",
                "website": "https://example.com",
                "rating": 4.5,
                "opening_hours": {"weekday_text": ["Mon-Fri: 9 AM - 5 PM"]},
                "types": ["university", "building"]
            }
        }
        
        mock_get.side_effect = [mock_search_response, mock_place_response]
        
        building_popup = BuildingPopUps()
        
        location_name = "H Building, Concordia University"
        latitude = 45.4973223
        longitude = -73.5790288
        
        location_info = building_popup.get_location_info(latitude, longitude, location_name)
        
        
        #everything needs fixing below this 
        self.assertEqual(location_info['name'], location_name)
        self.assertEqual(location_info['phone'], "+1 555-555-5555")
        self.assertEqual(location_info['website'], "https://example.com")
        self.assertEqual(location_info['rating'], 4.5)
        self.assertEqual(location_info['opening_hours'], ["Mon-Fri: 9 AM - 5 PM"])
        self.assertIn("university", location_info['types'])
        self.assertIn("building", location_info['types'])

    @patch('requests.get')
    def test_get_location_info_no_results(self, mock_get):
        mock_search_response = Mock()
        mock_search_response.json.return_value = {
            "results": []
        }
        
        mock_get.side_effect = [mock_search_response]
        
        building_popup = BuildingPopUps()
        
        location_name = "H Building, Concordia University"
        latitude = 45.4973223
        longitude = -73.5790288
        
        with self.assertRaises(ValueError) as context:
            building_popup.get_location_info(latitude, longitude, location_name)
        
        self.assertEqual(str(context.exception), "No results found for the given coordinates.")
    
    @patch('requests.get')
    def test_get_location_info_missing_api_key(self, mock_get):
        with self.assertRaises(ValueError) as context:
            BuildingPopUps()
        
        self.assertEqual(str(context.exception), "Google Maps API key is missing. Make sure it's set in the .env file.")
