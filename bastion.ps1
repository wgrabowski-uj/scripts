# Variables
$resourceGroupName = "test2511_05"
$location = "northeurope"
$vmName = "Audio-Bastion1"
$vnetName = "MyVNet"
$subnetName = "MySubnet"
$addressPrefix = "10.0.0.0/16"
$subnetPrefix = "10.0.0.0/24"
$bastionName = "MyBastion"
$bastionSubnetName = "AzureBastionSubnet"
$bastionSubnetPrefix = "10.0.1.0/24"

# Create Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create Virtual Network and Subnet
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name $vnetName -AddressPrefix $addressPrefix
# Create Subnet
$subnet = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetPrefix -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

# Create Bastion Subnet
$bastionSubnet = Add-AzVirtualNetworkSubnetConfig -Name $bastionSubnetName -AddressPrefix $bastionSubnetPrefix -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

# Create Public IP for Bastion
$bastionPip = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name "$bastionName-Pip" -AllocationMethod Static -Sku Standard

# Create Public IP for VM
$vmPip = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name "$vmName-Pip" -AllocationMethod Static

#Get Subnet ID - couldn't find easier way
$vnet_temp = Get-AzVirtualNetwork

foreach ($network_temp in $vnet_temp)
{
    $subnets_temp = $network_temp.Subnets
    foreach ($subnet_temp in $subnets_temp)
    {
        if ($subnet_temp.Name -eq $subnetName -and $network_temp.ResourceGroupName -eq $resourceGroupName)
        {
            Write-Output $subnet_temp.Id
            $subnet_temp2 = $subnet_temp
        }
    }
}


# Create NIC for VM
$nic = New-AzNetworkInterface -Name "$vmName-NIC" -ResourceGroupName $resourceGroupName -Location $location -SubnetId $subnet_temp2.Id -PublicIpAddressId $vmPip.Id

# Create VM Configuration with Azure Spot
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_F2s_v2" -Priority "Spot" -MaxPrice -1

# Create the password by doubling the VM name and capitalizing the first letter
$password = -join(([char]::ToUpper($vmName[0]) + $vmName.Substring(1)) * 2)

# Create the credential object with the VM name as the username and the generated password
$credential = New-Object System.Management.Automation.PSCredential($vmName, (ConvertTo-SecureString $password -AsPlainText -Force))

# Set the VM operating system configuration
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $credential -ProvisionVMAgent -EnableAutoUpdate

# Set NIC for VM
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# Create the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig


# Wait for 2 minutes to ensure the VM is fully started
Start-Sleep -Seconds 60

# Start Audio Service
Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -VMName $vmName -CommandId 'RunPowerShellScript' -ScriptString 'net start audiosrv'

# Create Bastion
New-AzBastion -ResourceGroupName $resourceGroupName -Name $bastionName `
-PublicIpAddressRgName $resourceGroupName -PublicIpAddressName "$bastionName-Pip" `
-VirtualNetworkRgName $resourceGroupName -VirtualNetworkName $vnetName `
-Sku "Basic"


# Clean up resources at the end of the day
#Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force
#Remove-AzResourceGroup -Name $resourceGroupName -Force -AsJob
