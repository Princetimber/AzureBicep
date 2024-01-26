param location string = resourceGroup().location
param sourceAddressPrefixes array
param dnsServers array
param addressPrefixes array
param subnets array
param gatewayAddressPrefixes array
param localGatewayPublicIpAddress string
param destinationAddressPrefix string
param connectionName string
param sharedKey string
param vnetneworexisting string
param subnetName string

// create network security group module
module nsg '../networkSecurityGroup/azuredeploy.bicep' = {
  name: 'network-security-group'
  params: {
    location: location
    sourceAddressPrefixes: sourceAddressPrefixes
    destinationAddressPrefix: destinationAddressPrefix
  }
}
output nsgId string = nsg.outputs.nsgId
output nsgName string = nsg.outputs.name

// create virtual network module
module vnet '../virtualNetworks/azuredeploy.bicep' = {
  name: 'virtual-network'
  params: {
    location: location
    vnetNewOrExisting: vnetneworexisting
    addressPrefixes: addressPrefixes
    subnets: subnets
    dnsServers: dnsServers
  }
  dependsOn: [
    nsg
  ]
}
output vnetId string = vnet.outputs.id
output vnetName string = vnet.outputs.name

//create module for gateways
module gateway '../gateways/azuredeploy.bicep' = {
  name: 'gateways'
  params: {
    location: location
    addressPrefixes: gatewayAddressPrefixes
    subnetName: subnetName
    localGatewayPublicIpAddress: localGatewayPublicIpAddress
  }
  dependsOn: [
    vnet
  ]
}

//create module for virtual network gateway connection
module connection '../VPN/azuredeploy.bicep' = {
  name: 'vpn-connection'
  params: {
    location: location
    connectionName: connectionName
    sharedKey: sharedKey
  }
  dependsOn: [
    gateway
  ]
}
output connectionName string = connection.outputs.name
