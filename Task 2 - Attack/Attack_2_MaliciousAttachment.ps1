<# Filename: Attack_2_MaliciusAttachment.ps1
Author: Krishan Himesh Abeyrathne - 12217274 , Carl Khyncer Bhryn Yurong - 12224629
Subject: COIT11241 (Cyber Security Technologies)
Purpose: Emulation of Medusa Locker Attack using Phishing email - with exe file #>

# Function to create a fake malicious attachment with benign content
function Create-FakeMaliciousAttachment {
    param(
        [string] $attachmentPath = "Z:\\FakeAttachment.exe"  # Path to create the fake executable
    )

    # Display the creation process
    Write-Host "Creating a fake malicious attachment at $attachmentPath..."

    # Content for the fake executable (a simple calculator script)
    # This script calculates 2 + 2 as a simple example of benign content
    $calculatorScript = @"
using System;

public class Calculator {
    public static void Main() {
        Console.WriteLine("Calculator: 2 + 2 = " + (2 + 2));
    }
}
"@

    try {
        # Compile the C# script into an executable
        Add-Type -TypeDefinition $calculatorScript -Language CSharp -OutputAssembly $attachmentPath

        # Success message after creating the executable
        Write-Host "Fake malicious attachment created successfully." -ForegroundColor Green
    } catch {
        # Display any error encountered during the creation
        Write-Host "Error creating fake malicious attachment: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to simulate sending a phishing email with a fake attachment
function Simulate-Phishing {
    param(
        [string] $emailAddress = "victim@example.com",  # Email address of the victim (simulated)
        [string] $attachmentPath = "Z:\\FakeAttachment.exe"  # Path to the fake attachment
    )

    # Display the start of the phishing simulation
    Write-Host "Simulating a phishing email to $emailAddress with attachment $attachmentPath..."

    # This is a simulation, not actually sending an email
    Write-Host "Phishing email simulation started." -ForegroundColor Green

    # Simulate the victim opening the attachment
    if (Test-Path -Path $attachmentPath) {
        Start-Process -FilePath $attachmentPath  # This runs the executable
        Write-Host "Attachment executed successfully." -ForegroundColor Green
    } else {
        # If the attachment is not found, show an error
        Write-Host "Attachment not found." -ForegroundColor Red
    }
}

# Function to create a registry entry for persistence (common ransomware technique)
function Simulate-Persistence {
    param(
        [string] $registryKey = "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Run",  # Location of the registry key
        [string] $registryValueName = "FakeRansomware",  # Name of the registry entry
        [string] $executablePath = "Z:\\FakeAttachment.exe"  # Path to the executable for persistence
    )

    Write-Host "Creating a registry entry for persistence..."

    try {
        # Create the registry key and set the value to the executable path for persistence
        Set-ItemProperty -Path $registryKey -Name $registryValueName -Value $executablePath -Force

        # Success message upon creation of the registry entry
        Write-Host "Registry entry for persistence created." -ForegroundColor Green
    } catch {
        # Display error message if registry creation fails
        Write-Host "Error creating registry entry: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to remove the registry entry for cleanup (after emulation)
function Cleanup-Persistence {
    param(
        [string] $registryKey = "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Run",  # Registry key location
        [string] $registryValueName = "FakeRansomware"  # Name of the registry entry to remove
    )

    Write-Host "Removing registry entry for persistence..."

    try {
        # Remove the registry key for cleanup after the emulation
        Remove-ItemProperty -Path $registryKey -Name $registryValueName -Force

        # Success message indicating removal of the registry entry
        Write-Host "Registry entry removed." -ForegroundColor Green
    } catch {
        # Display error message if registry removal fails
        Write-Host "Error removing registry entry: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Main script to simulate MedusaLocker-like attacks
Write-Host "Starting MedusaLocker-like attack simulation..." -ForegroundColor Yellow

# Create a fake malicious attachment to simulate malware execution
Create-FakeMaliciousAttachment -attachmentPath "Z:\\FakeAttachment.exe"

# Simulate sending a phishing email with the created attachment
Simulate-Phishing -emailAddress "victim@example.com" -attachmentPath "Z:\\FakeAttachment.exe"

# Simulate creating a registry entry for persistence, like ransomware does
Simulate-Persistence -registryValueName "FakeRansomware" -executablePath "Z:\\FakeAttachment.exe"

# Cleanup the registry after the emulation to leave no traces
Cleanup-Persistence -registryValueName "FakeRansomware"

# Final message indicating completion of the emulation
Write-Host "MedusaLocker-like attack simulation completed." -ForegroundColor Yellow
