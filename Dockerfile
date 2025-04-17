FROM python:3.12-slim

WORKDIR /app

# Install git, Node.js, npm, and other dependencies
RUN apt-get update && \
    apt-get install -y git curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements first for better layer caching
COPY requirements.txt .
#RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir git+https://github.com/supercog-ai/agentic.git@basic_ui_users
RUN pip install -r requirements.txt

# Copy the rest of the application
COPY . .
COPY start.sh .

# Install npm packages for the dashboard
#WORKDIR /app/agentic/dashboard
WORKDIR /usr/local/lib/python3.12/site-packages/agentic/dashboard
RUN npm install
WORKDIR /app

# Make sure the module is in the Python path
ENV PYTHONPATH=/app
ENV APP_BASE_DIR=/app

# Expose port and port 3000 for the dashboard
EXPOSE 8086
EXPOSE 3000

# Run the server
CMD ["/bin/bash", "./start.sh"]
