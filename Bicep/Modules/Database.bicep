targetScope = 'subscription'

@description('Required. The Azure region the deployment is targeted to.')
param Deployment_location string
@description('Required')
param Deployment_locationCode string
@description('Optional. Tag object to inject into all resources in this module')
param Module_Tags object = {
  Module:'Database'
  LastModified: utcNow()
}

resource Database_RG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'database'
}

resource Network_RG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'network'
}


resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: '${Deployment_locationCode}-vnet-Example'
  scope: Network_RG
  
}

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: 'privatelink.database.windows.net'
  scope: Network_RG
}

@description('Required. Resource ID for Private DNS zone for private endpoint to be registered against')
param sqldatabase_privateDNSZoneResourceId string

module sqldatabase 'br/public:avm/res/sql/server:0.16.0' = {
  name:'Database_AzureSQLDatabase'
  scope:Database_RG
  params: {
    name: '${Deployment_locationCode}-sql-Example'
    location: Deployment_location
    administrators:{
      azureADOnlyAuthentication: true
      login: 'Some Group name' //To be replaced with Group name.
      principalType: 'Group'
      sid: 'Some Group Principal ID' //to be replaced with Principal ID guid
    }
    databases:[
      {
        name: 'ExampleAppDB1'
        availabilityZone: -1
        backupLongTermRetentionPolicy:{
          backupStorageAccessTier:'Archive'
          makeBackupsImmutable:true
          yearlyRetention:'P7Y'
          monthlyRetention:'P1M'
          weeklyRetention:'P6W'
          weekOfYear:18 //as of time of initial creating we are week 19, so 52 standard weeks later will be week 18 of the next year.
        }
        backupShortTermRetentionPolicy:{
          retentionDays:14
        }
        collation: 'SQL_Latin1_General_CP1_CI_AS'
        licenseType: 'BasePrice'
        sku:{
          name: 'GP_Gen5_2'
          tier: 'GeneralPurpose'
          capacity:2 //convert me to a parameter
          family:'Gen5'
        }
      } 
    ]    
    publicNetworkAccess:'Disabled'
    privateEndpoints:[
      {
        subnetResourceId: filter(vnet.properties.subnets, (s) => s.name == 'endpoints')[0].id
        privateDnsZoneGroup:{
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: sqldatabase_privateDNSZoneResourceId
            }
          ]
        }
      }
    ]

    tags:union({},Module_Tags)
  }
}
