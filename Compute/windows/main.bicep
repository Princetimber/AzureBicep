param location string = resourceGroup().location
param secretName string = 'adminPassphrase'
param certificateName string = 'i365Cert'
param vmName string = 'windows-vm'
param adminUsername string = 'zadmin'
param customScriptExtensionUri string = 'https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vm-custom-script-windows/azuredeploy.json'
param autoShutdownNotificationEmail string = 'joe.bloggs@contoso.com'
param keyvaultName string = 'kv${uniqueString(resourceGroup().id)}'
resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyvaultName
}
module virtualMachine 'azuredeploy.bicep' = {
  name: 'windows-vm'
  params: {
    location: location
    adminPassword: keyvault.getSecret(secretName)
    adminUsername: adminUsername
    vmName: vmName
    autoShutdownNotificationEmail: autoShutdownNotificationEmail
    certificateName: certificateName
    customScriptExtensionUri: customScriptExtensionUri
    dnsServers: [
      '' //TODO: add DNS servers here
    ]
    subnetName: 'subnet1'
    vmSize: 'standard_D2s_v3'
  }
}
output vmName array = [
  virtualMachine.outputs.virtualMachineNames
]
output vmId array = [
  virtualMachine.outputs.virtualMachineIds
]
output adminUsername array = [
  virtualMachine.outputs.adminUsername
]
