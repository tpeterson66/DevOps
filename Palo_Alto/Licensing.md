# Palo Alto Licensing

Palo Alto has switched to using a credit based model allowing customers to use the exact solutions they need without having to be locked into a specific SKU or service. The following links can be used to obtain more information about these licensing limits and hardware selection requirements. When you purchase credits, you can use the built in calculator to identify the required credits.

- <https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/license-the-vm-series-firewall/software-ngfw/maximum-limits-based-on-memory.html>

## Create Deployment

<https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/license-the-vm-series-firewall/software-ngfw/create-a-deployment-profile-vm-series.html>

## Managing Profiles

If you need to remove a firewall from a deployment, you need to remove the license from the Palo firewall. In order to do this, you need to add the license API key.

This can be done by logging into the support portal, navigating to the "Assets" -> "Licensing API" menu. From there, generate the license API key. This is a secret and should be treated as such.

Login to the firewall and run the following commands:

```bash
request license api-key set key <key>

# Use the following command to replace the key, if needed:
request license api-key delete
```

If you need to create a new profile, use the following instructions.

<https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/license-the-vm-series-firewall/deactivate-the-licenses/install-a-license-deactivation-api-key.html>

## Registering the Licenses

Once you create the deployment profile, you will gain access to the auth codes. You can use those Auth Codes like you do any other Palo auth codes. Follow these instructions below for additional details:

<https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/license-the-vm-series-firewall/software-ngfw/register-the-vm-series-firewall-software-ngfw-credits.html>

## Panorama Licensing

If you add the Palo Alto licenses to the firewalls when creating the deployment profile, you can use the following instructions to create a Panorama auth code.

<https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/license-the-vm-series-firewall/software-ngfw/provision-panorama.html>

When you following these instructions, you will need to update the Panorama server with the newly created serial number and apply it to the server. This can be done under Panorama -> Setup -> General Settings -> Serial Number. Once this is done, you can use the corresponding Auth code to register and activate the Panorama under licensing.

### Summary

Once the firewalls are activated, licensed, patched, continue on to the Panorama registration process.
