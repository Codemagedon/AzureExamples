targetScope = 'subscription'
  @allowed([
    'uksouth'
    'ukwest'
  ])
  @description('Required. The deployment Region of the')
param Deployment_location string 
//short name temp table
var temp_RegionShortNames = {
   'uksouth': 'uks'
    'ukwest': 'ukw'
}
//short name lookup commands.
var Deployment_locationCode = temp_RegionShortNames[Deployment_location]

param Network_VirtualNetwork_addressPrefixes array

module Network 'Modules/Network.bicep' = {
  params: {
    Deployment_location: Deployment_location
    Deployment_locationCode: Deployment_locationCode
    VirtualNetwork_addressPrefixes:Network_VirtualNetwork_addressPrefixes
  }
}

module database 'Modules/Database.bicep' = {
  params:{
    Deployment_location: Deployment_location
    Deployment_locationCode: Deployment_locationCode
    sqldatabase_privateDNSZoneResourceId: Network.outputs.PrivateDNSZoneAzureSQL_Name
    
  }
}

module application 'Modules/app.bicep' = {
  
}
