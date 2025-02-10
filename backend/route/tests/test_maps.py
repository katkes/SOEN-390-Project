import pytest
import requests
from django.conf import settings
from route.services.google_maps_service import GoogleMapsService
from tests.conftest import disable_gis


@pytest.fixture
def mock_google_maps_api():
    """Mock Google Maps API response."""
    with requests_mock.Mocker() as m:
        mock_response = {
            "status": "OK",
            "routes": [
                {
                    "legs": [
                        {
                            "start_address": "Start Location",
                            "end_address": "End Location",
                            "distance": {"text": "5 km", "value": 5000},
                            "duration": {"text": "10 mins", "value": 600},
                        }
                    ]
                }
            ],
        }
        m.get("https://maps.googleapis.com/maps/api/directions/json", json=mock_response)
        yield m


@pytest.mark.django_db
def test_get_outdoor_route(mock_google_maps_api, disable_gis, settings):
    """Test fetching an outdoor route from Google Maps API."""

    # Mock API key for test environment
    settings.GOOGLE_MAPS_API_KEY = "fake-api-key"

    # Sample coordinates and mode
    start_lat, start_long = 40.712776, -74.005974
    end_lat, end_long = 34.052235, -118.243683
    mode = "driving"

    result = GoogleMapsService.get_outdoor_route(start_lat, start_long, end_lat, end_long, mode)

    # Assertions
    assert result is not None
    assert "distance" in result
    assert result["distance"]["text"] == "5 km"
    assert result["duration"]["text"] == "10 mins"

