#!/bin/sh

echo "Running migrations..."
python manage.py migrate --noinput

echo "Starting Daphne..."
exec daphne -b 0.0.0.0 -p 8080 project.asgi:application
