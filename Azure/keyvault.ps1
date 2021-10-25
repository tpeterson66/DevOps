<#
    .DESCRIPTION
        Get all keyvaults in the current subscription and check the keyvaults for expired 
        certificates, secrets, and keys.
    .PARAMETER subscriptionId
        STRING - The Azure Subscription ID that will be used in the report.csv
    .PARAMETER subscriptionName
        STRING - The Azure Subscription Friendly Name that will be used in the report.csv
    .PARAMETER days
        INT - Used to check the expiration date, the number of days that should trigger a warning
    .PARAMETER skip
        BOOLEAN - Used to skip the scorecard check, pass True if you would like to skip this check in an environment
    .EXAMPLE
        ./keyvault.ps1 -subscriptionId <string> -subscriptionName <string> -days <int> -skip <bool>
#>
[CmdletBinding()]
param(
  $subscriptionId,
  $subscriptionName,
  $days,
  $skip
)

# Call in CreateReportItem function
. "./createReportFunction.ps1"

if($skip -eq "True") {
    Write-Host "##[warning] Skipping this step because the variable was set to true"
    Exit
}

# Empty objects that will be updated during runtime
$rawReport = @{}
$today = Get-Date

# Get all keyvaults in subscription
$keyvaults = az keyvault list | ConvertFrom-Json

# Loop through keyvaults to get certificates, secrets, keys
Foreach($keyvault in $keyvaults) {
    # Create a report per keyvault
    $expiringCertificates = @()
    $expiringKeys = @()
    $expiringSecrets = @()
    <#
    Check for all ceritificates in the keyvault and report if any will expire in x number of days.
    #>
    $certificates = az keyvault certificate list --vault-name $keyvault.name | ConvertFrom-Json
    Foreach ($certificate in $certificates) {
        # Check certificate expiration date
        if($certificate.attributes.expires -lt $today.addDays($days)) {
            $expiringCertificates += $certificate
            Write-Host "##[warning] Azure Key Vault Certificate - $($certificate.name) Will expire on $($certificate.attributes.expires)"
            CreateReportItem -item @{
                "subscriptionId"= $subscriptionId
                "subscriptionName" = $subscriptionName
                "impact" = "medium"
                "category" = "Key Vault"
                "recommendation" = "Certificate Expiration Warning - $($certificate.name) will expire on $($certificate.attributes.expires)"
                "resourceGroup" = "$($keyvault.resourceGroup)"
                "resource" = "$($keyvault.name)/$($certificate.name)"
            }
        }
    }

    <#
    Check for all secrets in the keyvault and report if any will expire in x number of days.
    #>
    $secrets = az keyvault secret list --vault-name $keyvault.name | ConvertFrom-Json
    Foreach ($secret in $secrets) {
        # Check secret expiration date
        if($secret.attributes.expires -lt $today.addDays($days)) {
            $expiringSecrets += $secret
            Write-Host "##[warning] Azure Key Vault Secret - $($secret.name) Will expire on $($secret.attributes.expires)"
            CreateReportItem -item @{
                "subscriptionId"= $subscriptionId
                "subscriptionName" = $subscriptionName
                "impact" = "medium"
                "category" = "Key Vault"
                "recommendation" = "Secret Expiration Warning - $($secret.name) will expire on $($secret.attributes.expires)"
                "resourceGroup" = "$($keyvault.resourceGroup)"
                "resource" = "$($keyvault.name)/$($secret.name)"
            }
        }
    }

    <#
    Check for all keys in the keyvault and report if any will expire in x number of days.
    #>
    $keys = az keyvault key list --vault-name $keyvault.name | ConvertFrom-Json
    Foreach ($key in $keys) {
        # Check key expiration date
        if($key.attributes.expires -lt $today.addDays($days)) {
            $expiringKeys += $key
            Write-Host "##[warning] Azure Key Vault Key - $($key.name) Will expire on $($key.attributes.expires)"
            CreateReportItem -item @{
                "subscriptionId"= $subscriptionId
                "subscriptionName" = $subscriptionName
                "impact" = "medium"
                "category" = "Key Vault"
                "recommendation" = "Key Expiration Warning - $($key.name) will expire on $($key.attributes.expires)"
                "resourceGroup" = "$($keyvault.resourceGroup)"
                "resource" = "$($keyvault.name)/$($key.name)"
            }
        }
    }
    
    $rawReport | Add-Member -type NoteProperty -name $keyvault.name -Value @{
        "keyvault" = $keyvault
        "certificates" = $certificates
        "secrets" = $secrets
        "keys" = $keys
    }
}

$rawReport = $rawReport | ConvertTo-JSON -Depth 5
New-Item -Path . -Name "./reports/keyvault.json" -ItemType "file" -Value $rawReport -Force