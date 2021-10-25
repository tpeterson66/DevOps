<#
    .DESCRIPTION
        Report quota usage over percentage for Storage, Compute and Network. Network Watcher is skipped as it is a 1 and done object.
        Regions currently queried are all primary US location.
    .PARAMETER subscriptionId
        STRING - The Azure Subscription ID that will be used in the report.csv
    .PARAMETER subscriptionName
        STRING - The Azure Subscription Friendly Name that will be used in the report.csv
    .PARAMETER percentToReportOnQuotaUsage
        INT - The percentage of resource used before reporting on the Storage, Network and Compute Quota Limit.
    .PARAMETER skip
        BOOLEAN - Used to skip the scorecard check, pass True if you would like to skip this check in an environment        
    .EXAMPLE
        ./quotas.ps1 -subscriptionId <string> -subscriptionName <string> -skip <bool> -percentToReportOnQuotaUsage <int>
#>
[CmdletBinding()]
param(
  $subscriptionId,
  $subscriptionName,
  $skip,
  $percentToReportOnQuotaUsage

)

if($skip -eq "True") {
    Write-Host "##[warning] Skipping this step because the variable was set to true"
    Exit
}

# Call in CreateReportItem function
. "./createReportFunction.ps1"

$regions = @(
    'eastus',
    'eastus2',
    'southcentralus',
    'westus2',
    'centralus',
    'northcentralus',
    'westus'
    )

# Function: Calculate Impact Severity
function get-severity ($percentage){
    if ($percentage -eq 50 -or $percentage -lt 50){
        return "Low"
    }
    if ($percentage -eq 75 -or ($percentage -gt 50 -and $percentage -lt 75)){
        return "Medium"
    }
    if ($percentage -eq 100 -or ($percentage -gt 75 -and $percentage -lt 101)){
        return "High"
    }
}

foreach ($region in $regions) {
    # Gather Network Quota Information
    Write-Output "Collecting Network Quotas from $($region)"
    $netUsages = az network list-usages --location $region | ConvertFrom-JSON
    ForEach ($netUsage in $NetUsages){
        if ($netUsage.CurrentValue -ne 0){
            Write-Output "-Calculating $($netUsage.localName) usage in $($region)"
            $x = [int]$netUsage.currentValue 
            $y = [int]$netUsage.limit
            [int]$result = 100 * ($x / $y)
            Write-Output "--$($result)% of $($netUsage.localName) quota in use in $($region)"
            If (($netUsage.localName -notmatch 'Network Watchers') -and ($result -gt $percentToReportOnQuotaUsage)){
                CreateReportItem -item @{
                    "subscriptionId"= $subscriptionId
                    "subscriptionName" = $subscriptionName
                    "impact" = get-severity $result
                    "category" = "Subscription Quota"
                    "recommendation" = "$($result)% Quota Limit allocated for $($netUsage.localName) in $($region). Used: $x Limit: $y. Consider Extending the Quota Limit"
                    "resourceGroup" = "N/A"
                    "resource" = "$($region)/$($netUsage.localName)"
                }
            }
        }
    }
    # Gather Compute Quota Information
    Write-Output "Collecting Compute Quotas from $($region)"
    $vmUsages = az vm list-usage --location $region | ConvertFrom-JSON
    ForEach ($vmUsage in $vmUsages){
        if ($vmUsage.CurrentValue -ne 0){
            Write-Output "-Calculating $($vmUsage.localName) usage in $($region)"
            $x = [int]$vmUsage.currentValue 
            $y = [int]$vmUsage.limit
            [int]$result = 100 * ($x / $y)
            Write-Output "--$result % of $($vmUsage.localName) quota in use in $($region) Used: $x Limit: $y"
            If ($result -gt $percentToReportOnQuotaUsage){
                CreateReportItem -item @{
                    "subscriptionId"= $subscriptionId
                    "subscriptionName" = $subscriptionName
                    "impact" = get-severity $result
                    "category" = "Subscription Quota"
                    "recommendation" = "$($result)% Quota Limit allocated for $($vmUsage.localName) in $($region).  Used: $x Limit: $y. Consider Extending the Quota Limit"
                    "resourceGroup" = "N/A"
                    "resource" = "$($region)/$($vmUsage.localName)"
                }
            }
        }
    }
    # Gather Storage Account Quota Information
    Write-Output "Collecting Storage Account Quotas from $($region)"
    $storageUsages = az storage account show-usage --location $region | ConvertFrom-JSON
    ForEach ($storageUsage in $storageUsages){
        if ($storageUsage.CurrentValue -ne 0){
            Write-Output "-Calculating Storage Account usage in $($region)"
            $x = [int]$storageUsage.currentValue 
            $y = [int]$storageUsage.limit
            [int]$result = 100 * ($x / $y)
            Write-Output "--$result % of Storage Account quota in use in $($region) Used: $x Limit: $y"
            If ($result -gt $percentToReportOnQuotaUsage){
                CreateReportItem -item @{
                    "subscriptionId"= $subscriptionId
                    "subscriptionName" = $subscriptionName
                    "impact" = get-severity $result
                    "category" = "Subscription Quota"
                    "recommendation" = "$($result)% Quota Limit allocated for Storage Account in $($region). Used: $x Limit: $y. Consider Extending the Quota Limit"
                    "resourceGroup" = "N/A"
                    "resource" = "$($region)/Storage Account"
                }
            }
        }
    }
}