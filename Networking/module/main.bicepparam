using './main.bicep'

param sourceAddressPrefixes = [
  '62.31.74.157/32' // Add local network Public IP address here
  '10.0.1.0/29' // Add local network address space here
  '10.231.16.0/29'
]
param dnsServers = [
  '10.0.3.2'
  '10.0.3.3'
  '1.1.1.1'
]
param addressPrefixes = [
  '' //TODO: Add address space here for the virtual network. Use the CIDR notation, such as 10.0.0.0/16.
]
param subnets = [
  {
    name: 'gatewaySubnet'
    addressPrefix: '' //TODO: Add address space here for the gateway subnet. Use the CIDR notation, such as 10.0.0.0/27
  }
  {
    name: 'subnet1'
    addressPrefix: '' //TODO: Add address space here for the subnet. Use the CIDR notation, such as 10.0.0.0/24
  }
]
param gatewayAddressPrefixes = [
  '' //TODO: Add address space here for the gateway subnet. Use the CIDR notation, such as 192.168.0.1/24

]
param localGatewayPublicIpAddress = '' //TODO: Add local network Public IP address here
param destinationAddressPrefix = '' //TODO: Add destination address space here for the virtual network. Use the CIDR notation, such as 'virtualNetwork','*' or 'CIDR'
param connectionName = '' //TODO: Add connection name here
param sharedKey = '' //TODO: Add shared key here for the connection.
param subnetName = 'gatewaySubnet'
param vnetneworexisting = '' //TODO: Add new or existing vnet here. Options are 'new' or 'existing'. Default is 'new'
