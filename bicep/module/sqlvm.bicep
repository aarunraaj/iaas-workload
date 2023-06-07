param location string
@secure()
param adminPassword string
param vnetId string
param sqlVM array
param adminUsername string
param dbLB string
param subnetName string = 'dbtier'
param vmName string = 'sqlvm'
param vmSize string = 'Standard_B2ms'
param version string = 'latest'
param sqlsku string = 'Standard'
param dataLun int = 0
param logLun int = 1
param dataPath string = 'F:\\Data'
param logPath string = 'G:\\Log'


var subnetRef = '${vnetId}/subnets/${subnetName}'
var tempDB = 'D:\\tempdb'

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-08-01' = [for (vm, i) in sqlVM: {
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
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', dbLB, 'dbPool')
            }
          ]
          privateIPAllocationMethod: 'Static'
          privateIPAddress: vm.ipaddress
        }
      }
    ]
  }
}]

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = [for (vm, i) in sqlVM: {
  name: vm.vmName
  location: location
  zones: [
    vm.avZone
  ]
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
      dataDisks: [
        {
          createOption: 'Empty'
          diskSizeGB: 30
          lun: 0
        }
        {
          createOption: 'Empty'
          diskSizeGB: 30
          lun: 1
        }
      ]
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: 'sql2019-ws2019'
        sku: sqlsku
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
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
  }
}]

resource sqlAgent 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2022-07-01-preview' = [for (vm, i) in sqlVM: {
  name: vm.vmName
  location: location
  properties: {
    virtualMachineResourceId: virtualMachine[i].id
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    storageConfigurationSettings: {
      diskConfigurationType: 'NEW'
      storageWorkloadType: 'GENERAL'
      sqlDataSettings: {
        luns: [ dataLun ]
        defaultFilePath: dataPath
      }
      sqlLogSettings: {
        luns: [ logLun ]
        defaultFilePath: logPath
      }
      sqlTempDbSettings: {
        defaultFilePath: tempDB
      }
    }
  }
}]
