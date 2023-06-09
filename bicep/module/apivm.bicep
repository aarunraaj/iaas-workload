param location string
param adminUsername string
param subnetName string
param VnetId string
param dblbResourceId string
param vmSize string = 'Standard_B1s'
param publisher string = 'Canonical'
param offer string = '0001-com-ubuntu-server-jammy'
param sku string = '22_04-lts-gen2'
param version string = 'latest'
param apiLB string
param apivm array
@secure()
param adminPassword string

var subnetRef = '${VnetId}/subnets/${subnetName}'

resource pip 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: 'apipip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    deleteOption: 'Delete'
    publicIPAllocationMethod: 'Static'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-08-01' = [for (vm, i) in apivm: {
  name: '${vm.vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', apiLB, 'apiPool')
            }
          ]
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress:{
            id:pip.id
          }
        }
      }
    ]
  }
}]

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = [for (vm, i) in apivm: {
  name: vm.vmName
  location: location
  zones:[ vm.avZone ]
  tags:{
    'hidden-link:WorkloadModel.Relationship.CodeConnectsTo#usesManagedIdentity=false,usesTransportEncryption=false,usesPrivateEndpoint=false,criticality=Runtime': dblbResourceId
    }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: publisher
        offer: offer
        sku: sku
        version: version
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface[i].id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    osProfile: {
      computerName: vm.vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        patchSettings: {
          patchMode: 'ImageDefault'
        }
      }
    }
  }
}]

output adminUsername string = adminUsername
