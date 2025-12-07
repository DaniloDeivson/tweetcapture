FROM python:3.11-slim

# Install system dependencies including Chromium and its driver
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1 \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Create a directory for the package to satisfy absolute imports (e.g. 'from tweetcapture.utils ...')
# We copy the current directory contents into /app/tweetcapture
RUN mkdir tweetcapture
COPY . tweetcapture/

# Set PYTHONPATH to /app so that 'import tweetcapture' resolves to /app/tweetcapture
ENV PYTHONPATH="${PYTHONPATH}:/app"

# Set environment variables for Selenium
ENV CHROME_DRIVER=/usr/bin/chromedriver
ENV CHROME_BIN=/usr/bin/chromium

# Expose the port configured in the API
EXPOSE 9091

# Run the FastAPI application using Uvicorn
# Note: we run existing api.py which is now in tweetcapture/api.py
CMD ["uvicorn", "tweetcapture.api:app", "--host", "0.0.0.0", "--port", "9091"]
