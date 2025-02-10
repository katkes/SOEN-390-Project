from pathlib import Path

from map.services.campus_import import import_campus_boundaries
import pytest


# C:\Users\timam\Personal\University\multiclassrepo\Winter 2025\SOEN 390\SOEN-390-Project\backend\geojson_files\campus.geojson
@pytest.mark.django_db
def test_import_campus_boundaries(caplog):
    geojson_file = Path(__file__).parent.parent.parent / "geojson_files" / "campus.geojson"
    result = import_campus_boundaries(geojson_file)

    assert result["imported"] == 1
    assert "Imported campus: Test Campus" in caplog.text
