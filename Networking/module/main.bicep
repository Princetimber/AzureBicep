param location string = resourceGroup().location
param sourceAddressPrefixes array = [
  '62.31.74.157' // Add local network Public IP address here
  '10.0.1.0/28' // Add local network address space here
  '10.0.4.0/24'
]
param subnets array = [
  {
    name: 'gatewaySubnet'
    addressPrefix: '100.16.0.0/27'
  }
  {
    name: 'subnet1'
    addressPrefix: '100.16.1.0/24'
  }
  {
    name: 'subnet2'
    addressPrefix: '100.16.2.0/24'
  }
]
param dnsServers array = [
  '10.0.3.2'
  '10.0.3.3'
  '1.1.1.1'
]
param destinationAddressPrefix string = 'virtualNetwork'
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
    vnetNewOrExisting: 'new'
    addressPrefixes: [
      '17.25.0.0/16'
    ]
    subnets: [
      {
        name: 'gatewaySubnet'
        addressPrefix: '17.25.0.0/27'
      }
      {
        name: 'subnet1'
        addressPrefix: '17.25.1.0/24'
      }
      {
        name: 'subnet2'
        addressPrefix: '17.25.2.0/24'
      }
    ]
    dnsServers: dnsServers
  }
  dependsOn: [
    nsg
  ]
}
output vnetId string = vnet.outputs.id
output vnetName string = vnet.outputs.name

//create module for nat gateway
module natgw '../natGateways/azuredeploy.bicep' = {
  name: 'nat-gateway'
  params: {
    location: location
    subnets: subnets
  }
  dependsOn: [
    vnet
  ]
}
output natgwId string = natgw.outputs.id
output natgwName string = natgw.outputs.name
