<#
    .DESCRIPTION
        Get all keyvaults in the current subscription and check the keyvaults for expired 
        certificates, secrets, and keys.
    .PARAMETER subscriptionId
        STRING - The Azure Subscription ID that will be used in the report.csv
    .PARAMETER subscriptionName
        STRING - The Azure Subscription Friendly Name that will be used in the report.csv
    .PARAMETER skip
        BOOLEAN - Used to skip the scorecard check, pass True if you would like to skip this check in an environment
    .EXAMPLE
        ./virtualMachines.ps1 -subscriptionId <string> -subscriptionName <string> -skip <bool>
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

# Get the VMs
$vms = az vm list -d | ConvertFrom-JSON

$report = @()

# Find all stopped VMs
$stoppedVMs = @()
# $deallocatedVMs = @()
Foreach($vm in $vms) {
    if($vm.powerState -eq 'VM stopped') {
        Write-Host "##[warning] Found stopped VM: $(vm.name)"
        CreateReportItem -item @{
            "subscriptionId"= $subscriptionId
            "subscriptionName" = $subscriptionName
            "impact" = "medium"
            "category" = "Key Vault"
            "recommendation" = "Certificate Expiration Warning - $($certificate.name) will expire on $($certificate.attributes.expires)"
            "resourceGroup" = "$($keyvault.resourceGroup)"
            "resource" = "$($keyvault.name)/$($certificate.name)"
        }
        $stoppedVMs += $vm
    } 
}
Write-Host "Number of stopped VMs: " $stoppedVMs.Count
if($stoppedVMs.Count -ne 0) {
    $report += @{
        "stoppedVMs" = $stoppedVMs
    }
}

if($report.Count -ne 0) {  
    $report = $report | ConvertTo-JSON -Depth 5
    New-Item -Path . -Name "./reports/virtualMachines.json" -ItemType "file" -Value $report -Force
}