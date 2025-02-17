"""
Routing configuration for the WebSocket consumers.
"""

from django.urls import re_path
from route.services.consumers import LiveRouteConsumer

websocket_urlpatterns = [
    re_path(r"ws/routes/live/$", LiveRouteConsumer.as_asgi()),  # 🔥 WebSocket route
]
