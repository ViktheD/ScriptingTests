#!/bin/bash

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Git if not installed
if ! command_exists git; then
    echo "Git is not installed. Installing..."
    # Install Git using apt
    sudo apt-get update
    sudo apt-get install -y git || { echo "Failed to install Git. Please install Git manually and rerun the script."; exit 1; }
else
    echo "Git is already installed."
fi

# Clone the repository
echo "Cloning repository..."
git clone https://github.com/ViktheD/ScriptingTests || { echo "Failed to clone repository. Please check the repository URL and try again."; exit 1; }

# Navigate to the repository directory
cd ScriptingTests || { echo "Failed to navigate to the repository directory. Please check if the repository was cloned successfully."; exit 1; }

# Check if Node.js is installed
if ! command_exists node; then
    echo "Node.js is not installed. Installing..."
    # Install Node.js using apt
    sudo apt-get update
    sudo apt-get install -y nodejs || { echo "Failed to install Node.js. Please install Node.js manually."; exit 1; }
else
    echo "Node.js is already installed."
fi

# Check if Playwright is installed
if ! command_exists playwright; then
    echo "Playwright is not installed. Installing..."
    # Install Playwright using npm
    npm install -g playwright || { echo "Failed to install Playwright. Please install Playwright manually."; exit 1; }
else
    echo "Playwright is already installed."
fi

# Update Node.js and Playwright to the latest versions
echo "Updating Node.js and Playwright to the latest versions..."
npm install -g npm@latest      # Update npm to the latest version
npm install -g playwright@latest

# Install project dependencies
echo "Installing project dependencies..."
# if there are any, use npm install
npm install -g http-server

# Run Playwright tests
echo "Running Playwright tests..."
npm test || { echo "Failed to run Playwright tests."; exit 1; }

# Start a HTTP server to serve test results
echo "Starting a HTTP server..."
http-server -p 8000 || { echo "Failed to start HTTP server."; exit 1; }
