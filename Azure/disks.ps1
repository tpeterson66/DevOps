<#
    .DESCRIPTION
        Provide some information about the script and its pupose
    .PARAMETER subscriptionId
        STRING - The Azure Subscription ID that will be used in the report.csv
    .PARAMETER subscriptionName
        STRING - The Azure Subscription Friendly Name that will be used in the report.csv
    .PARAMETER productionEnvironment
        BOOLEAN - If true, this will check all disks in the enviroment and identify if they're standard or premium disks
    .PARAMETER skip
        BOOLEAN - If true, this will skip this check
    .EXAMPLE
        ./disks.ps1 -subscriptionId <string> -subscriptionName <string> -productionEnvironment <string> -skip <bool>
#>
# Incoming parameters passed by the command line
[CmdletBinding()]
param(
    $subscriptionId,
    $subscriptionName,
    $productionEnvironment,
    $skip
)

# Call in CreateReportItem function
. "./createReportFunction.ps1"

# Used to skip this particular check
if ($skip -eq "True") {
    Write-Host "##[warning] Skipping this step because the variable was set to true"
    Exit
}

Write-Host "Production environment is set to $productionEnvironment"
# Setup
$azureDisks = az disk list | ConvertFrom-JSON
$report = @{}
$unattachedDisks = @()
$premiumDisks = @()
$standardDisks = @()
<#
    Check for unattached disks, reported regardless of environment
#>
Write-Host "##[warning] Checking for unattached disks!"
foreach ($disk in $azureDisks) {
    if ($disk.diskState -eq "Unattached") {
        Write-Host "##[warning] $($disk.name) is unattached"
        $unattachedDisks += $disk
        CreateReportItem -item @{
            "subscriptionId"   = $subscriptionId
            "subscriptionName" = $subscriptionName
            "impact"           = "medium"
            "category"         = "Disks"
            "recommendation"   = "Detected unattached managed disk"
            "resourceGroup"    = "$($disk.resourceGroup)"
            "resource"         = "$($disk.name)"
        }
    }
}

<#
    Check the disk sku in each environment
#>
if ($productionEnvironment -eq "True") {
    Write-Host "##[warning] Checking for non-premium disks in a production subscription"
} else {
    Write-Host "##[warning] Checking for premium disks in a non-production subscription"
}
foreach ($disk in $azureDisks) {
    # Check for non-premium disks in production
    if ($productionEnvironment -eq "True" -AND $disk.sku.tier -ne "Premium") {
        Write-Host "##[warning] $($disk.name) - Detected non-premium disk in production"
        $standardDisks += $disk
        CreateReportItem -item @{
            "subscriptionId"   = $subscriptionId
            "subscriptionName" = $subscriptionName
            "impact"           = "medium"
            "category"         = "Disks"
            "recommendation"   = "Detected non-premium disk in production environment"
            "resourceGroup"    = "$($disk.resourceGroup)"
            "resource"         = "$($disk.name)"
        } 
    }
    else {
        # Check for premium disks in non-production 
        Write-Host "##[warning] $($disk.name) - Detected premium disk in non-production environment"
        $premiumDisks += $disk
        CreateReportItem -item @{
            "subscriptionId"   = $subscriptionId
            "subscriptionName" = $subscriptionName
            "impact"           = "medium"
            "category"         = "Disks"
            "recommendation"   = "Detected premium disk in non-production environment"
            "resourceGroup"    = "$($disk.resourceGroup)"
            "resource"         = "$($disk.name)"
        } 
    }
}

$report | Add-Member -type NoteProperty -name "standardDisksInProd" -Value $standardDisks
$report | Add-Member -type NoteProperty -name "unattachedDisks" -Value $unattachedDisks
$report | Add-Member -type NoteProperty -name "premiumDisksInPreProd" -Value $premiumDisks
$report = $report | ConvertTo-JSON -Depth 5
New-Item -Path . -Name "./reports/disks.json" -ItemType "file" -Value $report -Force

