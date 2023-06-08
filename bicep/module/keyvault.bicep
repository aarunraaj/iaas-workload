param location string
param keyvaultName string = 'diskvault'
param secretName string = 'encrKey'
@secure()
param keyvalue string

resource akv 'Microsoft.KeyVault/vaults@2023-02-01'= {
  name: keyvaultName
  location: location 
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: '240c52dc-9dc5-457b-90ab-ab7dd0470f95'
  }
}

resource vault 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: secretName
  parent: akv
  properties: {
    value:keyvalue
  }
}
