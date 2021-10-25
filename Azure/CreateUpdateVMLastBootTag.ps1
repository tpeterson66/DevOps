<#
    .DESCRIPTION
        Function to update the virtual machine with lastboot tag including the date.
    .PARAMETER subscriptionId
        STRING - The Azure Subscription ID that will be used in the report.csv
    .PARAMETER subscriptionName
        STRING - The Azure Subscription Friendly Name that will be used in the report.csv
    .PARAMETER skip
        BOOLEAN - If true, this check is skipped
    .EXAMPLE
        ./CreateUpdateVMLastBootTag.ps1 -subscriptionId <string> -subscriptionName <string> -skip <bool>
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

# Get the VMs
Write-Host "Getting a list of virtual machines in the subscription"
$vms = az vm list -d | ConvertFrom-JSON
Write-Host "Found $($vms.count) virtual machines"
# Get the VM Boot Diagnostics Information and Set Boot Time Tag on VM
Foreach($vm in $vms) {
    if($vm.DiagnosticsProfile.bootDiagnostics.storageUri){
        Write-Host "Getting Boot Diag Information from $($vm.name)"
        $diagSaName = [regex]::match($vm.DiagnosticsProfile.bootDiagnostics.storageUri, '^http[s]?://(.+?)\.').groups[1].value
        $diagSaKey = "$(az storage account keys list -n $diagSaName --query "[0].{value:value}" --output tsv)"

        $vmNameNoDashes = $vm.Name -replace '-',''
        $vmTrimTo9characters = $vmNameNoDashes.subString(0, [System.Math]::Min(9, $vmNameNoDashes.Length))
        $diagContainerName = ('bootdiagnostics-{0}-{1}' -f $vmTrimTo9characters, $vm.vmId).ToLower()
        $serialConsoleLogFileName = $vm.Name + '.' + $vm.vmId + '.serialconsole.log'

        Write-Host "Getting Blob Information from $($vm.name)"
        $blobs = az storage blob list --container-name $diagContainerName --account-name $diagSaName --account-key $diagSaKey | ConvertFrom-JSON
        $serialConsoleLogFile = $blobs | Where-Object Name -eq $serialConsoleLogFileName
        $lastBootTime = $serialConsoleLogFile.Properties.lastModified

        # create-update Tag
        Write-Host "Setting Tag on $($vm.name)"
        az vm update --name $vm.Name --resource-group $vm.ResourceGroup --set tags.LastBootTime=$lastBootTime --output none
        Write-Host "Completed setting the boot time tag on $($vm.name) to $lastBootTime"
    }
    Else{
        Write-Host "No Boot Diagnostics Information found on $($vm.name)" 
        az vm update --name $vm.Name --resource-group $vm.ResourceGroup --set tags.LastBootTime="UnableToQueryBootTime" --output none
    }
}