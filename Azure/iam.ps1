<#
    .DESCRIPTION
        Get all the roles for a subscription and report them in a subscription-permissions.csv
    .PARAMETER subscriptionId
        STRING - The Azure Subscription ID that will be used in the report.csv
    .PARAMETER subscriptionName
        STRING - The Azure Subscription Friendly Name that will be used in the report.csv
    .PARAMETER skip
        BOOLEAN - Used to skip the scorecard check, pass True if you would like to skip this check in an environment
    .EXAMPLE
        ./iam.ps1 -subscriptionId <string> -subscriptionName <string> -skip <bool>
#>
[CmdletBinding()]
param(
  $subscriptionId,
  $subscriptionName,
  $skip
)

if($skip -eq "True") {
    Write-Host "##[warning] Skipping this step because the variable was set to true"
    Exit
}

# init permissions report
Add-Content -Path ./iam-reports/$($subscriptionId).csv -Value "PrincipalType,PrincipalName,RoleDefinition,Scope,SubscriptionId,SubscriptionName"

function UpdateCSV($item) {
        Add-Content -Path ./iam-reports/$($subscriptionId).csv -Value "$($item.principalType),$($item.principalName),$($item.roleDefinition),$($item.scope),$($subscriptionId),$($subscriptionName)"
}

# Loop through roles to get individual permissions
Foreach($role in $roles) {
    updateCSV @{
        "principalType" = $role.principalType
        "principalName" = $role.principalName
        "roleDefinition" = $role.roleDefinitionName
        "scope" = $role.scope
    }
}

$roles = $roles | ConvertTo-JSON -Depth 5
New-Item -Path . -Name "./reports/iam.json" -ItemType "file" -Value $roles -Force