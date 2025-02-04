from django.db import models
from django.contrib.gis.db import models as gis_models  # For spatial data
from backend.map.models import CampusMap, FloorMap

# Create your models here.
class Location(models.Model):
    x = models.FloatField()
    y = models.FloatField()
    
class OutdoorLocation(Location):
    name = models.CharField(max_length=255)
    x = gis_models.FloatField()
    y = gis_models.FloatField()
    campus_map = models.ForeignKey(CampusMap, on_delete=models.CASCADE, related_name='outdoor_locations')
    
    def __str__(self):
        return f"Outdoor Location: {self.name} (Campus Map: {self.campus_map.name})"

class Building(OutdoorLocation):
    
    num_floors = models.IntegerField(default=1)
    
    def __str__(self):
        return f"Building: {self.name} (Campus Map: {self.campus_map.name})"
    
class OutdoorPOI(OutdoorLocation):
    
    poi_type = models.CharField(max_length=255)
    
    def __str__(self):
        return f"Outdoor POI: {self.name} (Campus Map: {self.campus_map.name})"
    

class IndoorLocation(Location):
    name = models.CharField(max_length=255)
    x = models.IntegerField()
    y = models.IntegerField()
    floor_map = models.ForeignKey(FloorMap, on_delete=models.CASCADE, related_name='indoor_locations')
    
    class Meta:
        abstract = True

class Room(IndoorLocation):
    room_number = models.CharField(max_length=10)
    room_type = models.CharField(max_length=10)

class IndoorPOI(IndoorLocation):
    is_accessible = models.BooleanField(default=True)
    poi_type = models.CharField(max_length=255)