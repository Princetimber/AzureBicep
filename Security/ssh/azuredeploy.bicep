@description('required: Thename of ssh Public key to be created.')
param name string

@description('required: The resource location. It must be one of the supported Azure locations. It defaults to the resource group location.')
param location string = resourceGroup().location

resource sshPublicKey 'Microsoft.Compute/sshPublicKeys@2023-09-01' = {
  name: name
  location: location
  properties: {}
  tags: {
    environment: 'dev'
    DisplayName: 'sshPublicKey'
  }
}
