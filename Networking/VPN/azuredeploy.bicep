@description('Required: The name of the VPN connection.')
param connectionName string

@description('Required:The name of the virtual network gateway.This defaults to the name of the resource group prefixed with vnetgw.')
param vnetGatewayName string = '${toLower(replace(resourceGroup().name, 'enguksouthrg', '-'))}vnetgw'

@description('required: The name of the local network gateway. this defaults to the name of the resource group prefixed with lgw.')
param localNetworkGatewayName string = '${toLower(replace(resourceGroup().name, 'enguksouthrg', '-'))}lgw'

@description('Required:The shared key for the VPN connection.This is used to set the shared key for the connection between the virtual network gateway and the local network gateway.')
param sharedKey string

@description('Required: The location of the VPN connection. this defaults to the location of the resource group.')
param location string = resourceGroup().location

@description('Optional:The tags of the VPN connection.')
param tags object = {
  displayName: 'vpnConnection'
  environment: 'dev'
}

resource vnetGW 'Microsoft.Network/virtualNetworkGateways@2023-06-01' existing = {
  name: vnetGatewayName
}
resource localGW 'Microsoft.Network/localNetworkGateways@2023-06-01' existing = {
  name: localNetworkGatewayName
}
resource vpnConnection 'Microsoft.Network/connections@2023-06-01' = {
  name: connectionName
  location: location
  tags: tags
  properties: {
    connectionType: 'IPsec'
    sharedKey: sharedKey
    enableBgp: false
    routingWeight: 0
    virtualNetworkGateway1: {
      id: vnetGW.id
      location: vnetGW.location
      properties: {
        gatewayType: 'Vpn'
        vpnType: 'RouteBased'
        vpnGatewayGeneration: 'Generation2'
        sku: {
          name: 'VpnGw2'
          tier: 'VpnGw2'
        }
        allowRemoteVnetTraffic: true
        enableBgp: false
        activeActive: false
        enableBgpRouteTranslationForNat: false
        enableDnsForwarding: false
        enablePrivateIpAddress: true
      }
    }
    localNetworkGateway2: {
      id: localGW.id
      location: location
      properties: {
        gatewayIpAddress: localGW.properties.gatewayIpAddress
        localNetworkAddressSpace: {
          addressPrefixes: localGW.properties.localNetworkAddressSpace.addressPrefixes
        }
      }
    }
  }
}
output name string = vpnConnection.name
