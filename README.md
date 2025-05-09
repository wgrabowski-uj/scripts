###
# scripts

This repository contains PowerShell scripts to set up Azure Bastion and related resources. Currently, it includes the 

* bastion.ps1 script.

## Scripts

### 

bastion.ps1



The bastion.ps1

 script is meant to allow for VM and Bastion setup at the beginning of the day. It is meant to be used for setting up VM that uses Bastion paid tier, is meant to be used to listen to music in strict environments at work, and can be set up with 1-click. It automates the creation of an Azure Bastion host and its associated resources. It performs the following tasks:

1. **Define Variables**: Sets up necessary variables such as resource group name, location, virtual network name, subnet names, and address prefixes.
2. **Create Resource Group**: Creates a new resource group in the specified location.
3. **Create Virtual Network and Subnets**: 
   - Creates a virtual network with the specified address prefix.
   - Adds a subnet to the virtual network.
   - Adds a dedicated subnet for Azure Bastion.
4. **Create Public IP Addresses**: 
   - Creates a public IP address for the Bastion host.
   - Creates a public IP address for the virtual machine.
5. **Create Virtual Machine**: 
   - Creates a virtual machine in the specified resource group and location.
   - Starts the audio service on the virtual machine.
6. **Create Azure Bastion**: 
   - Creates an Azure Bastion host in the specified resource group and virtual network.
7. **Clean Up Resources**: (Optional) Stops the virtual machine and removes the resource group at the end of the day.

## Usage

1. Open PowerShell and navigate to the directory containing 

bastion.ps1

.
2. Run the script:
   ```powershell
   ./bastion.ps1
   ```

Ensure you have the necessary Azure PowerShell modules installed and are authenticated to your Azure account.

## Future Enhancements

- Add more scripts for different Azure setups.
- Improve error handling and logging.

---

This README will be updated as more scripts are added to the repository.