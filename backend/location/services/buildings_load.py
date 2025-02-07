# pylint: skip-file
import json
from django.contrib.gis.geos import GEOSGeometry, MultiPolygon, Polygon, Point
from map.models import CampusMap
from location.models import Building


def import_building_data(info_geojson_file, boundary_geojson_file):
    """Imports building data and assigns buildings to the correct campus and boundary."""

    # ✅ 1. Load GeoJSON safely
    try:
        with open(info_geojson_file, "r") as file:
            building_info_data = json.load(file)
        print(f"📂 Loaded building info from {info_geojson_file}")

        with open(boundary_geojson_file, "r") as file:
            boundary_data = json.load(file)
        print(f"📂 Loaded boundary info from {boundary_geojson_file}")

    except Exception as e:
        print(f"❌ Error loading files: {e}")
        return

    # ✅ 2. Convert boundaries to dictionary
    boundary_dict = {}
    for feature in boundary_data.get("features", []):
        boundary_id = feature["properties"].get("id")

        if boundary_id is None:
            print("⚠️ Warning: Found a boundary without an ID. Skipping.")
            continue

        try:
            boundary_geometry = GEOSGeometry(json.dumps(feature["geometry"]))

            # ✅ Fix invalid geometries
            if not boundary_geometry.valid:
                print(f"⚠️ Warning: Boundary {boundary_id} is invalid. Fixing...")
                boundary_geometry = boundary_geometry.buffer(0)

            # ✅ Ensure the boundary is always a MultiPolygon
            if boundary_geometry.geom_type == "Polygon":
                boundary_geometry = MultiPolygon(boundary_geometry)

            boundary_dict[boundary_id] = boundary_geometry
            print(f"🗺️ Loaded boundary {boundary_id} as {boundary_geometry.geom_type}")

        except Exception as e:
            print(f"❌ Error processing boundary {boundary_id}: {e}")
            continue

    # ✅ 3. Process each building in the dataset
    for feature in building_info_data.get("features", []):
        properties = feature.get("properties", {})
        building_id = properties.get("id")

        if building_id is None:
            print(f"⚠️ Warning: Found a building without an ID. Skipping.")
            continue

        # ✅ Extract coordinates correctly from `geometry`
        try:
            geometry = feature.get("geometry", {})
            if geometry.get("type") == "Point":
                longitude, latitude = geometry["coordinates"]
            else:
                print(
                    f"⚠️ Skipping {properties.get('Building', 'Unknown')} - Invalid geometry type: {geometry.get('type')}"
                )
                continue
        except Exception as e:
            print(f"❌ Error extracting coordinates: {e}")
            continue

        # Create a point for this building's location
        building_point = Point(longitude, latitude)
        assigned_campus = properties.get("Campus", "")
        assigned_boundary = boundary_dict.get(building_id)  # ✅ Get the boundary by ID

        # ✅ 4. If no boundary found, log it
        if assigned_boundary is None:
            print(
                f"⚠️ {properties.get('Building', 'Unknown')} at ({latitude}, {longitude}) does not have a matching boundary."
            )
            continue

        # ✅ 5. Get or create the Campus Map entry
        try:
            campus_map, _ = CampusMap.objects.get_or_create(name=assigned_campus)
        except Exception as e:
            print(f"❌ Error creating or retrieving campus {assigned_campus}: {e}")
            continue

        # ✅ 6. Create the Building entry with the boundary assigned
        try:
            new_building = Building.objects.create(
                name=properties.get("Building", ""),
                long_name=properties.get("Building Long Name", ""),
                address=properties.get("Address", ""),
                latitude=latitude,
                longitude=longitude,
                campus_map=campus_map,  # Assign campus
                boundary=assigned_boundary,  # ✅ Assign the MultiPolygon boundary
            )
            print(
                f"🏗️ Created Building ID {new_building.id}: {properties.get('Building Long Name', '')} in {assigned_campus}"
            )

        except Exception as e:
            print(f"❌ Error creating building {properties.get('Building', '')}: {e}")
