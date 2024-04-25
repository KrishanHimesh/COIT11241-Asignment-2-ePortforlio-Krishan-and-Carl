<# Filename: Attack_3_MaliciusAttachment.ps1
Author: Krishan Himesh Abeyrathne - 12217274 , Carl Khyncer Bhryn Yurong - 12224629
Subject: COIT11241 (Cyber Security Technologies)
Purpose: Emulation of Medusa Locker Attack using Phishing email - With Notepad #>

# Function to install Sysmon if needed with proper error handling and checks
function Install-Sysmon {
    $sysmonExe = "$env:Temp\\Sysmon\\Sysmon64.exe"
    $sysmonConfigPath = "$env:Temp\\Sysmon\\SysmonConfig.xml"

    Write-Host "Checking if Sysmon is installed..."

    if (!(Get-Command Sysmon -ErrorAction SilentlyContinue)) {
        Write-Host "Sysmon is not installed. Installing Sysmon..." -ForegroundColor Yellow

        # Ensure the necessary paths exist
        if (-not (Test-Path "$env:Temp\\Sysmon")) {
            New-Item -Path "$env:Temp\\Sysmon" -ItemType Directory -Force
        }

        # Download and extract Sysmon
        $sysmonDownloadUrl = "https://download.sysinternals.com/files/Sysmon.zip"
        $downloadPath = "$env:Temp\\Sysmon.zip"
        $extractPath = "$env:Temp\\Sysmon"

        if (Test-Path $downloadPath) {
            Remove-Item -Path $downloadPath -Force  # Ensure the previous download is cleared
        }

        Invoke-WebRequest -Uri $sysmonDownloadUrl -OutFile $downloadPath
        Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

        # Create a simple Sysmon configuration
        $sysmonConfig = @"
<Sysmon schemaversion="13.0">
  <EventFiltering>
    <RuleGroup name="ProcessCreate" groupRelation="or">
      <ProcessCreate onmatch="include"/>
    </RuleGroup>
  </EventFiltering>
</Sysmon>
"@

        # Save the Sysmon configuration
        $sysmonConfig | Out-File -FilePath $sysmonConfigPath

        # Ensure the configuration file exists
        if (-not (Test-Path $sysmonConfigPath)) {
            Write-Host "Sysmon configuration file not found at $sysmonConfigPath." -ForegroundColor Red
            return
        }

        # Install Sysmon with the configuration and accept EULA
        try {
            & $sysmonExe -i $sysmonConfigPath -accepteula
            Write-Host "Sysmon installed and configured." -ForegroundColor Green
        } catch {
            Write-Host "Error installing Sysmon: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    } else {
        Write-Host "Sysmon is already installed." -ForegroundColor Yellow
    }
}

# Function to ensure the Sysmon event manifest is installed
function Install-EventManifest {
    $sysmonExe = "$env:Temp\\Sysmon\\Sysmon64.exe"

    if (Test-Path $sysmonExe) {
        Write-Host "Installing event manifest..."
        try {
            & $sysmonExe -m -accepteula  # Install the event manifest
            Write-Host "Event manifest installed successfully." -ForegroundColor Green
        } catch {
            Write-Host "Error installing event manifest. Ensure Sysmon is installed and try again." -ForegroundColor Red
        }
    } else {
        Write-Host "Sysmon executable not found." -ForegroundColor Red
    }
}

# Function to create a fake attack scenario in a Notepad file
function Create-FakeAttackNote {
    param(
        [string] $filePath = "Z:\\FakeAttackNote.txt"
    )

    Write-Host "Creating a Notepad file with a fake attack scenario at $filePath..."

    # Define a fake attack scenario
    $fakeAttackContent = @"
Simulated Attack Scenarios for Educational Purposes

1. Phishing Email Simulation
   - Description: Simulate sending a phishing email with a fake attachment.
   - Objective: Test user security awareness.
   - Example: Fake attachment named 'Invoice.pdf' with a hidden payload.

2. Process Injection Simulation
   - Description: Simulate process injection with benign DLL injection.
   - Objective: Test security monitoring.
   - Example: PowerShell command to simulate process injection.

3. Persistence via Registry Simulation
   - Description: Simulate creating a registry entry for persistence.
   - Objective: Test endpoint security.
   - Example: Adding a registry key in 'Run' for auto-starting executables.
"@

    try {
        $fakeAttackContent | Out-File -FilePath $filePath -Encoding ASCII
        Write-Host "Fake attack note created." -ForegroundColor Green
    } catch {
        Write-Host "Error creating fake attack note: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to simulate a phishing email with a fake attachment
function Simulate-PhishingEmail {
    param(
        [string] $targetEmail = "victim@example.com",
        [string] $fakeAttachment = "Z:\\FakeAttachment.exe"
    )

    Write-Host "Simulating a phishing email to $targetEmail with attachment $fakeAttachment..."
    Write-Host "Email with fake attachment sent. (Simulated)" -ForegroundColor Green
}

# Function to create a symbolic link and run Notepad
function CreateAndRunNotepad {
    $linkPath = "$env:Temp\\ATTACHME.LNK"
    $targetPath = "$env:Windir\\notepad.exe"

    try {
        New-Item -Path $linkPath -ItemType SymbolicLink -Value $targetPath -Force
        Start-Process -FilePath $linkPath
        Write-Host "Symbolic link created and Notepad started." -ForegroundColor Green
    } catch {
        Write-Host "Error creating symbolic link: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to check Sysmon logs for detection with filters
function CheckSysmonLogs {
    Write-Host "Checking Sysmon logs with filters..."

    $eventIDFilter = @(1, 11)  # Specific event IDs to check
    $startTime = (Get-Date).AddHours(-1)  # Adjust to match your simulation timeframe
    $processName = "notepad.exe"  # Example process name to filter by
    $filePath = "Z:\\FakeAttackNote.txt"  # Example file to filter by

    try {
        $filteredEventLog = Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" |
                            Where-Object { $_.Id -in $eventIDFilter } |
                            Where-Object { $_.TimeCreated -ge $startTime } |
                            Where-Object { $_.Message -like "*$processName*" -or $_.Message -like "*$filePath*" } |
                            Sort-Object TimeCreated -Descending
        
        if ($filteredEventLog -and $filteredEventLog.Count -gt 0) {
            Write-Host "Filtered Sysmon logs related to the simulation:" -ForegroundColor Green
            $filteredEventLog | Format-Table -AutoSize
        } else {
            Write-Host "No relevant logs found for the specified criteria." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error retrieving Sysmon logs: Ensure Sysmon is properly installed, check permissions, and confirm event logging is functional." -ForegroundColor Red
    }
}

# Function to clean up after the simulation
function Cleanup {
    $linkPath = "$env:Temp\\ATTACHME.LNK"

    if (Test-Path $linkPath) {
        try {
            Remove-Item -Path $linkPath -Force
            Write-Host "Symbolic link removed." -ForegroundColor Green
        } catch {
            Write-Host "Error removing symbolic link: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Main script execution
Install-Sysmon  # Install or reinstall Sysmon if needed
Install-EventManifest  # Ensure the Sysmon event manifest is installed
Create-FakeAttackNote -filePath "Z:\\FakeAttackNote.txt"  # Create a Notepad file with a fake attack scenario
Simulate-PhishingEmail -targetEmail "victim@example.com" -fakeAttachment "Z:\\FakeAttachment.exe"  # Simulate a phishing email
CreateAndRunNotepad  # Create a symbolic link and run Notepad
CheckSysmonLogs  # Check Sysmon logs for detection with filters
Cleanup  # Clean up after the simulation
