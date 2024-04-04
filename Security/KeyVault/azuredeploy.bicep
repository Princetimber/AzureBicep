@description('required: name of the key vault to be created. This is unique across the entire Azure service, not just within the resource group. This defaults to a unique value.')
@maxLength(24)
param keyVaultName string = 'kv${uniqueString(resourceGroup().id)}'

@description('required: The name of the virtual network that will access the key vault. This usually will be an existing virtual network.')
param vnetName string = '${toLower(replace(resourceGroup().name, 'enguksouthrg', '-'))}vnet'

@description('required:The resource location. This will be one of the supported and registered Azure Geo Regions (e.g. West US, East US, Southeast Asia, etc.).This defaults to the location of the resource group.')
param location string = resourceGroup().location

@description('required: The resource tenant Id. This is the tenant Id of the Azure subscription that should be used for creating the key vault. This defaults to the tenant Id of the resource group.')
param tenantId string = subscription().tenantId

@description('required: public ip address for the local network.')
param publicIpAddress string

@description('required: azure AD object id for user or group.')
param objectId string

@description('Optional: The tags that will be assigned to the key vault. This defaults to an empty object (i.e. {}).')
param tags object = {
  environment: 'dev'
  displayName: 'keyvault'
}
@description('required: subnets allowed to access the key vault.')
param subnets array = [
  'gatewaySubnet'
  'subnet1'
]
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}
var virtualNetworkRules = [
for subnet in subnets: {
  id: '${vnet.id}/subnets/${subnet}'
}
]
resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: objectId
        permissions: {
          secrets: [
            'all'
          ]
          certificates: [
            'all'
          ]
          keys: [
            'all'
          ]
          storage: [
            'all'
          ]
        }
      }
    ]
    createMode: 'default'
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    enableRbacAuthorization: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          value: publicIpAddress
        }
      ]
      virtualNetworkRules: virtualNetworkRules
    }
    provisioningState: 'Succeeded'
  }
}
output id string = keyvault.id
output name string = keyvault.name
