import pytest
import json
from channels.testing import WebsocketCommunicator
from project.asgi import application

@pytest.mark.asyncio
async def test_websocket_connection():
    communicator = WebsocketCommunicator(application, "/ws/liveroute/")
    connected, _ = await communicator.connect()
    assert connected

    await communicator.send_json_to({"current_location": {"latitude": 45.5, "longitude": -73.5}, "end_location": "123 Main St", "mode": "walking"})
    response = await communicator.receive_json_from()
    
    assert "routes" in response or "error" in response

    await communicator.disconnect()
