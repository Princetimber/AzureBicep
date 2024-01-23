param location string = resourceGroup().location
param sshPublicKeyName string = 'sshPublicKey'
resource sshPublicKey 'Microsoft.Compute/sshPublicKeys@2023-09-01' existing = {
  name: sshPublicKeyName
}
module storage '../storage/azuredeploy.bicep' = {
  name: 'storageAccount'
  params: {
    location: location
    publicIpAddress: ''
    subnets: [
      'gatewaySubnet'
      'subnet1'
      'subnet2'
    ]
    storageAccountMode: 'New'
  }
}
output storageAccountName string = storage.outputs.storageAccountName
output storageId string = storage.outputs.storageAccountResourceId

module linuxvm '../linux/azuredeploy.bicep' = {
  name: 'linux-vm'
  params: {
    location: location
    vmName: ''
    adminUsername: 'zadmin'
    aadClientId: ''
    tenantId: ''
    ubuntuOSVersion: 'Ubuntu-2204'
    adminPasswordOrKey: sshPublicKey.properties.publicKey
    authenticationType: 'sshPublicKey'
    autoShutdownNotificationEmail: ''
    subnetName: 'subnet1'
    dnsServers: [
      '' // private DNS server addresses
    ]

  }
}
