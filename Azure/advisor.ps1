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

$recommendations = az advisor recommendation list | ConvertFrom-Json
foreach ($recommendation in $recommendations) {
    if ($recommendation.category -eq "Cost") {
        CreateReportItem -item @{
            "subscriptionId"= $subscriptionId
            "subscriptionName" = $subscriptionName
            "impact" = "medium"
            "category" = "Advisor Cost"
            "recommendation" = "$($recommendation.shortDescription.problem) - potential savings: $($recommendation.extendedProperties.annualSavingsAmount)  $($recommendation.extendedProperties.savingsCurrency) /year"
            "resourceGroup" = "$($recommendation.resourceGroup)"
            "resource" = ""
        }
    }
    elseif ($recommendation.category -eq "Performance") {
        CreateReportItem -item @{
            "subscriptionId"= $subscriptionId
            "subscriptionName" = $subscriptionName
            "impact" = "medium"
            "category" = "Advisor HighAvailability"
            "recommendation" = "$($recommendation.shortDescription.problem)"
            "resourceGroup" = "$($recommendation.resourceGroup)"
            "resource" = "$($recommendation.resourceGroup) / $($recommendation.impactedValue)"
        }
    }
    elseif ($recommendation.category -eq "HighAvailability") {
        CreateReportItem -item @{
            "subscriptionId"= $subscriptionId
            "subscriptionName" = $subscriptionName
            "impact" = "medium"
            "category" = "Advisor HighAvailability"
            "recommendation" = "$($recommendation.shortDescription.problem)"
            "resourceGroup" = "$($recommendation.resourceGroup)"
            "resource" = "$($recommendation.resourceGroup) / $($recommendation.impactedValue)"
        }
    }
    elseif ($recommendation.category -eq "OperationalExcellence") {
        CreateReportItem -item @{
            "subscriptionId"= $subscriptionId
            "subscriptionName" = $subscriptionName
            "impact" = "medium"
            "category" = "Advisor OperationalExcellence"
            "recommendation" = "$($recommendation.shortDescription.problem)"
            "resourceGroup" = "N/A"
            "resource" = ""
        }
    }
    elseif ($recommendation.category -eq "Security") {
        CreateReportItem -item @{
            "subscriptionId"= $subscriptionId
            "subscriptionName" = $subscriptionName
            "impact" = "medium"
            "category" = "Advisor Security"
            "recommendation" = "$($recommendation.shortDescription.problem)"
            "resourceGroup" = "$($recommendation.resourceGroup)"
            "resource" = "$($recommendation.resourceGroup) / $($recommendation.impactedValue)"
        }
    }

}