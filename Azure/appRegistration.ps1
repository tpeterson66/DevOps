<#
    .DESCRIPTION
        Identify expired and expiring app registration credentials
    .PARAMETER subscriptionId
        STRING - The Azure Subscription ID that will be used in the report.csv
        .PARAMETER subscriptionName
            STRING - The Azure Subscription Friendly Name that will be used in the report.csv
        .PARAMETER days
            STRING - Number of days out to check for expired app registration credentials
        .PARAMETER skip
            STRING - Used to skip the scorecard check, pass "True" if you would like to skip this check in an environment
    .EXAMPLE
        ./appRegistration.ps1 -subscriptionId <string> -subscriptionName <string> -skip <bool>
#>
[CmdletBinding()]
param(
    [string]$subscriptionId,
    [string]$subscriptionName,
    [int]$days,
    [string]$skip
)

# Call in CreateReportItem function
. "./createReportFunction.ps1"

# Used to skip this particular check
if ($skip -eq "True") {
    Write-Host "##[warning] Skipping this step because the variable was set to true"
    Exit
}

$today = Get-Date
$expirationDate = $today.addDays($days)
$apps = az ad app list --all | ConvertFrom-Json
foreach($app in $apps) {
    foreach($_ in $app.keyCredentials) {
        # check for expired
        if($_.endDate -lt $today) {
            Write-Host "##[warning] Detected Expired App Registration Credential - $($app.displayName) expired on $($_.endDate)"
            CreateReportItem -item @{
                "subscriptionId"= $subscriptionId
                "subscriptionName" = $subscriptionName
                "impact" = "medium"
                "category" = "App Registration"
                "recommendation" = "Detected Expired App Registration Credential - $($app.displayName) expired on $($_.endDate)"
                "resourceGroup" = "N/A"
                "resource" = "$($app.displayName)"
            }
        }
        # Check for expiring within # of days
        if ($_.endDate -gt $today -AND $_.endDate -lt $expirationDate) {
            Write-Host "##[warning] Detected Expiring App Registration Credential within $($days) days - $($app.displayName) expires on $($_.endDate)"
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
}