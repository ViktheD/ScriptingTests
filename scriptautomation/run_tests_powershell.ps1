# Function to check if a command is available
function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
}

# Check if Chocolatey is installed
$chocoExecutablePath = "C:\ProgramData\chocolatey\bin\choco.exe"
if (-not (Test-Path $chocoExecutablePath)) {
    Write-Host "Chocolatey is not installed. Installing Chocolatey..."
    # Install Chocolatey using PowerShell script from Chocolatey website
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    if ($LastExitCode -ne 0) {
        Write-Host "Failed to install Chocolatey. Please install Chocolatey manually and rerun the script."
        pause
        exit 1
    }
}
else {
    Write-Host "Chocolatey is already installed."
}

# Check if Git is installed
if (-not (Test-Command "git")) {
    Write-Host "Git is not installed. Installing Git..."
    choco install git -y
}
else {
    Write-Host "Git is already installed."
}

# Prompt user for the repository directory
$repositoryDirectory = Read-Host "Enter the path to the repository directory (e.g., C:\path\to\repository)"

# Check if the repository directory exists
if (-not (Test-Path $repositoryDirectory)) {
    Write-Host "The specified repository directory does not exist."
    pause
    exit 1
}

# Navigate to the repository directory
cd $repositoryDirectory
if ($LastExitCode -ne 0) {
    Write-Host "Failed to navigate to the repository directory. Please check if the repository was cloned successfully."
    pause
    exit 1
}

# Check if Node.js is installed
if (-not (Test-Command "node")) {
    Write-Host "Node.js is not installed. Installing Node.js..."
    choco install nodejs -y
}
else {
    Write-Host "Node.js is already installed."
}

# Check if Playwright is installed
if (-not (Test-Command "playwright")) {
    Write-Host "Playwright is not installed. Installing Playwright..."
    # Install Playwright using npm
    npm install -g playwright
}
else {
    Write-Host "Playwright is already installed."
}

# Update Node.js and Playwright to the latest versions
Write-Host "Updating Node.js and Playwright to the latest versions..."
npm install -g npm@latest   # Update npm to the latest version
npm install -g playwright@latest

# Install project dependencies
Write-Host "Installing project dependencies..."
# if there are any, use npm install
npm install -g http-server

# Run Playwright tests
Write-Host "Running Playwright tests..."
npm test
if ($LastExitCode -ne 0) {
    Write-Host "Failed to run Playwright tests."
    pause
    exit 1
}

# Start a HTTP server to serve test results
Write-Host "Starting a HTTP server..."
http-server -p 8000
if ($LastExitCode -ne 0) {
    Write-Host "Failed to start HTTP server."
    pause
    exit 1
}

# Add pause to prevent the PowerShell window from closing automatically
pause