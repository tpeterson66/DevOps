<#
    .DESCRIPTION
        Get all resource groups without any resources/objects and report them.
    .PARAMETER subscriptionId
        STRING - The Azure Subscription ID that will be used in the report.csv
    .PARAMETER subscriptionName
        STRING - The Azure Subscription Friendly Name that will be used in the report.csv
    .PARAMETER skip
        BOOLEAN - Used to skip the scorecard check, pass True if you would like to skip this check in an environment
    .EXAMPLE
        ./EmptyResourceGroups.ps1 -subscriptionId <string> -subscriptionName <string> -days <int> -skip <bool>
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

# Az CLI to get all resource groups
$allRGs = az group list | ConvertFrom-JSON

# finds any resource groups with 0 resources in them
ForEach ($rg in $allRGs){
    $resources = az resource list --query "[?resourceGroup == '$($rg.name)']" | ConvertFrom-JSON
    if ($resources.count -eq 0){
        Write-Host "##[warning] Detected an empty storage account: $($rg.name)"
        CreateReportItem -item @{
            "subscriptionId"= $subscriptionId
            "subscriptionName" = $subscriptionName
            "impact" = "medium"
            "category" = "Resource Groups"
            "recommendation" = "Resource group with no objects identified"
            "resourceGroup" = "$($rg.name)"
            "resource" = ""
        }
    }
}