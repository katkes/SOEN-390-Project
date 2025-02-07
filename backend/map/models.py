"""
This file contains the models for the map app.
"""

from django.db import models
from django.contrib.gis.db import models as gis_models
from django.apps import apps


# Create your models here.
class Map(models.Model):
    """
    Abstract class for all maps
    includes the following fields:
    - name: The name of the map
    """

    name = models.CharField(max_length=255)

    class Meta:
        """
        Meta class for the Map model
        """

        abstract = True


class CampusMap(Map):
    """
    Represents a campus map
    includes the following fields:
    - boundary: Campus boundary as a polygon

    Args:
        Map (_type_): _description_
    """

    boundary = gis_models.MultiPolygonField(null=True, blank=True)  # Allow nulls

    def __str__(self):
        """
        Returns the string representation of the campus map

        Returns:
            String: A string representation of the campus map
        """
        return f"{self.name} Campus Map"


class FloorMap(Map):
    """
    Represents a floor map
    includes the following fields:
    - building: A foreign key to the Building model
    - floor_number: The floor number
    - grid_width: The width of the grid
    - grid_height: The height of the grid

    Args:
        Map (_type_): _description_
    """

    building = models.ForeignKey(
        "location.Building", on_delete=models.CASCADE, related_name="floor"
    )
    floor_number = models.IntegerField()
    grid_width = models.IntegerField()
    grid_height = models.IntegerField()

    def __str__(self):
        """
        Returns the string representation of the floor map
        Returns:
            String: A string representation of the floor map
        """
        return f"{self.name} Floor Map"
