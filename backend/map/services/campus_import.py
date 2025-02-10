# pylint: skip-file
from io import TextIOWrapper
import json
from django.contrib.gis.geos import GEOSGeometry
from pytest import deprecated_call
from map.models import CampusMap
import logging
from pathlib import Path

logger = logging.getLogger(__name__)





# @deprecated_call
def import_campus_boundaries(geojson_file: Path) -> dict:
    """Imports campus boundaries from a GeoJSON file."""
    with open(geojson_file, "r") as file:
        return import_campus_boundaries_new(file)

def import_campus_boundaries_new(geojson_file: TextIOWrapper) -> dict:
    """Imports campus boundaries from a GeoJSON file-like object.

    :param geojson_file: file path to the GeoJSON file
    :raises ValueError: if the GeoJSON is invalid
    :return: dictionary containing the number of imported and skipped campus boundaries
    """
    imported_count = 0
    skipped_count = 0

    try:
        data = json.load(geojson_file)
        if "features" not in data:
            raise ValueError("Invalid GeoJSON: Missing 'features' key")

        for feature in data["features"]:
            campus_name = feature["properties"].get("Campus")
            if not campus_name:
                skipped_count += 1
                logger.warning("Skipping feature with missing campus name")
                continue

            geometry = GEOSGeometry(json.dumps(feature.get("geometry", {})))

            CampusMap.objects.update_or_create(
                name=campus_name, defaults={"boundary": geometry}
            )
            imported_count += 1
            logger.info(f"Imported campus: {campus_name}")

        return {"imported": imported_count, "skipped": skipped_count}

    except (json.JSONDecodeError, KeyError, TypeError, ValueError) as e:
        logger.error(f"Error importing campus boundaries: {e}")
        return {"error": str(e)}

    except FileNotFoundError as e:
        logger.error(f"File not found: {e}")
        return {"error": str(e)}

