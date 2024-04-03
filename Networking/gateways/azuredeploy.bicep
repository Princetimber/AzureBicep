@description('Required: The name of the local gateway public IP address.The name defaults to the resource group name prefixed with lgwPubIp. This is the public IP address of the local gateway. It must be a unique to the local gateway provided by your service provider..')
param localGatewayPublicIpAddress string = '${toLower(replace(resourceGroup().name, 'enguksouthrg', '-'))}lgwPubIp'

@description('Required: The name of the local gateway. This is uniques and defaults to the resource group name prefixed with lgw.')
param localGatewayName string = '${toLower(replace(resourceGroup().name, 'enguksouthrg', '-'))}lgw'

@description('Required:The name for the virtual network. The name defaults to the resource group name prefixed with vnet.')
param vnetName string = '${toLower(replace(resourceGroup().name, 'enguksouthrg', '-'))}vnet'

@description('Required: The name for the virtual network gateway to be created. The name defaults to the resource group name prefixed with vnetgw.')
param vnetGatewayName string = '${toLower(replace(resourceGroup().name, 'enguksouthrg', '-'))}vnetgw'

@description('Required: The name the public IP address to be created. The name defaults to the resource group name prefixed with vnetGWPubIp.')
param PublicIpName string = '${toLower(replace(resourceGroup().name, 'enguksouthrg', '-'))}vnetGWPubIp'

@description('Required: The location where the virtual network gateway will be created.')
param location string = resourceGroup().location

@description('Required: The address prefixes of the local gateway.')
param addressPrefixes array

@description('Required: The name of the subnet where the virtual network gateway will be created.')
@allowed([
  'gatewaySubnet'
])
param subnetName string

@description('Optional: tags of the resource.')
param tags object = {
  environment: 'dev'
  displayName: 'virtual network gateway'
}

resource localNetworkGateway 'Microsoft.Network/localNetworkGateways@2023-09-01' = {
  name: localGatewayName
  location: location
  tags: {
    environment: 'dev'
    displayName: 'local Gateway' }
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: addressPrefixes
    }
    gatewayIpAddress: localGatewayPublicIpAddress
  }
}
output localNetworkGatewayId string = localNetworkGateway.id
output localNetworkGatewayName string = localNetworkGateway.name

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}
resource pubIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: PublicIpName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: 'Standard'
  }
  dependsOn: [
    vnet
  ]
}
resource vnetGateway 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  name: vnetGatewayName
  location: location
  tags: tags
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation2'
    sku: {
      name: 'VpnGw2'
      tier: 'VpnGw2'
    }
    ipConfigurations: [
      {
        name: pubIp.name
        id: pubIp.id
        properties: {
          publicIPAddress: {
            id: pubIp.id
          }
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
        }
      }
    ]
  }
}
output vnetGatewayId string = vnetGateway.id
output vnetGatewayName string = vnetGateway.name
