<# Filename: defend.ps1 
Author: Krishan Himesh Abeyrathne - 12217274 , Carl Khyncer Bhryn Yurong - 12224629
Subject: COIT11241 (Cyber Security Technologies) 
Purpose: Implement safeguard CIS 2.5 Allowlist Authorised Software #>

# Function to pre-test WDAC
function PreTest {
    # Run the keyfinder
    Start-Process -FilePath "Z:\keyfinder.exe"
    Write-Host "Unauthorised app Keyfinder is running"

    # Automate checking the Event Viewer logs for Code Integrity records
    Get-WinEvent (Get-WinEvent -ListLog *Integrity*).logname | where message -Like "*keyfinder*" | Out-Host
}


# Function to setup WDAC
function SetupWDAC {
    $WDACPolicyXMLFile = "C:\Windows\schemas\CodeIntegrity\ExamplePolicies\DefaultWindows_Audit.xml"
    [xml]$WDACPolicy = Get-Content -Path $WDACPolicyXMLFile

    if ($WDACPolicy.SiPolicy.PolicyID -ne $null) {
        $PolicyID = $WDACPolicy.SiPolicy.PolicyID
        $PolicyBinary = "$PolicyID.cip"
    }

    ConvertFrom-CIPolicy -XmlFilePath $WDACPolicyXMLFile -BinaryFilePath "C:\users\vagrant\$PolicyBinary"

    if ($(hostname) -eq "win11") {
        $PolicyBinary 
        C:\Windows\System32\CiTool.exe --update-policy "C:\Users\vagrant\$PolicyBinary" -json
    }

    Write-Host "WDAC Policy Applied Successfully"
}

# Function to post-test WDAC
function PostTest {
    # Check the WInEvent  List log for Intergrity record
    Get-WinEvent (Get-WinEvent -ListLog *Integrity*).logname | where message -Like "*keyfinder*" | Out-Host
}

# Function to reset WDAC
function ResetWDAC {
    $PolicyID = "{e0abda1f-ccf0-468e-8855-3e0f08b02d6a}"
    $SystemCodeIntegrityFolderRoot = $env:windir + "\System32\CodeIntegrity"
    $MultiplePolicyFilePath = "\CiPolicies\Active\" + $PolicyId + ".cip"
    $PolicyPath = $SystemCodeIntegrityFolderRoot + $MultiplePolicyFilePath
    
    Write-Host "Attempting to remove $PolicyPath..." 
    if (Test-Path $PolicyPath) {
        Remove-Item -Path $PolicyPath -Force -ErrorAction Continue
    }
    
    Write-Host "WDAC Policy Reset Successfully. Please restart your PC or it will restart automatically in 10 serconds"
    Start-Sleep -Seconds 10
    Restart-Computer -Force -Confirm:$false
}

# Main script
$command = $args[0]

switch ($command) {
    "pretest" {
        PreTest
    }
    "wdac-setup" {
        SetupWDAC
    }
    "post-test" {
        PostTest
    }
    "reset-WDAC" {
        ResetWDAC
    }
    default {
        Write-Host "Enter the commamd"
    }
}
