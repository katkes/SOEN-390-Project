import pytest
from rest_framework.test import APIClient

@pytest.mark.django_db
def test_get_route_valid():
    client = APIClient()
    data = {
        "start_location": {"latitude": 45.5, "longitude": -73.5},
        "end_location": "123 Main St, New York, NY",
        "mode": "walking"
    }
    response = client.post("/api/route/", data, format="json")
    assert response.status_code == 200
    assert "routes" in response.data

@pytest.mark.django_db
def test_get_route_invalid():
    client = APIClient()
    data = {
        "start_location": {"latitude": 45.5, "longitude": -73.5},
        "end_location": "",  # Invalid address
        "mode": "walking"
    }
    response = client.post("/api/route/", data, format="json")
    assert response.status_code == 400
    assert "error" in response.data
