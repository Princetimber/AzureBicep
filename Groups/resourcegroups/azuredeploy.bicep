/*
  *This is a Bicep file. More info here: https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview
  *This file is used to deploy the Azure resources needed for the Azure DevOps pipeline.
  The resources are:
    - Resource Group
    - Resource Lock.
  The resource lock is used to prevent accidental deletion of the resource group.    
*/

targetScope = 'subscription'

@description('Required:The name of the resource group to create.')
param resourceGroupName string

@description('Require:location of the resource group. This defaults to the deployment location.')
param location string = deployment().location

@description('Optional:resource tags')
param resourceTags object = {
  Environment: 'Dev'
  DsplayName: 'Resource Group'
}

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: resourceTags
}
resource lock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: '${resourceGroupName}-lock'
  properties: {
    level: 'CanNotDelete'
  }
  dependsOn: [
    rg
  ]
}
output name string = rg.name
output location string = rg.location
output id string = rg.id
