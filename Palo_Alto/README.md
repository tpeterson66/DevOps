# Palo Alto Configuration Notes

## Azure CLI Commands to accept the Azure Market Place plans

```azcli
az vm image terms accept --offer vmseries-flex --plan bundle2 --publisher paloaltonetworks
az vm image terms accept --offer vmseries-flex --plan byol --publisher paloaltonetworks
az vm image terms accept --offer panorama --plan byol --publisher paloaltonetworks
```

## Ansible

``` bash
sudo apt update
sudo apt install ansible -y
pip3 install pan-python
pip3 install pandevice
pip3 install pan-os-python
ansible-galaxy collection install paloaltonetworks.panos
```
