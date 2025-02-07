# pylint: skip-file
import json
from django.contrib.gis.geos import GEOSGeometry
from map.models import CampusMap

def import_campus_boundaries(geojson_file):
    """Imports campus boundaries from a GeoJSON file."""
    with open(geojson_file, 'r') as file:
        data = json.load(file)
        for feature in data['features']:
            campus_name = feature['properties']['Campus']  # Use "Campus" instead of "name"
            geometry = GEOSGeometry(json.dumps(feature['geometry']))  # Handles MultiPolygon

            # Create or update the campus boundary
            CampusMap.objects.update_or_create(name=campus_name, defaults={'boundary': geometry})
            print(f"Imported campus: {campus_name}")

