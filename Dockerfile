# Use Debian slim as base
FROM debian:12-slim

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    fortune-mod \
    cowsay \
    netcat-openbsd \
 && rm -rf /var/lib/apt/lists/*

# Copy application code
COPY . /app

# Make script executable
RUN chmod +x wisecow.sh

# Expose port
EXPOSE 4499

# Run Wisecow app
CMD ["./wisecow.sh"]
