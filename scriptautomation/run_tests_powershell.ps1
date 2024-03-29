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

# Check if the local repository is up to date with the remote repository's main branch
Write-Host "Checking if the repository is up to date..."
$gitOutput = git pull origin main

# Check if there were any updates
if ($gitOutput -match "Updating") {
    Write-Host "New updates were found in the repository."
    $restartScript = Read-Host "Do you want to restart the script to apply the updates? (Y/N)"
    
    if ($restartScript -eq "Y" -or $restartScript -eq "y") {
        Write-Host "Restarting the script..."
        & $MyInvocation.MyCommand.Path
        exit
    }
    else {
        Write-Host "Continuing script execution without applying updates."
    }
}
else {
    Write-Host "The repository is up to date."
}

# Install project dependencies
Write-Host "Installing project dependencies..."
# if there are any, use npm install
npm i -D @playwright/test #installs modules
npx playwright install   #installs browsers

# Prompt user to choose how to run tests
$testOption = Read-Host "Do you want to run all tests or a specific test? (Type 'all' or 'specific')"

# Run Playwright tests based on user's choice
if ($testOption -eq "all") {
    # Run all tests
    Write-Host "Running all Playwright tests..."
    npm test
    if ($LastExitCode -ne 0) {
        Write-Host "Failed to run Playwright tests."
        pause
        exit 1
    }
}
elseif ($testOption -eq "specific") {
    # Prompt user to choose which test to run
    $selectedTest = $null
    while (-not $selectedTest) {
        $selectedTest = Read-Host "Enter the name of the test you want to run (e.g., 'firstTest', 'seconTest')"
        $testExists = npm test -- --list | Select-String -Pattern $selectedTest

        if (-not $testExists) {
            Write-Host "No test with the name '$selectedTest' found. Please try again."
            $selectedTest = $null  # Reset $selectedTest to prompt the user again
        }
    }

    # Run the selected test
    Write-Host "Running Playwright test: $selectedTest..."
    npx playwright test "$selectedTest.spec.ts"
    if ($LastExitCode -ne 0) {
        Write-Host "Failed to run Playwright test: $selectedTest."
        pause
        exit 1
    }
}
else {
    Write-Host "Invalid option. Please choose 'all' or 'specific'."
    pause
    exit 1
}

# Display HTML report
Write-Host "Opening test results HTML report..."
npx playwright show-report

# Add pause to prevent the PowerShell window from closing automatically
pause