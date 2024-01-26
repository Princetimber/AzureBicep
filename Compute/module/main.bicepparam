using './main.bicep'

param subnetName = 'subnet1'
param virtualMachineCount = 1
param sshPublicKeyName = 'sshPublicKeys'
param publicIpAddress = '62.31.74.157'
param subnets = [
  'gatewaySubnet'
  'subnet1'
]
param storageAccountMode = 'New'
param vmName = 'testvm'
param adminUsername = 'zadmin'
param ubuntuOSVersion = 'Ubuntu-2204'
param authenticationType = 'sshPublicKey'
param autoShutdownNotificationEmail = 'olamide@fountview.co.uk'
param dnsServers = [
  '10.0.3.2'
  '10.0.3.3'
  '1.1.1.1'
]
