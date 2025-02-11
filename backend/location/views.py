"""
Views for the location app.

This module provides CRUD operations for managing campus locations stored in a GeoJSON file.
"""

import os
import json
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.gis.geos import MultiPolygon, Polygon

# Path to the geojson file
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GEOJSON_FILE_PATH = os.path.join(BASE_DIR, "geojson_files", "campus.geojson")


def load_geojson():
    """Load the campus.geojson file."""
    try:
        with open(GEOJSON_FILE_PATH, "r", encoding="utf-8") as file:
            return json.load(file)
    except (FileNotFoundError, json.JSONDecodeError) as error:
        return {"error": f"Error loading GeoJSON file: {str(error)}"}


def save_geojson(data):
    """Save data to the campus.geojson file."""
    try:
        with open(GEOJSON_FILE_PATH, "w", encoding="utf-8") as file:
            json.dump(data, file, indent=4)
    except OSError as error:
        return {"error": f"Error saving GeoJSON file: {str(error)}"}


def campus_list(request):
    """
    Retrieve all campuses from the geojson file.
    """
    if request.method == "GET":
        data = load_geojson()
        if "error" in data:
            return JsonResponse(data, status=500)
        return JsonResponse(data, safe=False)
    return JsonResponse({"error": "Invalid HTTP method."}, status=405)


def campus_detail(request, campus_id):
    """
    Retrieve a specific campus by ID.
    """
    if request.method == "GET":
        data = load_geojson()
        if "error" in data:
            return JsonResponse(data, status=500)

        features = data.get("features", [])
        campus = next(
            (
                feature
                for feature in features
                if feature["properties"]["id"] == campus_id
            ),
            None,
        )

        if not campus:
            return JsonResponse({"error": "Campus not found."}, status=404)

        return JsonResponse(campus, safe=False)

    return JsonResponse({"error": "Invalid HTTP method."}, status=405)


@csrf_exempt
def create_campus(request):
    """
    Create a new campus and add it to the geojson file.
    """
    if request.method == "POST":
        try:
            new_campus = json.loads(request.body)
            data = load_geojson()
            if "error" in data:
                return JsonResponse(data, status=500)

            new_id = (
                max(
                    (feature["properties"]["id"] for feature in data["features"]),
                    default=0,
                )
                + 1
            )
            new_campus["properties"]["id"] = new_id  # Assign a new unique ID

            data["features"].append(new_campus)
            save_geojson(data)

            return JsonResponse(new_campus, status=201)
        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format."}, status=400)
        except KeyError as key_error:
            return JsonResponse({"error": f"Missing key: {str(key_error)}"}, status=400)
        except OSError as os_error:
            return JsonResponse({"error": f"File error: {str(os_error)}"}, status=500)

    return JsonResponse({"error": "Invalid HTTP method."}, status=405)


@csrf_exempt
def update_campus(request, campus_id):
    """
    Update an existing campus in the geojson file.
    """
    if request.method == "PUT":
        try:
            updated_campus = json.loads(request.body)
            data = load_geojson()
            if "error" in data:
                return JsonResponse(data, status=500)

            features = data.get("features", [])
            campus = next(
                (
                    feature
                    for feature in features
                    if feature["properties"]["id"] == campus_id
                ),
                None,
            )

            if not campus:
                return JsonResponse({"error": "Campus not found."}, status=404)

            # Update the campus data
            campus["properties"].update(updated_campus.get("properties", {}))
            campus["geometry"] = updated_campus.get("geometry", campus["geometry"])
            save_geojson(data)

            return JsonResponse(campus, status=200)
        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format."}, status=400)
        except KeyError as key_error:
            return JsonResponse({"error": f"Missing key: {str(key_error)}"}, status=400)
        except OSError as os_error:
            return JsonResponse({"error": f"File error: {str(os_error)}"}, status=500)

    return JsonResponse({"error": "Invalid HTTP method."}, status=405)


@csrf_exempt
def delete_campus(request, campus_id):
    """
    Delete a campus from the geojson file.
    """
    if request.method == "DELETE":
        try:
            data = load_geojson()
            if "error" in data:
                return JsonResponse(data, status=500)

            features = data.get("features", [])
            updated_features = [
                feature
                for feature in features
                if feature["properties"]["id"] != campus_id
            ]

            if len(features) == len(updated_features):
                return JsonResponse({"error": "Campus not found."}, status=404)

            data["features"] = updated_features
            save_geojson(data)

            return HttpResponse(status=204)
        except OSError as os_error:
            return JsonResponse({"error": f"File error: {str(os_error)}"}, status=500)

    return JsonResponse({"error": "Invalid HTTP method."}, status=405)
