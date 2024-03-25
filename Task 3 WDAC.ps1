#Implement safeguard CIS 2.5 Allowlist Authorised Software

function pretest{
Start-Process -FilePath "Y:\ChromeSetup.exe"
Write-Host "Chromesetup is running"
get-winevent (Get-WinEvent -ListLog *Integrity*).logname | where message -Like *chrome* | Out-Host
}

function wdac-setup{
$WDACPolicyXMLFile = $env:USERPROFILE + "\Desktop\MyWDACPolicy.xml"
$WDACPolicyXMLFile = "C:\Windows\schemas\CodeIntegrity\ExamplePolicies\DefaultWindows_Audit.xml"
[xml]$WDACPolicy = Get-Content -Path $WDACPolicyXMLFile

if ($WDACPolicy.SiPolicy.PolicyID -ne $null)
{
    $PolicyID = $WDACPolicy.SiPolicy.PolicyID
    $PolicyBinary = "$PolicyID.cip"}

ConvertFrom-CIPolicy -XmlFilePath $WDACPolicyXMLFile -BinaryFilePath "C:\users\vagrant\$PolicyBinary"

if ($(hostname) -eq "dc") {
    $PolicyBinary 
    cd C:\Users\vagrant
    citool.exe --update-policy $PolicyBinary -json
}
 Write-Host "WDAC Policy Applied Successfully"
} 
function post-test{
Start-Process -FilePath "Y:\ChromeSetup.exe"
get-winevent (Get-WinEvent -ListLog *Integrity*).logname | where message -Like *chrome* | Out-Host
}

function reset-WDAC{
# Set PolicyId GUID to the PolicyId from your WDAC policy XML
    $PolicyID = "{e0abda1f-ccf0-468e-8855-3e0f08b02d6a}"

    # Initialize variables
    $SystemCodeIntegrityFolderRoot = $env:windir+"\System32\CodeIntegrity"
    $MultiplePolicyFilePath = "\CiPolicies\Active\"+$PolicyId+".cip"


 $PolicyPath = $SystemCodeIntegrityFolderRoot+$MultiplePolicyFilePath
 
# Delete the policy file from the current $PolicyPath
 Write-Host "Attempting to remove $PolicyPath..." 
 if (Test-Path $PolicyPath) {Remove-Item -Path $PolicyPath -Force -ErrorAction Continue}
 Write-Host "WDAC Policy Reseted Successfully, Please Restart your PC or PC will be Restart Automatically in 10 Seconds"
 Start-Sleep -Seconds 10; Restart-Computer -Force -Confirm:$false
}
