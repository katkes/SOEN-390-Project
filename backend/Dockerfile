# Use the official GDAL image from OSGeo GitHub Container Registry
FROM ghcr.io/osgeo/gdal:ubuntu-full-latest

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies required for Django & GDAL
RUN apt-get update && apt-get install -y \
    python3-pip python3-dev python3-venv \
    libgdal-dev libgeos-dev libproj-dev \
    && rm -rf /var/lib/apt/lists/*

# ✅ REMOVE: Explicit GDAL installation (it is already in the base image)
# RUN apt-get install -y gdal-bin=3.10.1-1build1 libgdal-dev=3.10.1-1build1

# Set environment variables for GDAL & GEOS
ENV GDAL_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/libgdal.so
ENV GEOS_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/libgeos_c.so
ENV PROJ_LIB=/usr/share/proj

# Create a virtual environment for Python
RUN python3 -m venv /app/venv

# Activate the virtual environment
ENV PATH="/app/venv/bin:$PATH"

# Copy only requirements first to leverage Docker cache
COPY requirements.txt .

# ✅ REMOVE: Explicit GDAL Python bindings (let Docker handle it)
# RUN pip install --no-cache-dir "GDAL==3.10.1"

# Install all other Python dependencies inside the virtual environment
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project files into the container
COPY . .

# Expose port 8080 for WebSockets & HTTP
EXPOSE 8080

# Set Django settings module explicitly
ENV DJANGO_SETTINGS_MODULE=project.settings

# Copy the entrypoint script
#COPY entrypoint.sh /app/entrypoint.sh

# Set execution permissions inside the container
#RUN chmod +x /app/entrypoint.sh

# Use entrypoint script for migrations & server startup
CMD ["sh", "-c", "python manage.py migrate --noinput && daphne -b 0.0.0.0 -p 8080 project.asgi:application"]

