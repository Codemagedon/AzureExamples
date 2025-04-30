targetScope = 'subscription'

resource Application_RG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'application'
}

resource Network_RG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'network'
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: '${Deployment_locationCode}-vnet-Example'
  scope: Network_RG
}

//Deployment wide parameters
@description('Required. The Azure region the deployment is targeted to.')
param Deployment_location string
@description('Required')
param Deployment_locationCode string


//Module Specific parameters
@description('Optional. Tag object to inject into all resources in this module')
param Module_Tags object = {
  Module:'Application'
  LastModified: utcNow()
}


//App service plan definition and parameters

module AppServicePlan 'br/public:avm/res/web/serverfarm:0.4.1' = {
  scope: Application_RG
  name:'Application${Deployment_locationCode}AppServicePlan'
  params: {
    name: '${Deployment_locationCode}-asp-Example'
    location:Deployment_location
    kind:'app'
    skuName:'P1v3'
    skuCapacity:3//set me to variable
    zoneRedundant:true
    tags:union({},Module_Tags)
  } 
}

//App service definition and parameters
module AppService  'br/public:avm/res/web/site:0.15.1' = {
  scope: Application_RG
  name:'Application${Deployment_locationCode}AppService'
  params: {
    name: '${Deployment_locationCode}-web-Example'
    kind: 'app'
    serverFarmResourceId: AppServicePlan.outputs.resourceId
    virtualNetworkSubnetId:filter(vnet.properties.subnets, (s) => s.name == 'application')[0].id
    tags:union({},Module_Tags)
  }
}

