targetScope = 'subscription'



resource Database_RG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'database'
  location: 'uksouth'
}

resource Network_RG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'network'
  location: 'uksouth'
}

resource Application_RG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'application'
  location: 'uksouth'
}



