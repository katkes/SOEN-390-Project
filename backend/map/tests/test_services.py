from pathlib import Path

from map.services.campus_import import import_campus_boundaries
import pytest


@pytest.mark.django_db
@pytest.mark.skip
def test_import_campus_boundaries(caplog):
    geojson_file = Path(__file__).parent.parent.parent / "geojson_files" / "campus.geojson"
    result = import_campus_boundaries(geojson_file)

    assert result["imported"] == 1
    assert "Imported campus: Test Campus" in caplog.text
