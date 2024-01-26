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
  '100.68.0.0/16'
]
param subnets = [
  {
    name: 'gatewaySubnet'
    addressPrefix: '100.68.0.0/27'
  }
  {
    name: 'subnet1'
    addressPrefix: '100.68.1.0/24'
  }
]
param gatewayAddressPrefixes = [
  '10.0.1.0/29'
  '10.231.16.0/29'
]
param localGatewayPublicIpAddress = '62.31.74.157'
param destinationAddressPrefix = 'virtualNetwork'
param connectionName = 'azure-pfsense-connection'
param sharedKey = 'KZ@f$iYR8bbxa@w$tct5jDCe%Y@@g89&c#'
param subnetName = 'gatewaySubnet'
param vnetneworexisting = 'new'
