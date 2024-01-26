@description('Required:network security group location')
param location string = resourceGroup().location

@description('Required:name of the network security group to create.This must be unique within the resource group and can not be changed after creation. It defaults to the resource group name prefixed with nsg.')
param name string = '${toLower(replace(resourceGroup().name, 'enguksouthrg', '-'))}nsg'

@description('Required: source address prefixes, which includes the IP address range or CIDR block for the source of the rule. This can be internet, virtual network, subnet, or IP address or Public IP Address based on the service.')
param sourceAddressPrefixes array

@description('Required: destination address prefix. This can also be a CIDR block, virtual network, or service tag or Ip Address based on the service.')
param destinationAddressPrefix string

@description('Optional:tags of the network security group to create.')
param tags object = {
  displayName: 'Network Security Group'
  Environment: 'Development'
}

// Security rules
var securityRules = [
  {
    name: 'allow_https_inbound'
    properties: {
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp'
      priority: 200
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: destinationAddressPrefix
      destinationPortRange: '443'
      description: 'Allow HTTPS inbound traffic'
    }
  }
  {
    name: 'allow_http_inbound'
    properties: {
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp'
      priority: 201
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: destinationAddressPrefix
      destinationPortRange: '80'
      description: 'Allow HTTP inbound traffic'
    }
  }
  {
    name: 'allow_rdp_inbound'
    properties: {
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp'
      priority: 202
      sourceAddressPrefixes: sourceAddressPrefixes
      sourcePortRange: '*'
      destinationAddressPrefix: destinationAddressPrefix
      destinationPortRange: '3380-3400'
      description: 'Allow RDP inbound traffic'
    }
  }
  {
    name: 'allow_ssh_inbound'
    properties: {
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp'
      priority: 203
      sourceAddressPrefixes: sourceAddressPrefixes
      sourcePortRange: '*'
      destinationAddressPrefix: destinationAddressPrefix
      destinationPortRange: '22'
      description: 'Allow SSH inbound traffic'
    }
  }
  {
    name: 'allow_winrm_inbound'
    properties: {
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp'
      priority: 204
      sourceAddressPrefixes: sourceAddressPrefixes
      sourcePortRange: '*'
      destinationAddressPrefix: destinationAddressPrefix
      destinationPortRange: '5985'
      description: 'Allow WinRM inbound traffic'
    }
  }
  {
    name: 'allow_dns_inbound'
    properties: {
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp'
      priority: 205
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: destinationAddressPrefix
      destinationPortRange: '53'
    }
  }
  {
    name: 'allow_ntp_inbound'
    properties: {
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Udp'
      priority: 206
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: destinationAddressPrefix
      destinationPortRange: '123'
      description: 'Allow NTP inbound traffic'
    }
  }
]
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    flushConnection: false
    securityRules: securityRules
  }
}
output nsgId string = nsg.id
output name string = nsg.name
