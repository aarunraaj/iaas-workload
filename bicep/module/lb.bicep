param location string
param dblbName string = 'dbLB'
param apilbName string = 'apiLB'
param weblbName string = 'webLB'
param vnetId string
param dbsubnetName string
param apisubnetName string

var dbsubnetId = '${vnetId}/subnets/${dbsubnetName}'
var apisubnetId = '${vnetId}/subnets/${apisubnetName}'

resource dbilb 'Microsoft.Network/loadBalancers@2022-11-01' = {
  name: dblbName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'loadbalancerFE'
        properties: {
          subnet: {
            id: dbsubnetId
          }
          privateIPAddress: '192.168.0.40'
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'dbPool'
      }
    ]
    loadBalancingRules: [
      {
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', dblbName, 'loadbalancerFE')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', dblbName, 'dbpool')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          idleTimeoutInMinutes: 15
        }
        name: 'lbrule'
      }
    ]
  }
}

resource apilb 'Microsoft.Network/loadBalancers@2022-11-01' = {
  name: apilbName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'loadbalancerFE'
        properties: {
          subnet: {
            id: apisubnetId
          }
          privateIPAddress: '192.168.0.20'
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'apiPool'
      }
    ]
    loadBalancingRules: [
      {
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', apilbName, 'loadbalancerFE')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', apilbName, 'apiPool')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          idleTimeoutInMinutes: 15
        }
        name: 'lbrule'
      }
    ]
  }
}

resource webLB 'Microsoft.Network/loadBalancers@2022-11-01' = {
  name: weblbName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'loadbalancerFE'
        properties: {
          publicIPAddress: {
            id: lbPip.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'webPool'
      }
    ]
    loadBalancingRules: [
      {
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', weblbName, 'loadbalancerFE')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', weblbName, 'webPool')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          idleTimeoutInMinutes: 15
          disableOutboundSnat: true
        }
        name: 'httpRule'
      }
    ]
    outboundRules: [
      {
        name: 'myOutboundRule'
        properties: {
          protocol: 'All'
          enableTcpReset: false
          idleTimeoutInMinutes: 15
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', weblbName, 'webPool')
          }
          frontendIPConfigurations: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', weblbName, 'loadbalancerFE')
            }
          ]
        }
      }
    ]
  }
}

resource lbPip 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: 'weblbPip'
  location: location
  zones:[
    '1'
  ]
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    deleteOption: 'Delete'
    publicIPAllocationMethod: 'Static'
  }
}
output dblb string = dbilb.name
output dblbResourceId string = dbilb.id
output apilb string = apilb.name
output apilbResourceId string = apilb.id
output weblb string = webLB.name
