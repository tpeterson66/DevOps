<#
    .DESCRIPTION
        Identify availability sets with less than 2 members
    .PARAMETER subscriptionId
        STRING - The Azure Subscription ID that will be used in the report.csv
    .PARAMETER subscriptionName
        STRING - The Azure Subscription Friendly Name that will be used in the report.csv
    .EXAMPLE
        ./availabilitySets.ps1 -subscriptionId <string> -subscriptionName <string> -skip <bool>
#>
[CmdletBinding()]
param(
  $subscriptionId,
  $subscriptionName,
  $skip
)

# Call in CreateReportItem function
. "./createReportFunction.ps1"

# Used to skip this particular check
if($skip -eq "True") {
    Write-Host "##[warning] Skipping this step because the variable was set to true"
    Exit
}

# Get all availability sets
$as = az vm availability-set list | ConvertFrom-JSON
$report = @()
# Report on any availability set with less than 2 virtual machines
Foreach ($a in $as) {
    if ($a.virtualMachines.Count -lt 2) {
        $report += $a # Add the item to the raw report
        CreateReportItem -item @{
            "subscriptionId"= $subscriptionId
            "subscriptionName" = $subscriptionName
            "impact" = "low"
            "category" = "Availability Set"
            "recommendation" = "Virutal Machine Availability Set detected with less than 2 members"
            "resourceGroup" = "$($a.resourceGroup)"
            "resource" = "$($a.name)"
        }
    }
}

if($report.Count -gt 0) {
    $report = $report | ConvertTo-Json
    New-Item -Path . -Name "./reports/availablitySet.json" -ItemType "file" -Value $report -Force
}