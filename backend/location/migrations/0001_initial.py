# Generated by Django 5.1.6 on 2025-02-11 01:51

import django.contrib.gis.db.models.fields
import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="Location",
            fields=[
                ("id", models.AutoField(primary_key=True, serialize=False)),
                ("name", models.CharField(max_length=255, unique=True)),
            ],
        ),
        migrations.CreateModel(
            name="Building",
            fields=[
                (
                    "location_ptr",
                    models.OneToOneField(
                        auto_created=True,
                        on_delete=django.db.models.deletion.CASCADE,
                        parent_link=True,
                        primary_key=True,
                        serialize=False,
                        to="location.location",
                    ),
                ),
                (
                    "boundary",
                    django.contrib.gis.db.models.fields.MultiPolygonField(
                        blank=True, null=True, srid=4326
                    ),
                ),
                ("num_floors", models.IntegerField(default=1)),
                (
                    "long_name",
                    models.CharField(default="Unknown Building", max_length=255),
                ),
                ("address", models.TextField(default="Unknown Address")),
                ("latitude", models.FloatField(default=0.0)),
                ("longitude", models.FloatField(default=0.0)),
            ],
            bases=("location.location",),
        ),
        migrations.CreateModel(
            name="IndoorLocation",
            fields=[
                (
                    "location_ptr",
                    models.OneToOneField(
                        auto_created=True,
                        on_delete=django.db.models.deletion.CASCADE,
                        parent_link=True,
                        primary_key=True,
                        serialize=False,
                        to="location.location",
                    ),
                ),
                ("x", models.IntegerField(default=0)),
                ("y", models.IntegerField(default=0)),
            ],
            bases=("location.location",),
        ),
    ]
