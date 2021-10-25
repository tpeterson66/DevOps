<#
    .DESCRIPTION
        Check all azure ASR vaults and identify any failed backup jobs.
    .PARAMETER subscriptionId
        STRING - The Azure Subscription ID that will be used in the report.csv
    .PARAMETER subscriptionName
        STRING - The Azure Subscription Friendly Name that will be used in the report.csv
    .PARAMETER skip
        BOOLEAN - if "True", this check will be skipped.
    .EXAMPLE
        ./recoveryServices.ps1 -subscriptionId <string> -subscriptionName <string> -skip <bool>
#>
[CmdletBinding()]
param(
  $subscriptionId,
  $subscriptionName,
  $skip
)

# Call in CreateReportItem function
. "./createReportFunction.ps1"

if($skip -eq "True") {
    Write-Host "##[warning] Skipping this step because the variable was set to true"
    Exit
}
# Get the list of vaults
$vaults = az backup vault list | ConvertFrom-JSON -AsHashTable
$report = @{}
$listVaults = @()

forEach($vault in $vaults) {
    # Identify backup items
    $backupItems = az backup item list --resource-group $vault.resourceGroup --vault-name $vault.name | ConvertFrom-JSON
    $backupJobs = az backup job list --resource-group $vault.resourceGroup --vault-name $vault.name | ConvertFrom-JSON
    forEach($job in $backupJobs) {
        if($job.properties.status -ne "Complete") {
            Write-Host "##[warning] Failed backup job detected for $($job.properties.entityFriendlyName)"
            CreateReportItem -item @{
                "subscriptionId"= $subscriptionId
                "subscriptionName" = $subscriptionName
                "impact" = "medium"
                "category" = "Recovery Services"
                "recommendation" = "Failed backup job detected for $($job.properties.entityFriendlyName)"
                "resourceGroup" = "$($job.resourceGroup)"
                "resource" = "$($vault.name)"
            }
        }
        Write-Host $job.properties.status
    }
    $listVaults += "$($vault.name)"
    $report | Add-Member -type NoteProperty -name "$($vault.name)" -Value @{
        "backupItems" = $backupItems
        "backupJobs" = $backupJobs
        }
}

$report | Add-Member -type NoteProperty -name vaults -Value $listVaults
$report = $report | ConvertTo-JSON -Depth 5
New-Item -Path . -Name "./reports/recoveryServices.json" -ItemType "file" -Value $report -Force