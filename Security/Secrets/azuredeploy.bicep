@description('required: name of the key vault to be created. This is unique across the entire Azure service, not just within the resource group. This defaults to a unique value. An existing key vault with the same name cannot be reused.')
@maxLength(24)
param keyVaultName string = 'kv${uniqueString(resourceGroup().id)}'

@description('required: The name of the secret to be created. This is unique within a Key Vault and is used to identify the secret within a Key Vault.')
param secretName string

@description('required: The value of the secret to be created. This is the secret that will be stored and encrypted in Azure Key Vault.')
@secure()
param secretValue string

@description('Optional: The content type of the secret to be created. This is the content type of the secret value. Defaults to "text/plain".')
param contentType string = 'text/plain'

@description('Optional: The expiration date of the secret to be created. This is the expiration date of the secret value. If not specified, the secret will not expire.')
param expirationDateInSeconds int

@description('Optional: The not before date of the secret to be created. This is the not before date of the secret value. If not specified, the secret will be available immediately.')
param notBeforeDateInSeconds int

var attributes = {
  enabled: true
  exp: expirationDateInSeconds
  nbf: notBeforeDateInSeconds
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}
resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: secretName
  parent: keyVault
  properties: {
    value: secretValue
    attributes: attributes
    contentType: contentType
  }
}
output id string = secret.id
output name string = secret.name
output version string = secret.properties.secretUriWithVersion
