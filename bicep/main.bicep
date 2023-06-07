param location string = 'eastus'
@secure()
param adminPassword string

var Vnet = modvnet.outputs.VnetId
var webSubnet = modvnet.outputs.webSubnet
var apiSubnet = modvnet.outputs.apiSubnet
var dbSubnet = modvnet.outputs.dbSubnet
var dbLB = modilb.outputs.dblb
var dblbResourceId = modilb.outputs.dblbResourceId
var apiLB = modilb.outputs.apilb
var apilbResourceId = modilb.outputs.apilbResourceId
var webLB = modilb.outputs.weblb

module modapivm './module/apivm.bicep' = {
  name: 'apivmdeployment'
  params: {
    adminUsername: 'uxadmin'
    location: location
    adminPassword: adminPassword
    subnetName: apiSubnet
    VnetId: Vnet
    apiLB: apiLB
    dblbResourceId: dblbResourceId
  }
}

module modwebvm './module/webvm.bicep' = {
  name: 'webvmdeployment'
  params: {
    adminUsername: 'uxadmin'
    location: location
    adminPassword: adminPassword
    VnetId: Vnet
    subnetName: webSubnet
    webLB: webLB
    apilbResourceId:apilbResourceId
  }
}

module modvnet './module/vnet.bicep' = {
  name: 'vnetdeployment'
  params: {
    location: location
  }
}

module modsqlvm './module/sqlvm.bicep' = {
  name: 'sqlvmdeployment'
  params: {
    location: location
    adminUsername: 'dbsrvadmin'
    adminPassword: adminPassword
    vnetId: Vnet
    sqlVM: [
      {
        vmName: 'sqlvm01'
        avZone: 1
        ipaddress: '192.168.0.45'
      }, {
        vmName: 'sqlvm02'
        avZone: 2
        ipaddress: '192.168.0.46'
      }
    ]
    dbLB: dbLB
  }
}

module modilb './module/lb.bicep' = {
  name: 'ilbdeployment'
  params: {
    location: location
    dbsubnetName: dbSubnet
    apisubnetName: apiSubnet
    vnetId: Vnet

  }
}
