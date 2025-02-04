from django.db import models
from django.contrib.gis.db import models as gis_models
from backend.location.models import Building

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
    boundary = gis_models.PolygonField()
    
    def __str__(self):
        return f"{self.name} Campus Map"

class FloorMap(Map):
    """Represents a floor map

    Args:
        Map (_type_): _description_
    """
    building = models.ForeignKey(Building, on_delete=models.CASCADE, related_name='floor')
    floor_number = models.IntegerField()
    grid_width = models.IntegerField()
    grid_height = models.IntegerField()
    
    def __str__(self):
        return f"{self.name} Floor Map"