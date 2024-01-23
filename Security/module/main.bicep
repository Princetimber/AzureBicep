param location string = resourceGroup().location
module keyvault '../KeyVault/azuredeploy.bicep' = {
  name: 'key-vault'
  params: {
    location: location
    objectId: '' //object id of the user
    tenantId: '' //tenant id
    publicIpAddress: '' //public ip address allowed to access the key vault.
  }
}
output keyVaultName string = keyvault.outputs.name
output vaultId string = keyvault.outputs.id
module secret '../Secrets/azuredeploy.bicep' = {
  name: 'secrets'
  params: {
    expirationDateInSeconds: 1
    notBeforeDateInSeconds: 1
    secretName: ''
    secretValue: ''
  }
  dependsOn: [
    keyvault
  ]
}
output secretName string = secret.outputs.name
output secretId string = secret.outputs.id
output version string = secret.outputs.version

module sshPubKey '../ssh/azuredeploy.bicep' = {
  name: 'sshKey'
  params: {
    location: location
    name: 'sshPublicKey'
    publicKey: '' //public key
  }
}
