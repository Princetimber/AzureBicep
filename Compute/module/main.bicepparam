using './main.bicep'

param subnetName = 'subnet1'
param virtualMachineCount = 1
param sshPublicKeyName = 'sshPublicKeys'
param publicIpAddress = '' //TODO: add public ip address for the local network to access the vm.
param subnets = [
  'gatewaySubnet'
  'subnet1'
]
param storageAccountMode = 'New'
param vmName = '' //TODO: add preferred name for vm to be created.
param adminUsername = '' //TODO: add preferred username for vm to be created.Note: username must not be admin.
param ubuntuOSVersion = 'Ubuntu-2204'
param authenticationType = 'sshPublicKey'
param autoShutdownNotificationEmail = '' //TODO: add email address to receive auto shutdown notification.
param dnsServers = [
  '' //TODO: add preferred dns server Ip address.
]
