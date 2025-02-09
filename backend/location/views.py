import os
import json
from django.http import JsonResponse, HttpResponse
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt
from django.contrib.gis.geos import MultiPolygon, Polygon

# Path to the geojson file
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GEOJSON_FILE = os.path.join(BASE_DIR, "geojson_files", "campus.geojson")

print(GEOJSON_FILE)


def load_geojson():
    """Load the campus.geojson file."""
    with open(GEOJSON_FILE, "r") as f:
        return json.load(f)


def save_geojson(data):
    """Save data to the campus.geojson file."""
    with open(GEOJSON_FILE, "w") as f:
        json.dump(data, f, indent=4)


def campus_list(request):
    """
    Retrieve all campuses from the geojson file.
    """
    if request.method == "GET":
        data = load_geojson()
        return JsonResponse(data, safe=False)


def campus_detail(request, campus_id):
    """
    Retrieve a specific campus by ID.
    """
    data = load_geojson()
    features = data.get("features", [])
    campus = next((f for f in features if f["properties"]["id"] == campus_id), None)

    if not campus:
        return JsonResponse({"error": "Campus not found."}, status=404)

    return JsonResponse(campus, safe=False)


@csrf_exempt
def create_campus(request):
    """
    Create a new campus and add it to the geojson file.
    """
    if request.method == "POST":
        try:
            new_campus = json.loads(request.body)
            data = load_geojson()
            new_id = max(f["properties"]["id"] for f in data["features"]) + 1 if data["features"] else 1
            new_campus["properties"]["id"] = new_id  # Assign a new unique ID
            data["features"].append(new_campus)
            save_geojson(data)
            return JsonResponse(new_campus, status=201)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)


@csrf_exempt
def update_campus(request, campus_id):
    """
    Update an existing campus in the geojson file.
    """
    if request.method == "PUT":
        try:
            updated_campus = json.loads(request.body)
            data = load_geojson()
            features = data.get("features", [])
            campus = next((f for f in features if f["properties"]["id"] == campus_id), None)

            if not campus:
                return JsonResponse({"error": "Campus not found."}, status=404)

            # Update the campus data
            campus["properties"].update(updated_campus.get("properties", {}))
            campus["geometry"] = updated_campus.get("geometry", campus["geometry"])
            save_geojson(data)

            return JsonResponse(campus, status=200)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)


@csrf_exempt
def delete_campus(request, campus_id):
    """
    Delete a campus from the geojson file.
    """
    if request.method == "DELETE":
        try:
            data = load_geojson()
            features = data.get("features", [])
            updated_features = [f for f in features if f["properties"]["id"] != campus_id]

            if len(features) == len(updated_features):
                return JsonResponse({"error": "Campus not found."}, status=404)

            data["features"] = updated_features
            save_geojson(data)

            return HttpResponse(status=204)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)
