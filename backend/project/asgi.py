"""
ASGI config for project.

It exposes the ASGI callable as a module-level variable named `application`.
"""
import os

# Load environment variables
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "project.settings")

# ✅ Use the correct GDAL paths inside Docker
os.environ.setdefault("GDAL_LIBRARY_PATH", "/usr/lib/libgdal.so")
os.environ.setdefault("GEOS_LIBRARY_PATH", "/usr/lib/libgeos_c.so")


from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from project.routing import websocket_urlpatterns  # ✅ Import WebSocket routing

# ✅ Set up ASGI application with WebSockets
application = ProtocolTypeRouter(
    {
        "http": get_asgi_application(),
        "websocket": AuthMiddlewareStack(  # ✅ Allows authenticated WebSockets
            URLRouter(websocket_urlpatterns)
        ),
    }
)
