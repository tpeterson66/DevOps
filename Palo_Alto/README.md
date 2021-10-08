# Palo Alto Configuration Notes

## Azure CLI Commands to accept the Azure Market Place plans

```azcli
az vm image terms accept --offer vmseries-flex --plan bundle2 --publisher paloaltonetworks
az vm image terms accept --offer vmseries-flex --plan byol --publisher paloaltonetworks
az vm image terms accept --offer panorama --plan byol --publisher paloaltonetworks
```
