﻿function Find-AzVms() {

    param
    (
        [Parameter(Mandatory=$true)] [array] $SubscriptionList,
        [Parameter(Mandatory=$false)] [string] $ExportFilePath,
        [Parameter(Mandatory=$false)] [string] $ExportFileFormat,
        [Parameter(Mandatory=$false)] [string] $Delimiter
    )

    Import-Module Az.Compute
    Import-Module Az.Accounts
    Import-Module Az.Network

    # Initialize array
    $report = @()

    # Initialize export if ExportFilePath specified
    If(-not [string]::IsNullOrEmpty($ExportFilePath)){
    
        # Default format is csv
        If([string]::IsNullOrEmpty($ExportFileFormat)){$ExportFileFormat = "csv"}
        
        # Check ExportFileFormat and format export
        Switch ($ExportFileFormat.ToLower()) {

            "csv"  {$export = @(); break}

            "json" {$export = @{}; break}

            default {Write-Host "ExportFileFormat : $ExportFileFormat not supported" ; return -1 ; break}

        }
    }

    ForEach ($subscriptionId in $subscriptionList)
    {
        Select-AzSubscription $subscriptionId
        $SubscriptionName = (Select-AzSubscription $subscriptionId).Name

        # Gets list of all Virtual Machines
        $vms = Get-AzVM

        # Gets list of all public IPs
        $publicIps = Get-AzPublicIpAddress

        # Gets list of network interfaces attached to virtual machines
        $nics = Get-AzNetworkInterface | Where-Object { $_.VirtualMachine -NE $null} 

        # Gets number of VMs
        $VmsCounter = 0

        foreach ($nic in $nics) {
            
            # Display progress
            $VmsCounter = $VmsCounter+1
            $PercentComplete = (100/$nics.Count)*$VmsCounter
            $ProgressMessage = "Getting informations for " + $vm.Name + " in " + $SubscriptionName
            Write-Progress -Activity $ProgressMessage -PercentComplete $PercentComplete

            # Get attached Virtual Machine
            $vm = $vms | Where-Object -Property Id -eq $nic.VirtualMachine.id

            # $info will store current VM info
            $info = "" | Select Subscription, VmName, VmSize, ResourceGroupName, Region, VirtualNetwork, Subnet, PrivateIpAddress, PublicIPAddress, OSVersion, OsType

            # Subscription
            $info.Subscription = (Select-AzSubscription $subscriptionId).Name

            # VmName
            $info.VmName = $vm.Name
            
            # VmSize
            $info.VmSize = $vm.HardwareProfile.VmSize

            # ResourceGroupName
            $info.ResourceGroupName = $vm.ResourceGroupName

            # Region
            $info.Region = $vm.Location

            # VirtualNetwork
            $info.VirtualNetwork = $nic.IpConfigurations.subnet.Id.Split("/")[-3]

            # Subnet
            $info.Subnet = $nic.IpConfigurations.subnet.Id.Split("/")[-1]
        
            # Private IP Address
            $info.PrivateIpAddress = $nic.IpConfigurations.PrivateIpAddress

            # NIC's Public IP Address, if exists
            foreach($publicIp in $publicIps) { 
            if($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) {
                $info.PublicIPAddress = $publicIp.ipaddress
                }
            }
        
            # OsVersion
            $info.OsVersion = $vm.StorageProfile.ImageReference.Offer + ' ' + $vm.StorageProfile.ImageReference.Sku

            # OsType
            $info.OsType = $vm.StorageProfile.OsDisk.OsType

            # Append
            $report+=$info

        }

    }

    # Output to a file if ExportFilePath specified
    If(-not [string]::IsNullOrEmpty($ExportFilePath)){

        Switch ($ExportFileFormat.ToLower()) {

        # Export to CSV
        "csv"  {

                    # Default delimiter
                    If([string]::IsNullOrEmpty($Delimiter)){
                        $report | Export-CSV -path $ExportFilePath
                    }
                    # Delimiter specified
                    Else {
                        $report | Export-CSV -path $ExportFilePath -Delimiter $Delimiter
                    }

                    ; break

                }

        # Export to JSON
        "json" {
        
                    # $export = @{}
                    $JsonSubscriptionList = $report | Select-Object -Unique -property subscription
        
                    ForEach ($JsonSubscription in $JsonSubscriptionList) {

                        $JsonVnetList = $report | Where-Object -Property Subscription -eq $JsonSubscription.Subscription | Select-Object -Unique -property VirtualNetwork
                        $export[$JsonSubscription.Subscription] = @{
                            Name = $JsonSubscription.Subscription
                            VirtualNetworks = @{}
                        }

                        ForEach ($JsonVnet in $JsonVnetList) {

                            $JsonSubnetList = $report | Where-Object -Property Subscription -eq $JsonSubscription.Subscription  | Where-Object -Property VirtualNetwork -eq $JsonVnet.VirtualNetwork | Select-Object -Unique -property Subnet
                            $export[$JsonSubscription.Subscription]["VirtualNetworks"][$JsonVnet.VirtualNetwork] = @{
                                Name = $JsonVnet.VirtualNetwork
                                Subnets = @{}
                            }

                            ForEach ($JsonSubnet in $JsonSubnetList) {

                                $JsonVmsList = $report | Where-Object -Property Subscription -eq $JsonSubscription.Subscription  | Where-Object -Property VirtualNetwork -eq $JsonVnet.VirtualNetwork | Where-Object -Property Subnet -eq $JsonSubnet.Subnet | Select-Object -Unique -property VmName,VmSize,ResourceGroupName,Region,PrivateIpAddress,PublicIPAddress,OSVersion,OsType
                                $export[$JsonSubscription.Subscription]["VirtualNetworks"][$JsonVnet.VirtualNetwork]["Subnets"][$JsonSubnet.Subnet] = @{
                                    Name = $JsonSubnet.Subnet
                                    Vms = @{}
                                }

                                ForEach ($JsonVm in $JsonVmsList) {

                                    $export[$JsonSubscription.Subscription]["VirtualNetworks"][$JsonVnet.VirtualNetwork]["Subnets"][$JsonSubnet.Subnet]["Vms"][$JsonVm.VmName] = @{
                                        Name = $JsonVm.VmName
                                        Size = $JsonVm.VmSize
                                        ResourceGroupName = $JsonVm.ResourceGroupName
                                        Region = $JsonVm.Region
                                        PrivateIpAddress = $JsonVm.PrivateIpAddress
                                        PublicIPAddress = $JsonVm.PublicIPAddress
                                        OSVersion = $JsonVm.OSVersion
                                        OsType = $JsonVm.OsType.ToString()
                                    }

                                }

                            }

                        }

                    }

                    $export | ConvertTo-Json -Depth 7| out-file $ExportFilePath

                    ; break

                }

        }

    }

    return $report

}