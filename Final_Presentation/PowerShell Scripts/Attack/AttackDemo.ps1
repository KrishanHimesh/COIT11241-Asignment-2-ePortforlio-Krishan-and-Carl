# Function to log results to the console
function Log-Results {
    param (
        [string]$message
    )
    Write-Host $message
}

# Function to block file copy
function Block-FileCopy {
    Write-Host "Blocking file copy over SMB..."
    $rule = New-NetFirewallRule -DisplayName "Block SMB File Copy" -Direction Outbound -Protocol TCP -RemotePort 445 -Action Block
    if ($rule) {
        Write-Host "File copy over SMB blocked."
    } else {
        Write-Host "Failed to create firewall rule to block file copy."
    }
}

# Function to allow file copy
function Allow-FileCopy {
    Write-Host "Allowing file copy over SMB..."
    $firewallRule = Get-NetFirewallRule -DisplayName "Block SMB File Copy" -ErrorAction SilentlyContinue
    if ($firewallRule) {
        Remove-NetFirewallRule -DisplayName "Block SMB File Copy"
        Write-Host "File copy over SMB allowed."
    } else {
        Write-Host "Firewall rule 'Block SMB File Copy' not found."
    }
}

# Function to run the remote file copy
function Run-RemoteFileCopy {
    Log-Results -message "Running remote file copy script..."
    try {
        # Debugging: Check if the file exists
        if (Test-Path -Path "\\DC\pslogs\malicious-file.txt") {
            Log-Results -message "File exists at the source path."
        } else {
            Log-Results -message "File does not exist at the source path."
        }

        # Debugging: Check if the destination is writable
        if (Test-Path -Path "Z:") {
            Log-Results -message "Destination path is writable."
        } else {
            Log-Results -message "Destination path is not writable."
        }

        # Perform the file copy
        .\remoteFileCopy.ps1
        Log-Results -message "Remote file copy script executed."
    } catch {
        Log-Results -message "Remote file copy execution blocked or failed."
    }
}

# Function to get essential event details
function Get-EssentialEventDetails {
    param (
        [System.Diagnostics.Eventing.Reader.EventRecord]$event
    )

    Log-Results -message "Extracting details from event ID: $($event.Id) at $($event.TimeCreated)..."
    $details = @{
        TimeCreated = $event.TimeCreated
        Id          = $event.Id
    }

    $eventMessage = $event.FormatDescription()
    if ($eventMessage) {
        $eventMessage.Split("`n") | ForEach-Object {
            if ($_ -like "TargetFilename:*") {
                $details.TargetFilename = $_.Split(":")[1].Trim()
            }
            if ($_ -like "Image:*") {
                $details.ProcessName = $_.Split(":")[1].Trim()
            }
        }
    }

    return $details
}

# Function to display recent Sysmon events with essential details
function Show-SysmonEvents {
    Write-Host "Logging recent Sysmon events..."
    Start-Sleep -Seconds 5 # Delay to ensure events are written to the log

    $fileEvents = Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -FilterXPath "*[System[EventID=11]]" -MaxEvents 20
    if ($fileEvents.Count -gt 0) {
        $fileEvents | ForEach-Object {
            $eventDetails = Get-EssentialEventDetails -event $_
            [PSCustomObject]@{
                TimeCreated     = $eventDetails.TimeCreated
                Id              = $eventDetails.Id
                ProcessName     = $eventDetails.ProcessName
                TargetFilename  = $eventDetails.TargetFilename
            }
        } | Format-Table -AutoSize -Wrap

        Write-Host "Recent Sysmon events displayed."
    } else {
        Write-Host "No relevant Sysmon events found."
    }
}

# Function to apply mitigation (e.g., block remote file copy)
function ApplyMitigation {
    Write-Host "Applying mitigation to prevent future unauthorized file copies..."
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareWks" -Value 0 -PropertyType "DWORD" -Force
    Restart-Service -Name "LanmanServer"
    Write-Host "Mitigation applied."
}

# Main function to run the demonstration
function Run-Demo {
    # Phase 1: Block the file copy and show it being blocked
    Block-FileCopy
    Run-RemoteFileCopy

    # Phase 2: Allow the file copy and demonstrate detection
    Allow-FileCopy
    Run-RemoteFileCopy

    # Display Sysmon events
    Show-SysmonEvents

    # Phase 3: Apply mitigation
    ApplyMitigation

    Log-Results -message "Demo completed."
}

# Run the demonstration
Run-Demo
