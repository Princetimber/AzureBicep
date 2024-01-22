/*
  This is a bicep file for the Azure Resource Manager (ARM) template.
  It is used to create a virtual network and with multiple sunnets.
*/
@description('Required: resource location. It defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('Required: virtual network resource name. It defaults to the resourcegroup name preffixed with vnet.')
param vnetName string = '${toLower(replace(resourceGroup().name, 'uksouthrg', ''))}vnet'

@description('Required: network security group resource name. It defaults to the resourcegroup name preffixed with nsg.')
param nsgName string = '${toLower(replace(resourceGroup().name, 'uksouthrg', ''))}nsg'

@description('Required: virtual network address prefixes. It is an array of strings.')
param addressPrefixes array

@description('Required: virtual network subnets. It is an array of objects.')
param subnets array

@description('Optional: tags. It is an object.')
param tags object = {
  environment: 'dev'
  DisplayName: 'Virtual Network'
}
@description('Optional: DNS servers. It is an array of strings.')
param dnsServers array

@description('Required: create new or existing virtual network. It defaults to new.')
@allowed([
  'new'
  'existing'
])
param vnetNewOrExisting string = 'new'

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-06-01' existing = {
  name: nsgName
}
var nsgId = nsg.id

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-06-01' = if (vnetNewOrExisting == 'new') {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
    for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        serviceEndpoints: [
          {
            service: 'Microsoft.Storage'
          }
          {
            service: 'Microsoft.Sql'
          }
          {
            service: 'Microsoft.AzureActiveDirectory'
          }
          {
            service: 'Microsoft.KeyVault'
          }
          {
            service: 'Microsoft.ContainerRegistry'
          }
          {
            service: 'Microsoft.EventHub'
          }
          {
            service: 'Microsoft.ServiceBus'
          }
          {
            service: 'Microsoft.Web'
          }
        ]
        networkSecurityGroup: subnet.name != 'gatewaySubnet' ? {
          id: nsgId
        } : null
      }
    }
    ]
    enableDdosProtection: false
    enableVmProtection: true
    dhcpOptions: {
      dnsServers: dnsServers
    }
  }
}
output name string = virtualNetwork.name
output id string = virtualNetwork.id
