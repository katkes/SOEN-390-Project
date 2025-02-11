# Use the official GDAL image
FROM ghcr.io/osgeo/gdal:ubuntu-full-latest AS base

# Set the working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3-pip python3-dev python3-venv \
    libgdal-dev libgeos-dev libproj-dev \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment in a separate directory
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Copy dependencies first (for caching)
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project files
COPY . .

# Expose port 8080
EXPOSE 8080

# Copy and execute entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Use entrypoint script to dynamically set GDAL paths
ENTRYPOINT ["/app/entrypoint.sh"]

# Start Django using the virtual environment's Python
CMD ["sh", "-c", "/venv/bin/python manage.py migrate --noinput && /venv/bin/daphne -b 0.0.0.0 -p 8080 project.asgi:application"]