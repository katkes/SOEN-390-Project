from django.db import models
from django.apps import apps

class Path(models.Model):
    """Generic path model for indoor or outdoor paths"""
    distance = models.FloatField()
    estimated_time = models.FloatField()

    class Meta:
        abstract = True  # Ensures this model is only inherited, not used directly


        
class IndoorPath(Path):
    """Represents an indoor path

    Args:
        Path (_type_): _description_
    """
    start = models.ForeignKey('location.IndoorLocation', on_delete=models.CASCADE, related_name='indoor_start')
    intermediate = models.ManyToManyField('location.IndoorLocation', related_name='indoor_intermediate')
    end = models.ForeignKey('location.IndoorLocation', on_delete=models.CASCADE, related_name='indoor_end')
    is_accessible = models.BooleanField(default=True)
    
    def __str(self):
        return f"Indoor Path from {self.start} to {self.end}"
    
class OutdoorPath(Path):
    """Represents an outdoor path

    Args:
        Path (_type_): _description_
    """
    start = models.ForeignKey('location.Building', on_delete=models.CASCADE, related_name='outdoor_start')
    end = models.ForeignKey('location.Building', on_delete=models.CASCADE, related_name='outdoor_end')
    
    def __str(self):
        return f"Outdoor Path from {self.start} to {self.end}"

class EntranceExit(models.Model):
    """Represents an entrance or exit to a building

    Args:
        models (_type_): _description_
    """
    building = models.ForeignKey('location.Building', on_delete=models.CASCADE, related_name='entrance_exit')
    outdoor_location = models.ForeignKey('location.Building', on_delete=models.CASCADE, related_name='linked_exit')
    indoor_location = models.ForeignKey('location.IndoorPOI', on_delete=models.CASCADE, related_name='linked_entrance')
    floor_map = models.ForeignKey('map.FloorMap', on_delete=models.CASCADE, related_name='entrance_exit')
    
    def __str__(self):
        return f"Entrance/Exit for {self.building.name} at {self.outdoor_location.name} (Floor: {self.floor_map.floor_number})"
    
class Route(models.Model):
    """Represents a route between two locations"""
    outdoor_paths = models.ManyToManyField('route.OutdoorPath', related_name='outdoor_routes')
    indoor_paths = models.ManyToManyField('route.IndoorPath', related_name='indoor_routes')
    total_distance = models.FloatField()
    estimated_time = models.FloatField()

    def __str__(self):
        return f"Route with {self.outdoor_paths.count()} outdoor paths and {self.indoor_paths.count()} indoor paths"
