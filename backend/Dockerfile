# Use the official GDAL image
FROM ghcr.io/osgeo/gdal:ubuntu-full-latest

# Set the working directory inside the container
WORKDIR /app

# Install dependencies
# Install dependencies
# Install dependencies
RUN apt-get update && apt-get install -y \
    python3-pip python3-dev python3-venv \
    libgdal-dev libgeos-dev libproj-dev curl \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Install Poetry inside the virtual environment
RUN /app/venv/bin/pip install poetry

RUN ls -lah /app/venv/bin/poetry

# Copy requirements first (for caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project files
COPY . .

# Ensure entrypoint.sh has executable permissions AFTER copying
RUN chmod +x /app/entrypoint.sh && ls -lah /app/entrypoint.sh  # Debug permissions

# Expose port 8080
EXPOSE 8080

# Use entrypoint script to dynamically set GDAL paths
ENTRYPOINT ["sh", "/app/entrypoint.sh"]

# Start Django
CMD ["sh", "-c", "python manage.py migrate --noinput && daphne -b 0.0.0.0 -p 8080 project.asgi:application"]
