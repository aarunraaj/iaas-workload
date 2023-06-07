# Scenario #1 deployment
- Includes web tier / App tier / DB tier 
- All these are zonal deployment and the servers placed across different zones (1 & 2).
- All three tiers will have Azure Load Balancer attached.
    - Web tier has Public Load balancer
    - App and DB tier is attached with internal load balancer
    
Include disk encryption part of the deployment.
Azure DNS zone (public zone).

## Steps
- Clone the repo and run [main.bicep](./main.bicep)
```
az group create -n sampleRG -l eastus
az deployment group create -g sampleRG --template-file .\bicep\main.bicep
```
- Supply virtual machine and SQLdb password secure string.