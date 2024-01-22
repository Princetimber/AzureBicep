// This is the main template for the deployment
targetScope = 'subscription'

// Get the location from the deployment
param location string = deployment().location
module resourgroup '../resourcegroups/azuredeploy.bicep' = {
  name: 'resource-group'
  params: {
    resourceGroupName: ''
    location: location
  }
}
