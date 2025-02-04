from django.db import models

# Create your models here.
from backend.location.models import Location, IndoorLocation, OutdoorLocation, Building
from backend.map.models import FloorMap

# Create your models here.
class Path(models.Model):
    """Generic path model for indoor or outdoor paths

    Args:
        models (_type_): _description_
    """
    start = models.ForeignKey(Location, on_delete=models.CASCADE, related_name='start')
    end = models.ForeignKey(Location, on_delete=models.CASCADE, related_name='end')
    intermediate_points = models.ManyToManyField(Location, related_name='intermediate_points')
    distance = models.FloatField()
    estimated_time = models.FloatField()
    
    class Meta:
        abstract = True
        
class IndoorPath(Path):
    """Represents an indoor path

    Args:
        Path (_type_): _description_
    """
    start = models.ForeignKey(IndoorLocation, on_delete=models.CASCADE, related_name='indoor_start')
    end = models.ForeignKey(IndoorLocation, on_delete=models.CASCADE, related_name='indoor_end')
    is_accessible = models.BooleanField(default=True)
    
    def __str(self):
        return f"Indoor Path from {self.start} to {self.end}"
    
class OutdoorPath(Path):
    """Represents an outdoor path

    Args:
        Path (_type_): _description_
    """
    start = models.ForeignKey(OutdoorLocation, on_delete=models.CASCADE, related_name='outdoor_start')
    end = models.ForeignKey(OutdoorLocation, on_delete=models.CASCADE, related_name='outdoor_end')
    
    def __str(self):
        return f"Outdoor Path from {self.start} to {self.end}"

class EntranceExit(models.Model):
    """Represents an entrance or exit to a building

    Args:
        models (_type_): _description_
    """
    building = models.ForeignKey(Building, on_delete=models.CASCADE, related_name='entrance_exit')
    outdoor_location = models.ForeignKey(OutdoorLocation, on_delete=models.CASCADE, related_name='linked_exit')
    indoor_location = models.ForeignKey(IndoorLocation, on_delete=models.CASCADE, related_name='linked_entrance')
    floor_map = models.ForeignKey(FloorMap, on_delete=models.CASCADE, related_name='entrance_exit')
    
    def __str__(self):
        return f"Entrance/Exit for {self.building.name} at {self.outdoor_location.name} (Floor: {self.floor_map.floor_number})"
    
class Route(models.Model):
    """Represents a route between two locations

    Args:
        models (_type_): _description_
    """
    paths = models.ManyToManyField(Path, related_name='paths')
    total_distance = models.FloatField()
    estimated_time = models.FloatField()
    
    def __str__(self):
        return f"Route from {self.paths.first().start} to {self.paths.last().end}"