param location string = resourceGroup().location
param virtualMachineCount int = 1
param sshPublicKeyName string = 'sshPublicKeys'
param publicIpAddress string
param subnets array
param subnetName string
param storageAccountMode string
param vmName string
param adminUsername string
param ubuntuOSVersion string
param authenticationType string
param autoShutdownNotificationEmail string
param dnsServers array
// use exisiting ssh public key
resource sshPublicKey 'Microsoft.Compute/sshPublicKeys@2023-09-01' existing = {
  name: sshPublicKeyName
}

// create storage account
module storage '../storage/azuredeploy.bicep' = {
  name: 'storageAccount'
  params: {
    location: location
    publicIpAddress: publicIpAddress
    subnets: subnets
    storageAccountMode: storageAccountMode
  }
}
output storageAccountName string = storage.outputs.storageAccountName
output storageId string = storage.outputs.storageAccountResourceId

// create linux vm
module linuxvm '../linux/azuredeploy.bicep' = {
  name: 'linux-vm'
  params: {
    location: location
    virtualMachineCount: virtualMachineCount
    vmName: vmName
    adminUsername: adminUsername
    ubuntuOSVersion: ubuntuOSVersion
    adminPasswordOrKey: sshPublicKey.properties.publicKey
    authenticationType: authenticationType
    autoShutdownNotificationEmail: autoShutdownNotificationEmail
    subnetName: subnetName
    dnsServers: dnsServers
  }
  dependsOn: [
    storage
  ]
}
output name array = [
  linuxvm.outputs.vmNames
]
output adminUsername string = linuxvm.outputs.adminUsername
output sshCommand array = [
  linuxvm.outputs.sshExecution
]
