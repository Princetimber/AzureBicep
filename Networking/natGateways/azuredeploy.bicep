@description('Required:location of the resource')
param location string = resourceGroup().location

@description('Required:name for the nat gateway. It defaults to the name of the resource group prefixed with natgw.')
param natGatewayName string = '${toLower(replace(resourceGroup().name, 'uksouthrg', ''))}natgw'

@description('Required: name of the public ip address. It defaults to resource name prefixed with pubIp.')
param publicIpName string = '${natGatewayName}pubIp'

@description('Required:name of subnet to deploy the nat gateway in')
param subnets array

@description('Required:name of the virtual network to deploy the nat gateway in')
param virtualNetworkName string = '${toLower(replace(resourceGroup().name, 'uksouthrg', ''))}vnet'

@description('Required:name of the network security group to deploy the nat gateway in')
param networkSecurityGroupName string = '${toLower(replace(resourceGroup().name, 'uksouthrg', ''))}nsg'

@description('Optional:tags to be added to the nat gateway')
param tags object = {
  environment: 'dev'
  DisplayName: 'Nat Gateway'
  Department: 'Engineering'
}

@description('Required: sku name of the nat gateway')
param skuName string = 'Standard'

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-06-01' existing = {
  name: networkSecurityGroupName
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-06-01' existing = {
  name: virtualNetworkName
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-06-01' = {
  name: publicIpName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: skuName
  }
}

resource natgw 'Microsoft.Network/natGateways@2023-06-01' = {
  name: natGatewayName
  location: location
  sku: {
    name: skuName
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: publicIp.id
      }
    ]
  }
  tags: tags
}
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-06-01' = [for subnet in subnets: {
  name: subnet
  parent: vnet
  properties: {
    addressPrefix: subnet.addressPrefix
    natGateway: subnet != 'gatewaySubnet' ? {
      id: natgw.id
    } : null
    networkSecurityGroup: {
      id: nsg.id
    }
    defaultOutboundAccess: true
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.keyvault'
      }
      {
        service: 'Microsoft.Sql'
      }
      {
        service: 'Microsoft.AzureActiveDirectory'
      }
      {
        service: 'Microsoft.web'
      }
      {
        service: 'Microsoft.ContainerRegistry'
      }
    ]
  }
}]
output id string = natgw.id
output name string = natgw.name
