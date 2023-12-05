#!/usr/bin/env bash

# Stop the service
echo "Stopping the service..."
./stop.sh
if [ $? -ne 0 ]; then
    echo "Failed to stop the service."
    #exit 1
fi

# Clean up
echo "Cleaning up..."
./clean.sh
if [ $? -ne 0 ]; then
    echo "Cleanup failed."
    #exit 1
fi

# Start the service
echo "Starting the service..."
./start.sh
if [ $? -ne 0 ]; then
    echo "Failed to start the service."
    exit 1
fi

echo "Service restarted successfully."
