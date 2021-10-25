<#
    .DESCRIPTION
        Provide some information about the script and its pupose
    .PARAMETER subscriptionId
        STRING - The Azure Subscription ID that will be used in the report.csv
    .PARAMETER subscriptionName
        STRING - The Azure Subscription Friendly Name that will be used in the report.csv
    .PARAMETER days
        INT - number of days to check for expired VMs
    .PARAMETER skip
        BOOLEAN - if true, skip this step.
    .EXAMPLE
        ./expiredVMs.ps1 -subscriptionId <string> -subscriptionName <string> -days <int> -skip <bool>
#>
[CmdletBinding()]
param(
  $subscriptionId,
  $subscriptionName,
  $days,
  $skip
)

# Call in CreateReportItem function
. "./createReportFunction.ps1"

# Used to skip this particular check
if($skip -eq "True") {
    Write-Host "##[warning] Skipping this step because the variable was set to true"
    Exit
}

$vms = az vm list -d | ConvertFrom-JSON
$report = @{}
$expiredVMs = @()
$stoppedVMs = @()
$deallocatedVMs = @()
# Find and report virtual machines without boot diagnostics enabled
$missingBootDiag = @()

ForEach ($d in $vms) {
    # Find and report virtual machines without boot diagnostics enabled
    if ($d.diagnosticsProfile.bootDiagnostics.enabled -ne $true) {
        Write-Host "##[warning] Boot diagnostics is not enabled on $($d.name)"
        CreateReportItem -item @{
            "subscriptionId"= $subscriptionId
            "subscriptionName" = $subscriptionName
            "impact" = "low"
            "category" = "Virtual Machines"
            "recommendation" = "Detected a virtual machine without boot diagnostics enabled"
            "resourceGroup" = "$($d.resourceGroup)"
            "resource" = "$($d.name)"
        }
        $missingBootDiag += $d
    }
    else {
        if ($_.powerState -eq 'VM stopped') {
            $stoppedVMs += $_
        }
        elseif ($_.powerState -eq 'VM deallocated') {
            $deallocatedVMs += $_
        }
    }
}

Write-Host Number of stopped VMs: $stoppedVMs.Count
Write-Host Number of deallocated VMs: $deallocatedVMs.Count

if ($stoppedVMs.Count -ne 0) {
    foreach ($i in $stoppedVMs) {
        Write-Host "Getting SA"
        $sa = $i.diagnosticsProfile.bootDiagnostics.storageUri.substring(8).Split('.')[0]
        Write-Host "Getting Key"
        $key = az storage account keys list --account-name $sa | ConvertFrom-JSON
        Write-Host "Getting Container"
        $container = az storage container list --account-key $key[0].value --account-name $sa --query "[?contains(name, 'bootdiagnostics-$($i.name)')]" | ConvertFrom-JSON
        Write-Host "Getting Blob"
        $blob = az storage blob list --container-name $container.name --account-key $key[0].value --account-name $sa | ConvertFrom-JSON
        Foreach ($b in $blob) {
            if ($b.name.Substring($b.name.Length - 4) -eq ".log") {
                $today = Get-Date
                if ($b.properties.lastModified.addDays($days) -gt $today) {
                    Write-Host "Last booted within the last $days days"
                }
                else {
                    $expiredVMs += $i
                    Write-Host "##[warning] Last boot older than $days : $($i.name)"
                    CreateReportItem -item @{
                        "subscriptionId"= $subscriptionId
                        "subscriptionName" = $subscriptionName
                        "impact" = "medium"
                        "category" = "Virtual Machines"
                        "recommendation" = "Detected a stopped virtual machine that has not booted in $days"
                        "resourceGroup" = "$($i.resourceGroup)"
                        "resource" = "$($i.name)"
                    }
                }
            }
        }
    }
}

Write-Host Number of deallocated VMs: $deallocatedVMs.Count
if ($deallocatedVMs.Count -ne 0) {
    foreach ($u in $deallocatedVMs) {
        Write-Host "Getting SA"
        $sa = $u.diagnosticsProfile.bootDiagnostics.storageUri.substring(8).Split('.')[0]
        Write-Host "Getting Key"
        $key = az storage account keys list --account-name $sa | ConvertFrom-JSON
        Write-Host "Getting Container"
        $container = az storage container list --account-key $key[0].value --account-name $sa --query "[?contains(name, 'bootdiagnostics-$($u.name)')]" | ConvertFrom-JSON
        Write-Host "Getting Blob"
        $blob = az storage blob list --container-name $container.name --account-key $key[0].value --account-name $sa | ConvertFrom-JSON
        Foreach ($b in $blob) {
            if ($b.name.Substring($b.name.Length - 4) -eq ".log") {
                $today = Get-Date
                if ($b.properties.lastModified.addDays($days) -gt $today) {
                    Write-Host "Last booted within the last $days days"
                }
                else {
                    $expiredVMs += $u
                    Write-Host "##[warning] Last boot older than $days : $($u.name)"
                    CreateReportItem -item @{
                        "subscriptionId"= $subscriptionId
                        "subscriptionName" = $subscriptionName
                        "impact" = "low"
                        "category" = "Virtual Machines"
                        "recommendation" = "Detected a deallocated virtual machine without boot diagnostics enabled"
                        "resourceGroup" = "$($u.resourceGroup)"
                        "resource" = "$($u.name)"
                    }
                }
            }
        }
    }
}

$report | Add-Member -type NoteProperty -name expiredVMs -Value $expiredVMs
$report | Add-Member -type NoteProperty -name missingBootDiag -Value $missingBootDiag
$report = $report | ConvertTo-JSON -Depth 5
New-Item -Path . -Name "./reports/expiredVirtualMachines.json" -ItemType "file" -Value $report -Force