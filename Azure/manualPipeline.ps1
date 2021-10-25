Write-Host "Hold on to your butts" -ForegroundColor Magenta
$accounts = az account list | ConvertFrom-Json

# Create a reports folder for storing results
New-Item -ItemType Directory -Force -Path ./reports

foreach($account in $accounts) {
    Write-Host "Running Scorecard Script for the following subscription:" -ForegroundColor Yellow
    Write-Host "Subscription ID: $($account.id)" -ForegroundColor Yellow
    Write-Host "Subscription Name: $($account.name)" -ForegroundColor Yellow
    $confirmation = Read-Host "Are you Sure You Want To Proceed (yes/no)"
    if ($confirmation -eq 'yes') {
        Write-Host "Setting az account:" -ForegroundColor Green
        az account set --subscription "$($account.id)"
        az account show
        Write-Host "Availability Sets" -ForegroundColor Green
        & "./ReportAvailabilitySets.ps1"
        Write-Host "Disks" -ForegroundColor Green
        & "./disks.ps1"
        Write-Host "Expired VMs" -ForegroundColor Green
        & "./expiredVMs.ps1"
        Write-Host "IAM Roles" -ForegroundColor Green
        & "./iam.ps1"
        Write-Host "Keyvault" -ForegroundColor Green
        & "./iam.ps1"
        Write-Host "Networking" -ForegroundColor Green
        & "./networking.ps1"
        Write-Host "Recovery Services" -ForegroundColor Green
        & "./recoveryServices.ps1"
        Write-Host "Resource Groups" -ForegroundColor Green
        & "./resourceGroups.ps1"
        Write-Host "Storage" -ForegroundColor Green
        & "./storage.ps1"
        Write-Host "Virtual Machines" -ForegroundColor Green
        & "./virtualMachines.ps1"
 
        # ZIP results and store them in a file with the subscription id.
        Compress-Archive -Path .\reports\*.json -DestinationPath ./reports/$($account.id).zip
        Remove-Item ./reports/*.json
    }
}