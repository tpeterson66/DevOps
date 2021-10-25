<#
    .DESCRIPTION
        Report on various networking items including unattached NICs, unused public IPs, etc.
    .PARAMETER subscriptionId
        STRING - The Azure Subscription ID that will be used in the report.csv
    .PARAMETER subscriptionName
        STRING - The Azure Subscription Friendly Name that will be used in the report.csv
    .PARAMETER utilizationValue
        INT - percentage value that should trigger a warning if the subnet is used more than this value
    .EXAMPLE
        ./networking.ps1 -subscriptionId <string> -subscriptionName <string> -utilizationValue <int> -skip <bool>
#>

# Incoming parameters passed by the command line
[CmdletBinding()]
param(
  $subscriptionId,
  $subscriptionName,
  $utilizationValue,
  $skip
)

# Call in CreateReportItem function
. "./createReportFunction.ps1"

# Used to skip this particular check
if($skip -eq "True") {
    Write-Host "##[warning] Skipping this step because the variable was set to true"
    Exit
}
# Report unused public IPs by running AZ CLI to check 
# all public IPs with an IP configuration of Null. This is done per subscription.
$report = @{}

<#
    Identify and report any network interface that is not attached to a virtual machine
#>
$unattachedNICs = az network nic list --query "[?virtualMachine == null]" | ConvertFrom-JSON
Write-Host "Count of unattached NICs: " $unattachedNICs.Count
foreach($_ in $unattachedNICs) {
    CreateReportItem -item @{
        "subscriptionId"= $subscriptionId
        "subscriptionName" = $subscriptionName
        "impact" = "low"
        "category" = "Networking"
        "recommendation" = "Network Interface is not attached to any virtual machines"
        "resourceGroup" = "$($_.resourceGroup)"
        "resource" = "$($_.name)"
    }
}
if($unattachedNICs.Count -ne 0) {
    $report | Add-Member -type NoteProperty -name unattachedNICs -Value $unattachedNICs
}

<#
    Identify and report any public ip addresses that are not attached to a NIC
#>
$unattachedPIPs = az network public-ip list --query "[?ipConfiguration==null]" | ConvertFrom-JSON
Write-Host "Count of unattached public IPs: " $unattachedPIPs.Count
foreach($_ in $unattachedPIPs) {
    CreateReportItem -item @{
        "subscriptionId"= $subscriptionId
        "subscriptionName" = $subscriptionName
        "impact" = "medium"
        "category" = "Networking"
        "recommendation" = "Public IP is not attached to a network interface"
        "resourceGroup" = "$($_.resourceGroup)"
        "resource" = "$($_.name)"
    }
}
if($unattachedPIPs.Count -ne 0) {
    $report | Add-Member -type NoteProperty -name unattachedPIPs -Value $unattachedPIPs
}

<#
    Identify any subnet that is 90% used
#>
$vnets = az network vnet list | ConvertFrom-JSON
Foreach($vnet in $vnets) {
    Foreach($subnet in $vnet.subnets) {
        if($subnet.addressPrefix) {
            $cidr = $subnet.addressPrefix.Split("/")[1]
            $used = $subnet.ipConfigurations.Count
            # Get the total number of IPs in a subnet
            $total = [Math]::Pow(2,32-$cidr)-2
            # Get the used percentage
            $percentUsed = [Math]::Round(($used / $total) * 100)
            if($percentUsed -gt $value) {
                CreateReportItem -item @{
                    "subscriptionId"= $subscriptionId
                    "subscriptionName" = $subscriptionName
                    "impact" = "medium"
                    "category" = "Networking"
                    "recommendation" = "vNet subnet is more than $utilizationValue used; current utilization is $($percentUsed)%"
                    "resourceGroup" = "$($vnet.resourceGroup)"
                    "resource" = "$($vnet.name)/$($subnet.name)"
                }
            }
        }
    }
}
<#
    Report all unused or unattached Network Security Groups
#>
$nsgs = az network nsg list | ConvertFrom-JSON
$emptyNSGs = @()
Foreach($nsg in $nsgs){
    If ($nsg.networkInterfaces.count -eq 0 -and $nsg.subnets.count -eq 0){
        $emptyNSGs += $nsg
        Write-Host "##[warning] Detected a unattached network security group: $($sng.name)"
        CreateReportItem -item @{
            "subscriptionId"= $subscriptionId
            "subscriptionName" = $subscriptionName
            "impact" = "medium"
            "category" = "Networking"
            "recommendation" = "Unattached Network Security Group Detected"
            "resourceGroup" = "$($nsg.resourceGroup)"
            "resource" = "$($nsg.name)"
        }
    }
}
if($emptyNSGs.Count -ne 0) {
    $report | Add-Member -type NoteProperty -name emptyNSGs -Value $emptyNSGs
}

# Export the raw data to a json file
$report = $report | ConvertTo-JSON -Depth 5
New-Item -Path . -Name "./reports/networking.json" -ItemType "file" -Value $report -Force