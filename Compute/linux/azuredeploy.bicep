@description('required:name of the VM to be created.')
param vmName string

@description('required: storage account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'

@description('required:size of the VM')
@allowed([
  'standard_DS1_v2'
  'standard_DS2_v2'
  'standard_DS3_v2'
  'standard_DS4_v2'
  'standard_DS5_v2'
  'standard_D2s_v3'
  'standard_D2_v3'
  'standard_D4s_v3'
])
param vmSize string = 'standard_D2s_v3'

@description('required: vm disk size in GB')
@minValue(60)
@maxValue(1024)
param vmDiskSize int = 128

@description('required: admin account username')
param adminUsername string

@description('optional: minimum number of VMs to be created. Default is 1.')
@minValue(1)
@maxValue(10)
param virtualMachineCount int = 1

@description('required:resource location. Default is resourcegroup location.')
param location string = resourceGroup().location

@description('required: availability set name. Default is resourcegroup name prefixed with avset.')
param availabilitySetName string = '${toLower(replace(resourceGroup().name, 'enguksouthrg', '-'))}avset'

@description('required:proximity placement group name. The name must be unique within the region. Default is resourcegroup name prefixed with ppg.')
param proximityPlacementGroupName string = '${toLower(replace(resourceGroup().name, 'enguksouthrg', '-'))}ppg'

@description('required: virtual network name. use an existing virtual network. The name must be unique within the region. Default is resourcegroup name prefixed with vnet.')
param vnetName string = '${toLower(replace(resourceGroup().name, 'enguksouthrg', '-'))}vnet'

@description('required: network interface name.')
param networkInterfaceName string = 'nic'

@description('Optional: dns servers for vm.')
param dnsServers array

@description('required: name of subnet where VMs will be created.')
@allowed([
  'subnet1'
  'subnet2'
])
param subnetName string

@description('autoshutdown status')
@allowed([
  'Enabled'
  'Disabled'
])
param autoShutdownStatus string = 'Enabled'

@description('autoshutdown time')
param autoShutdownTime string = '18:00'

@description('autoshutdown timezone')
param autoShutdownTimeZone string = 'GMT Standard Time'

@description('autoshutdown notification status')
@allowed([
  'Enabled'
  'Disabled'
])
param autoShutdownNotificationStatus string = 'Enabled'

@description('autoshutdown notification email')
param autoShutdownNotificationEmail string

@description('autoshutdown notification time in minutes')
param autoShutdownNotificationTimeInMinutes int = 30

@description('autoshutdown notification locale')
param autoShutdownNotificationLocale string = 'en'

@description('required:authentication type. Default is password. Recommended is sshPublicKey.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('Security Type of the Virtual Machine.')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
@allowed([
  'Ubuntu-1804'
  'Ubuntu-2004'
  'Ubuntu-2204'
])
param ubuntuOSVersion string = 'Ubuntu-2004'

var imageReference = {
  'Ubuntu-1804': {
    publisher: 'Canonical'
    offer: 'UbuntuServer'
    sku: '18_04-lts-gen2'
    version: 'latest'
  }
  'Ubuntu-2004': {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts-gen2'
    version: 'latest'
  }
  'Ubuntu-2204': {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-server-jammy'
    sku: '22_04-lts-gen2'
    version: 'latest'
  }
}

var virtualMachineCountRange = range(0, virtualMachineCount)
var linuxConfiguration = {
  disablePasswordAuthentication: true
  provisionVMAgent: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: ((authenticationType == 'sshPublicKey') ? adminPasswordOrKey : null)
      }
    ]
  }
  patchSettings: {
    assessmentMode: 'ImageDefault'
    patchMode: 'ImageDefault'
  }
}
var securityProfileJson = {
  securityType: securityType
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
}
var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.LinuxAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var maaEndpoint = substring('emptystring', 0, 0)
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource proximityPlacementGroup 'Microsoft.Compute/proximityPlacementGroups@2023-09-01' = {
  name: proximityPlacementGroupName
  location: location
  properties: {
    proximityPlacementGroupType: 'Standard'
    colocationStatus: {
      code: 'Aligned'
      displayStatus: 'Aligned'
      level: 'Error'
      message: 'Aligned'
    }
  }
}

resource availabilitySet 'Microsoft.Compute/availabilitySets@2023-09-01' = {
  name: availabilitySetName
  location: location
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 2
    proximityPlacementGroup: {
      id: proximityPlacementGroup.id
    }
  }
  sku: {
    name: 'Aligned'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = [for i in virtualMachineCountRange: {
  name: '${vmName}-${networkInterfaceName}${i + 1}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig${i + 1}'
        properties: {
          primary: true
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: dnsServers
    }
    nicType: 'Standard'
    enableIPForwarding: true
  }
}]

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-09-01' = [for i in virtualMachineCountRange: {
  name: '${vmName}${i + 1}'
  location: location
  properties: {
    availabilitySet: {
      id: availabilitySet.id
    }
    proximityPlacementGroup: {
      id: proximityPlacementGroup.id
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmName}-${networkInterfaceName}${i + 1}')
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${vmName}${i + 1}'
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'sshPublicKey') ? linuxConfiguration : null)
      allowExtensionOperations: true
    }
    storageProfile: {
      osDisk: {
        name: '${vmName}-osdisk${i + 1}'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diskSizeGB: vmDiskSize
        managedDisk: {
          storageAccountType: storageAccountType
        }
        deleteOption: 'Delete'
        osType: 'Linux'
      }
      imageReference: imageReference[ubuntuOSVersion]
    }
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
  }
  identity: {
    type: 'SystemAssigned'
  }
}]

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = [for i in virtualMachineCountRange: if ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true))) {
  parent: virtualMachine[i]
  name: extensionName
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: maaEndpoint
          maaTenantName: maaTenantName
        }
      }
    }
  }
}]

resource autoshutdown_computeVM 'Microsoft.DevTestLab/schedules@2018-09-15' = [for i in virtualMachineCountRange: {
  name: 'shutdown-computeVM-${vmName}${i + 1}'
  location: location
  properties: {
    status: autoShutdownStatus
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: autoShutdownTime
    }
    timeZoneId: autoShutdownTimeZone
    notificationSettings: {
      status: autoShutdownNotificationStatus
      notificationLocale: autoShutdownNotificationLocale
      emailRecipient: autoShutdownNotificationEmail
      timeInMinutes: autoShutdownNotificationTimeInMinutes
    }
    targetResourceId: resourceId('Microsoft.Compute/virtualMachines', '${vmName}${i + 1}')
  }
  dependsOn: [
    virtualMachine
  ]
}]

output vmNames array = [for i in virtualMachineCountRange: '${vmName}${i + 1}']
output vmIds array = [for i in virtualMachineCountRange: '${virtualMachine[i].id}']
output adminUsername string = adminUsername
output sshExecution array = [for i in virtualMachineCountRange: {
  name: '${vmName}${i + 1}'
  sshCommand: 'ssh ${adminUsername}@${nic[i].properties.ipConfigurations[i].properties.privateIPAddress} -i ~/.ssh/id_rsa'
}]
