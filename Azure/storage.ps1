[CmdletBinding()]
param(
    $subscriptionId,
    $subscriptionName,
    $skip
)

if($skip -eq "True") {
    Write-Output "##[warning] Skipping this step because the variable skip was set to true"
    Exit
}

# Call in CreateReportItem function
. "./createReportFunction.ps1"

# Get the Storage Accounts
Write-Output "Getting all Storage Accounts in the subscription"
$sas = az storage account list | ConvertFrom-JSON
Write-Output "Found $($sas.count) Storage Accounts"
Write-Output "Getting a list of Virtual Machines in the Subscription"
$vms = az vm list -d | ConvertFrom-JSON

# Get the VM Boot Diagnostics Information
Foreach($sa in $sas) {
    Write-Output "-Getting Key for Storage Account: $($sa.name)"
    Try{
        $diagSaKey = "$(az storage account keys list -n $sa.name --query "[0].{value:value}" --output tsv)"
        If($diagSaKey){
            Write-Output "--Looking for Boot Diagnostics Containers within the Storage Account: $($sa.name) "
            $bdcontainers = az storage container list --account-key $diagSaKey --account-name $sa.name --query "[?contains(name, 'bootdiagnostics')]" | ConvertFrom-JSON
            If ($bdcontainers){
                Foreach ($bdcontainer in $bdContainers){
                    Write-Output "---Looking for screenshot.bmp Blobs within Container: $($bdContainer.name)"
                    $blobs = az storage blob list --container-name $bdcontainer.name --account-key $diagSaKey --account-name $sa.name --query "[?contains(name, '.screenshot.bmp')]" | ConvertFrom-JSON
                    If ($blobs){
                        Foreach ($blob in $blobs){
                            Write-Output "----Found Blob: $($blob.name)"
                            $vmName = $($blob.name).Split('.')[0]
                            #$resourceID = $($blob.name).Split('.')[1]
                            Write-Output "-----Looking for Virtual Machine: $($vmName)"
                            $vmObject = $vms | Where-Object Name -EQ $vmName
                            If($vmObject){
                                Write-Output "------Found $($vmObject.Name) and it is $($vmObject.powerState)"
                            }
                            Else{
                                Write-Output "------Unable to find VM: $($vmName)"
                                
                                CreateReportItem -item @{
                                    "subscriptionId"= $subscriptionId
                                    "subscriptionName" = $subscriptionName
                                    "impact" = "medium"
                                    "category" = "Storage"
                                    "recommendation" = "Boot Diagnotics with no VM Found"
                                    "resourceGroup" = "$($sa.resourceGroup)"
                                    "resource" = "$($sa.name)/$($bdcontainer.name)/$($blob.name)"
                                }
                            }
                        }
                    }
                    Else{
                        Write-Output "--No screenshot files found in diagnostics container $($bdcontainer.name) in Storage account $($sa.name). Checking for serialConsole.log"
                        $blobs = az storage blob list --container-name $bdcontainer.name --account-key $diagSaKey --account-name $sa.name --query "[?contains(name, '.serialconsole.log')]" | ConvertFrom-JSON
                        If ($blobs){
                            Foreach ($blob in $blobs){
                                Write-Output "----Found Blob: $($blob.name)"
                                $vmName = $($blob.name).Split('.')[0]
                                Write-Output "-----Looking for Virtual Machine: $($vmName)"
                                $vmObject = $vms | Where-Object Name -EQ $vmName
                                If($vmObject){
                                    Write-Output "------Found $($vmObject.Name) and it is $($vmObject.powerState)"
                                }
                                Else{
                                    Write-Output "------Unable to find VM: $($vmName)"

                                    CreateReportItem -item @{
                                        "subscriptionId"= $subscriptionId
                                        "subscriptionName" = $subscriptionName
                                        "impact" = "medium"
                                        "category" = "Storage"
                                        "recommendation" = "Boot Diagnotics with no VM Found"
                                        "resourceGroup" = "$($sa.resourceGroup)"
                                        "resource" = "$($sa.name)/$($bdcontainer.name)/$($blob.name)"
                                    }
                                }
                            }
                        }
                        Else{
                            Write-Output "WARNING: No Diagnostic Files found in Diagnostics Container: $($bdcontainer.name)"
                            
                            CreateReportItem -item @{
                                "subscriptionId"= $subscriptionId
                                "subscriptionName" = $subscriptionName
                                "impact" = "medium"
                                "category" = "Storage"
                                "recommendation" = "No Diagnostic Files found in Diagnostics Container"
                                "resourceGroup" = "$($sa.resourceGroup)"
                                "resource" = "$($sa.name)/$($bdcontainer.name)"
                            }
                        }
                    }
                }
            }
            Else{
                Write-Output "--No Boot Diagnostics Containers Found in $($sa.name)"
            }
        }
    }
    Catch{
        Write-Output "Unable to obtain storage key from $($sa.name)"
    }
}