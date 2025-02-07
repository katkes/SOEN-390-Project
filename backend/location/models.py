"""
    This file contains the models for the location app.
    which includes the following models:
    - Location: A generic model for locations
    - Building: A model for buildings
    - IndoorLocation: A model for indoor locations
    - Room: A model for rooms
    - IndoorPOI: A model for indoor Points of Interest
"""

from django.db import models
from django.contrib.gis.db import models as gis_models  # For spatial data
from django.apps import apps


# Create your models here.
class Location(models.Model):
    """
    a generic model for locations
    """

    name = models.CharField(max_length=255)


class Building(Location):
    """
    A model for buildings which inherits from the Location model
    includes the following fields:
    - campus_map: A foreign key to the CampusMap model
    - boundary: Building boundary as a polygon
    - num_floors: Number of floors in the building
    - long_name: The full name of the building
    - address: The address of the building
    - latitude: The latitude of the building
    - longitude: The longitude of the building
    """

    campus_map = models.ForeignKey(
        "map.CampusMap", on_delete=models.CASCADE, related_name="buildings"
    )
    boundary = gis_models.MultiPolygonField(
        null=True, blank=True
    )  # Allow nulls # Building boundary as a polygon
    num_floors = models.IntegerField(default=1)
    long_name = models.CharField(max_length=255)
    address = models.TextField(default="")
    latitude = models.FloatField()
    longitude = models.FloatField()

    def __str__(self):
        """
        Returns the string representation of the building
        Returns:
        - A string representation of the building
        """
        return f"Building: {self.name} (Campus: {self.campus_map.name})"


class IndoorLocation(Location):
    """
    A model for indoor locations which inherits from the Location model
    includes the following fields:
    - x: The x coordinate of the location
    - y: The y coordinate of the location
    - floor_map: A foreign key to the FloorMap model
    """

    x = models.IntegerField()
    y = models.IntegerField()
    floor_map = models.ForeignKey(
        "map.FloorMap", on_delete=models.CASCADE, related_name="indoor_location_set"
    )


class Room(IndoorLocation):
    """
    A model for rooms which inherits from the IndoorLocation model
    includes the following fields:
    - room_number: The room number
    - room_type: The type of the room
    """

    room_number = models.CharField(max_length=10)
    room_type = models.CharField(max_length=10)


class IndoorPOI(IndoorLocation):
    """
    a model for indoor Points of Interest which inherits from the IndoorLocation model
    includes the following fields:
    - is_accessible: A boolean field to indicate if the POI is accessible
    - poi_type: The type of the POI
    """

    is_accessible = models.BooleanField(default=True)
    poi_type = models.CharField(max_length=255)
