param location string = resourceGroup().location
param objectId string
param tenantId string
param publicIpAddress string
param expirationDateInSeconds int
param notBeforeDateInSeconds int
param secretName string
@secure()
param secretValue string

module keyvault '../KeyVault/azuredeploy.bicep' = {
  name: 'key-vault'
  params: {
    location: location
    objectId: objectId
    tenantId: tenantId
    publicIpAddress: publicIpAddress
  }
}
output keyVaultName string = keyvault.outputs.name
output vaultId string = keyvault.outputs.id

module secret '../Secrets/azuredeploy.bicep' = {
  name: 'secrets'
  params: {
    expirationDateInSeconds: expirationDateInSeconds
    notBeforeDateInSeconds: notBeforeDateInSeconds
    secretName: secretName
    secretValue: secretValue
  }
  dependsOn: [
    keyvault
  ]
}
output secretName string = secret.outputs.name
output secretId string = secret.outputs.id
output version string = secret.outputs.version
