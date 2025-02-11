# Connect to Azure
Connect-AzAccount

# Set variables
$resourceGroupName = "yourResourceGroup"
$vaultName = "yourVault"
$backupRetentionPeriod = (Get-Date).AddYears(-1)

# Get the Recovery Services vault
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $resourceGroupName -Name $vaultName
Set-AzRecoveryServicesVaultContext -Vault $vault

# Get all backup containers
$Containers = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM

foreach ($Container in $Containers) {
   # Get all backup items in the container
   $BackupItems = Get-AzRecoveryServicesBackupItem -Container $Container -WorkloadType AzureVM -VaultId $vault.ID

   foreach ($item in $BackupItems) {
       # Extract ResourceGroupName and VM Name from the backup item's name
       $itemDetails = $item.Name.Split(';')
       $resourceGroupName = $itemDetails[2]
       $vmName = $itemDetails[3]

       # Check if the VM is deleted
       $vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -ErrorAction SilentlyContinue
       if (-not $vm) {
           # Get all recovery points
           $recoveryPoints = Get-AzRecoveryServicesBackupRecoveryPoint -Item $item
           $pointsDeleted = $false

           foreach ($rp in $recoveryPoints) {
               # Check if the recovery point is older than the retention period
               if ($rp.RecoveryPointTime -lt $backupRetentionPeriod) {
                   # Delete the recovery point
                   Remove-AzRecoveryServicesBackupRecoveryPoint -RecoveryPoint $rp -Force
                   $pointsDeleted = $true
               }
           }

           if (-not $pointsDeleted) {
               Write-Output "No recovery points needed to be deleted for backup item: $vmName"
           }
       }
   }
}
