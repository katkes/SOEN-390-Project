import json
from channels.generic.websocket import AsyncWebsocketConsumer
from route.services.google_maps_service import GoogleMapsService
from django.apps import apps

class LiveRouteConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        """Accepts WebSocket connection for real-time route updates."""
        await self.accept()

    async def disconnect(self, close_code):
        """Handles disconnection."""
        pass

    async def receive(self, text_data):
        """Handles new GPS updates and sends updated route data."""
        data = json.loads(text_data)
        current_location = data.get("current_location")  # {"latitude": 45.5, "longitude": -73.5}
        end_location = data.get("end_location")  # Can be a building ID or an address
        mode = data.get("mode")

        if isinstance(end_location, str):
            from location.services.location_utils import geocode_address
            end_location = geocode_address(end_location)

        if not end_location:
            await self.send(text_data=json.dumps({"error": "Invalid destination"}))
            return

        route_data = GoogleMapsService.get_outdoor_routes(
            current_location["latitude"],
            current_location["longitude"],
            end_location["latitude"],
            end_location["longitude"],
            mode
        )

        if route_data:
            await self.send(text_data=json.dumps(route_data))
        else:
            await self.send(text_data=json.dumps({"error": "Could not find route"}))
