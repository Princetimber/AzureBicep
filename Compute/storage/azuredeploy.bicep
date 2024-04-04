@description('The name of the storage account name to be created.This is a required parameter and must be unique within the resource group.')
@minLength(3)
@maxLength(24)
param storageAccountName string = '${uniqueString(resourceGroup().id)}stga'

@description('Required: storage sku name.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param skuName string = 'Standard_LRS'

@description('storage kind.')
@allowed([ 'Storage', 'StorageV2', 'BlobStorage', 'FileStorage', 'BlockBlobStorage' ])
param storageAccountKind string = 'StorageV2'

@description('storage access tier.')
@allowed([ 'Hot', 'Cool' ])
param storageAccountAccessTier string = 'Hot'

@description('resource location.')
param location string = resourceGroup().location

@description('resource tags.')
param tags object = {
  environment: 'dev'
  displayName: 'storage account'
}

@description('Required: The values of the publicIpAddress allowed to access the storage account.')
param publicIpAddress string

@description('Required: The name of the virtual network allowed to access the storage account.This defaults to the resource group name prefixed with vnet.')
param virtualNetworkName string = '${toLower(replace(resourceGroup().name, 'enguksouthrg', '-'))}vnet'

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: virtualNetworkName
}
@description('Required: Storage account mode to determine whether to create a new account or use an existing storage account.')
@allowed([ 'New', 'Existing' ])
param storageAccountMode string = 'New'

@description('Required: names of subnets allowed to access the storage account.')
@allowed([
  'gatewaySubnet'
  'subnet1'
  'subnet2'
])
param subnets array

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = if (storageAccountMode == 'New' && storageAccountName != '') {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: storageAccountKind
  properties: {
    accessTier: storageAccountAccessTier
    supportsHttpsTrafficOnly: true
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: [
      for subnet in subnets: {
        id: '${vnet.id}/subnets/${subnet}'
        action: 'Allow'
        state: 'Succeeded'
      }
      ]
      ipRules: [
        {
          value: publicIpAddress
          action: 'Allow'
        }
      ]
    }
    isNfsV3Enabled: false
    largeFileSharesState: 'Enabled'
    allowBlobPublicAccess: true
    allowCrossTenantReplication: true
    allowSharedKeyAccess: true
    isLocalUserEnabled: true
    minimumTlsVersion: 'TLS1_2'
    keyPolicy: {
      keyExpirationPeriodInDays: 90
    }
    immutableStorageWithVersioning: {
      enabled: true
      immutabilityPolicy: {
        immutabilityPeriodSinceCreationInDays: 30
        allowProtectedAppendWrites: true
        state: 'Unlocked'
      }
    }
  }
}
resource stga 'Microsoft.Storage/storageAccounts@2023-01-01' existing = if (storageAccountMode == 'Existing' && storageAccountName != '') {
  name: storageAccountName
}
output storageAccountName string = storageAccountMode == 'New' ? storageAccount.name : stga.name
output storageAccountResourceId string = storageAccountMode == 'New' ? storageAccount.id : stga.id
