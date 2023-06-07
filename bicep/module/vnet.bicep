param location string
param vnetName string = 'iaas-vnet'
param addressPrefix string = '192.168.0.0/24'
param webSnet string = 'webTier'
param apiSnet string = 'apiTier'
param dbSnet string = 'dbTier'
param webSubnetaddr string = '192.168.0.0/28'
param apiSubnetaddr string = '192.168.0.16/28'
param dbSubnetaddr string = '192.168.0.32/28'
param nsgName string = 'workloadnsg'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'allowWebToApi'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 110
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
        }
      }
      {
        name: 'allowWebInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
          destinationPortRange: '80'
        }
      }
    ]
  }
}

resource Vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
    subnets: [
      {
        name: webSnet
        properties: {
          addressPrefix: webSubnetaddr
          networkSecurityGroup:{
            id:networkSecurityGroup.id
          }
        }
      }
      {
        name: apiSnet
        properties: {
          addressPrefix: apiSubnetaddr
          networkSecurityGroup:{
            id:networkSecurityGroup.id
          }
        }
      }
      {
        name: dbSnet
        properties:{
          addressPrefix:dbSubnetaddr
          networkSecurityGroup:{
            id:networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

output VnetId string = Vnet.id
output webSubnet string = Vnet.properties.subnets[0].name
output apiSubnet string = Vnet.properties.subnets[1].name
output dbSubnet string = Vnet.properties.subnets[2].name
