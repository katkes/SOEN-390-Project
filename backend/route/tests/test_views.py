import pytest
import route  # Ensure app module is imported for coverage tracking

from rest_framework import status
from rest_framework.test import APIClient
from unittest.mock import patch


# Define pytest fixtures
@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def valid_data():
    return {
        "start_location": {"latitude": 40.7128, "longitude": -74.0060},
        "end_location": {"latitude": 34.0522, "longitude": -118.2437},
        "mode": "walking",
    }


@pytest.fixture
def invalid_data():
    return {
        "start_location": {"latitude": None, "longitude": None},
        "end_location": {"latitude": None, "longitude": None},
        "mode": "walking",
    }


@pytest.fixture
def mock_get_route_data():
    with patch("route.views.get_route_data") as mock:
        yield mock


# Test for a valid request with mocked data
@pytest.mark.django_db
def test_get_route_success(api_client, valid_data, mock_get_route_data):
    # Mock the route data
    mock_get_route_data.return_value = [
        {"distance": 1000, "duration": 10, "steps": []},
        {"distance": 1500, "duration": 15, "steps": []},
    ]

    # Corrected path to the API endpoint
    response = api_client.post("/api/routes/outdoor/", valid_data, format="json")

    # Validate response
    assert response.status_code == status.HTTP_200_OK
    assert "routes" in response.data
    assert len(response.data["routes"]) == 2  # Ensure two routes are returned


# Test for invalid request when no routes are found
@pytest.mark.django_db
def test_get_route_no_routes(api_client, valid_data, mock_get_route_data):
    # Mock no route data returned
    mock_get_route_data.return_value = None

    # Corrected path to the API endpoint
    response = api_client.post("/api/routes/outdoor/", valid_data, format="json")

    # Validate response
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert "error" in response.data
    assert response.data["error"] == "Could not find routes"


# Test for invalid request with missing or invalid data
@pytest.mark.django_db
def test_get_route_missing_data(api_client, invalid_data):
    # Corrected path to the API endpoint
    response = api_client.post("/api/routes/outdoor/", invalid_data, format="json")

    # Validate response
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert "error" in response.data
    assert response.data["error"] == "Could not find routes"
