## Palo Alto Panorama 10.1 Firewall Adoption

The firewall adoption process changed in 10.1 resulting in a couple additional steps to get the firewalls connected to Panorama. This will walk you through the steps and requirements to get the firewalls connected in 10.1.

## Registration Process

<https://docs.paloaltonetworks.com/panorama/10-1/panorama-admin/manage-firewalls/add-a-firewall-as-a-managed-device.html>

There is an issue on 10.1.3, well, I've seen the issue on 10.1.3, where the auth code will not work in the WebUI for the Palo firewall. If this happens, you can use the following commands to set the auth code on the firewall.

```bash
admin@pan1> request authkey set 
Authkey set.

admin@pan1> configure 
Entering configuration mode
[edit]
admin@pan1# commit force 
```
