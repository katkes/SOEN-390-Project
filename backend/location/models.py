from django.db import models
from django.contrib.gis.db import models as gis_models  # For spatial data
from django.apps import apps


# Create your models here.
class Location(models.Model):
    name = models.CharField(max_length=255)
    
    

class Building(Location):
    campus_map = models.ForeignKey('map.CampusMap', on_delete=models.CASCADE, related_name='buildings')
    boundary = gis_models.MultiPolygonField(null=True, blank=True)  # Allow nulls
 # Building boundary as a polygon
    num_floors = models.IntegerField(default=1)
    long_name = models.CharField(max_length=255)
    address = models.TextField(default='')
    latitude = models.FloatField()
    longitude = models.FloatField()

    def __str__(self):
        return f"Building: {self.name} (Campus: {self.campus_map.name})"

    

class IndoorLocation(Location):
    x = models.IntegerField()
    y = models.IntegerField()
    floor_map = models.ForeignKey('map.FloorMap', on_delete=models.CASCADE, related_name='indoor_location_set')
    

class Room(IndoorLocation):
    room_number = models.CharField(max_length=10)
    room_type = models.CharField(max_length=10)

class IndoorPOI(IndoorLocation):
    is_accessible = models.BooleanField(default=True)
    poi_type = models.CharField(max_length=255)