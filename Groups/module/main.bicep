// This is the main template for the deployment
targetScope = 'subscription'

// Get the location from the deployment
param location string = deployment().location
module resourcegroup '../resourcegroups/azuredeploy.bicep' = {
  name: 'resource-group'
  params: {
    resourceGroupName: ''
    location: location
  }
}
output name string = resourcegroup.outputs.name
output location string = resourcegroup.outputs.location
output resourceGroup string = resourcegroup.outputs.id
