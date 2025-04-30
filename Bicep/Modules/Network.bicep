targetScope = 'subscription'

@description('Required. The Azure region the deployment is targeted to.')
param Deployment_location string
@description('Required')
param Deployment_locationCode string
@description('Optional. Tag object to inject into all resources in this module')
param Module_Tags object = {
  Module:'Network'
  LastModified: utcNow()
}


resource Network_RG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'network'
}


@description('Requred. List of CIDR ranges to assign to the virtual network. [must be /24 or larger]')
param VirtualNetwork_addressPrefixes array = [
  '10.0.0.0/23'
]

//Convert list of CIDR strings provided into CIDR objects
var cidrs = [for cidr in VirtualNetwork_addressPrefixes: parseCidr(cidr) ]
//Sort CIDR objects by smallest CIDR value(largest IP pool) and select the 1st object in the array as the primary IP pool.
var primaryCIDR = sort(cidrs, (x,y) => x.cidr < y.cidr)[0]


module VirtualNetwork 'br/public:avm/res/network/virtual-network:0.6.1' = {
  scope: Network_RG
  params: {
    name: '${Deployment_locationCode}-vnet-Example'
    location:Deployment_location
    addressPrefixes: [
      VirtualNetwork_addressPrefixes
    ]
    subnets:[
      {
        name: 'application'
        addressPrefix:cidrSubnet(primaryCIDR.network,25,0)
        delegation:'Microsoft.Web/serverfarms'
      }
      {
        name: 'endpoints'
        addressPrefix:cidrSubnet(primaryCIDR.network,25,1)
      }
    ]
    tags:union({},Module_Tags)
  }
}

module PrivateDNSZoneAzureSQL 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  scope: Network_RG
  params: {
    name: 'privatelink.database.windows.net'
    location:Deployment_location
    virtualNetworkLinks:[
      {
        virtualNetworkResourceId: VirtualNetwork.outputs.resourceId
      }
    ]
    tags:union({},Module_Tags)
  }
}

output VirtualNetwork_Name string = VirtualNetwork.outputs.name
output PrivateDNSZoneAzureSQL_Name string = PrivateDNSZoneAzureSQL.outputs.name
