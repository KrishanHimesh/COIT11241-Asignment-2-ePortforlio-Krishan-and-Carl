<# Filename: remoteFileCopy.ps1
Author: Krishan Himesh Abeyrathne - 12217274 
Subject: COIT11241 (Cyber Security Technologies)
Purpose: Emulation of Remote file copy #>

# remoteFileCopy.ps1
# Simulate copying a file from a remote server to the local machine
$source = "\\DC\pslogs\malicious-file.txt"
$destination = "Z:\malicious-file.txt"
Write-Host "Source: $source"
Write-Host "Destination: $destination"
Copy-Item -Path $source -Destination $destination -Verbose

