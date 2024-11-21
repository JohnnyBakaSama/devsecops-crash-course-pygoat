FROM python:3.11-slim-buster

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies for psycopg2 and other libraries
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install Python dependencies
RUN python -m pip install --no-cache-dir --upgrade pip==22.0.4
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the project files into the container
COPY . /app/

# Set up the database for PyGoat
RUN python3 manage.py migrate

# Expose the application port
EXPOSE 8000

# Start the application with Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
