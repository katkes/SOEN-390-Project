from django.db import models
from django.contrib.gis.db import models as gis_models
from django.apps import apps


# Create your models here.
class Map(models.Model):
    """Abstract class for all maps

    Args:
        models (_type_): _description_
    """
    name = models.CharField(max_length=255)
    class Meta:
        abstract = True
    
class CampusMap(Map):
    """Represents a campus map

    Args:
        Map (_type_): _description_
    """
    
    boundary = gis_models.MultiPolygonField(null=True, blank=True)  # Allow nulls

    
    def __str__(self):
        return f"{self.name} Campus Map"

class FloorMap(Map):
    """Represents a floor map

    Args:
        Map (_type_): _description_
    """
    building = models.ForeignKey('location.Building', on_delete=models.CASCADE, related_name='floor')
    floor_number = models.IntegerField()
    grid_width = models.IntegerField()
    grid_height = models.IntegerField()
    
    def __str__(self):
        return f"{self.name} Floor Map"