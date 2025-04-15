FROM python:3.12-slim

WORKDIR /app

# Install git and other dependencies
RUN apt-get update && apt-get install -y git && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Make sure the module is in the Python path
ENV PYTHONPATH=/app
ENV APP_BASE_DIR=/app

# Expose port
EXPOSE 8086

# Run the server
CMD ["python", "server.py"]