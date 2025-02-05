#!/bin/bash

# Variables
resourceGroupName="MyResourceGroup"
location="northeurope"
vnetName="MyVnet"
subnetName="MySubnet"
nsgName="MyNSG"
vmNames=("VM1" "VM2" "VM3" "VM4" "VM5" "VM6" "VM7" "VM8" "VM9" "VM10")
vmSize="Standard_B1s"                     # Cheaper & available in North Europe
image="MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest"
username="azureuser"                      # Replace with your username
password="YourSecurePassword123!"         # Replace with your password

# Create Resource Group
az group create --name $resourceGroupName --location $location

# Create VNet and Subnet
az network vnet create \
  --resource-group $resourceGroupName \
  --name $vnetName \
  --address-prefix "10.0.0.0/16" \
  --subnet-name $subnetName \
  --subnet-prefix "10.0.1.0/24"

# Create Network Security Group (NSG)
az network nsg create --resource-group $resourceGroupName --name $nsgName

# Add NSG Rule to Allow RDP (Port 3389)
az network nsg rule create \
  --resource-group $resourceGroupName \
  --nsg-name $nsgName \
  --name AllowRDP \
  --priority 100 \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefix '*' \
  --source-port-range '*' \
  --destination-address-prefix '*' \
  --destination-port-range 3389 \
  --access Allow

# Deploy Spot VMs
for vmName in "${vmNames[@]}"; do
  az vm create \
    --resource-group $resourceGroupName \
    --name $vmName \
    --image $image \
    --size $vmSize \
    --vnet-name $vnetName \
    --subnet $subnetName \
    --nsg $nsgName \
    --admin-username $username \
    --admin-password $password \
    --priority Spot \
    --max-price -1 \
    --eviction-policy Deallocate \
    --no-wait               # Deploy VMs in parallel
done

# Wait for all VMs to deploy
az vm wait --created --ids $(az vm list -g $resourceGroupName --query "[].id" -o tsv)

# Configure VMs
for vmName in "${vmNames[@]}"; do
  # Disable IE Enhanced Security + Reboot
  az vm run-command invoke --name $vmName --resource-group $resourceGroupName \
    --command-id RunPowerShellScript --scripts '
      Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0 -ErrorAction Stop;
      Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0 -ErrorAction Stop;
      Restart-Computer -Force;
    '

  # Install Chrome
  az vm run-command invoke --name $vmName --resource-group $resourceGroupName \
    --command-id RunPowerShellScript --scripts '
      $TempDir = "$env:windir\Temp";
      $Installer = "chrome_installer.exe";
      Invoke-WebRequest "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile "$TempDir\$Installer" -ErrorAction Stop;
      Start-Process -FilePath "$TempDir\$Installer" -Args "/silent /install" -Verb RunAs -Wait -ErrorAction Stop;
      Remove-Item "$TempDir\$Installer" -ErrorAction SilentlyContinue;
    '
done
