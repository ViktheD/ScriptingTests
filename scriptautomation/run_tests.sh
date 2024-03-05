#!/bin/bash

# Function to check if a command is available
command_exists() {
	  command -v "$1" >/dev/null 2>&1
  }

  # Check if Node.js is installed
  if ! command_exists node; then
	    echo "Node.js is not installed. Installing..."
	      # Install Node.js using apt
	        sudo apt-get update
		sudo apt-get install -y nodejs
	  else
		    echo "Node.js is already installed."
  fi

  # Check if Playwright is installed
  if ! command_exists playwright; then
	    echo "Playwright is not installed. Installing..."
	      # Install Playwright using npm
	        npm install -g playwright
	else
		  echo "Playwright is already installed."
  fi

  # Update Node.js and Playwright to the latest versions
  echo "Updating Node.js and Playwright to the latest versions..."
  npm install -g npm@latest      # Update npm to the latest version
  npm install -g playwright@latest

  # Clone the repository
  # echo "Cloning the repository..."
  # git clone https://github.com/yourusername/your-repo.git

  # Navigate to the tests directory
  cd your-repo

  # Install project dependencies
  echo "Installing project dependencies..."
  # if there are any, use npm install

  # Run Playwright tests
  echo "Running Playwright tests..."
  npm test

  # Start a simple HTTP server to serve test results
  echo "Starting a simple HTTP server..."
  python -m SimpleHTTPServer 8000

