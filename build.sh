#!/bin/bash

# Build the Docker image
echo "Building Magento Docker image..."
docker build -t magento-nginx .

# Run the container
echo "Starting Magento container..."
docker run -d -p 9000:9000 --name magento-app magento-nginx

echo "Magento is running on http://localhost:9000"
echo "To view logs: docker logs magento-app"
echo "To stop: docker stop magento-app"
echo "To remove: docker rm magento-app"
