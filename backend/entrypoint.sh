#!/bin/sh

# Find correct GDAL path dynamically
if [ -f "/usr/lib/x86_64-linux-gnu/libgdal.so" ]; then
    export GDAL_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu/libgdal.so"
elif [ -f "/usr/lib/aarch64-linux-gnu/libgdal.so" ]; then
    export GDAL_LIBRARY_PATH="/usr/lib/aarch64-linux-gnu/libgdal.so"
elif [ -f "/usr/lib/libgdal.so" ]; then
    export GDAL_LIBRARY_PATH="/usr/lib/libgdal.so"
else
    echo "ERROR: Could not find libgdal.so"
    exit 1
fi

echo "Using GDAL_LIBRARY_PATH: $GDAL_LIBRARY_PATH"

# Run the original command
exec "$@"
