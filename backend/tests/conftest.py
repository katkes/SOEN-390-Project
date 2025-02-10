import sys
import pytest
from unittest.mock import MagicMock

@pytest.fixture(scope="session", autouse=True)
def disable_gis():
    """Mock django.contrib.gis modules to prevent GDAL from loading."""
    sys.modules["django.contrib.gis.gdal"] = MagicMock()
    sys.modules["django.contrib.gis.db"] = MagicMock()
    sys.modules["django.contrib.gis.db.models"] = MagicMock()

