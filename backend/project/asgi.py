"""
ASGI config for project.

It exposes the ASGI callable as a module-level variable named `application`.
"""

import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from project.routing import websocket_urlpatterns  # ✅ Import WebSocket routing

# ✅ Load environment variables before initializing Django settings
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "project.settings")

# ✅ Use the correct GDAL paths inside Docker
os.environ.setdefault("GDAL_LIBRARY_PATH", "/usr/lib/libgdal.so")
os.environ.setdefault("GEOS_LIBRARY_PATH", "/usr/lib/libgeos_c.so")

# ✅ Set up ASGI application with WebSockets
application = ProtocolTypeRouter(
    {
        "http": get_asgi_application(),
        "websocket": AuthMiddlewareStack(  # ✅ Allows authenticated WebSockets
            URLRouter(websocket_urlpatterns)
        ),
    }
)
