# pylint: skip-file

import os
from django.core.management.base import BaseCommand
from map.services.campus_import import import_campus_boundaries as campus_import
from location.services.buildings_load import import_building_data as buildings_load


class Command(BaseCommand):
    help = "Imports campus boundaries and building data from GeoJSON files"

    def add_arguments(self, parser):
        parser.add_argument(
            "campus_file", type=str, help="Path to the Campus Boundaries GeoJSON"
        )
        parser.add_argument(
            "buildings_file", type=str, help="Path to the Building Information GeoJSON"
        )
        parser.add_argument(
            "boundaries_file", type=str, help="Path to the Building Boundaries GeoJSON"
        )

    def handle(self, *args, **options):
        campus_file = options["campus_file"]
        buildings_file = options["buildings_file"]
        boundaries_file = options["boundaries_file"]

        if not os.path.exists(campus_file):
            self.stderr.write(self.style.ERROR(f"Campus file {campus_file} not found!"))
            return

        if not os.path.exists(buildings_file):
            self.stderr.write(
                self.style.ERROR(f"Buildings file {buildings_file} not found!")
            )
            return

        if not os.path.exists(boundaries_file):
            self.stderr.write(
                self.style.ERROR(f"Boundaries file {boundaries_file} not found!")
            )
            return

        self.stdout.write(self.style.SUCCESS("🚀 Starting Import Process..."))

        campus_import(campus_file)
        buildings_load(buildings_file, boundaries_file)

        self.stdout.write(self.style.SUCCESS("✅ Data Import Completed Successfully!"))
