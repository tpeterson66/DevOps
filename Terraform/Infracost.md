# InfraCost

<https://www.infracost.io/>
This tool can be used to track the cost of deployments using Terraform and other template based deployment tools.

## Installing the tool

```bash
# Install on Linux / WSL
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
```

## Registering

Once the tool is installed, you can run the following command to register access. This creates an API key which is used to access the tools api.

```bash
infracost register
```

If you're using CI/CD, you will need to create this file manually using a script:

```bash
# create the directory for the file, then create the YML file
mkdir -p ~/.config/infracost/ && touch ~/.config/infracost/credentials.yml
# create the YML file
echo 'version: "0.1"' >> ~/.config/infracost/credentials.yml
echo 'api_key: <ENTER YOUR KEY HERE>' >> ~/.config/infracost/credentials.yml
echo 'pricing_api_endpoint: https://pricing.api.infracost.io' >> ~/.config/infracost/credentials.yml
```

## Running the Tool

The tool CLI can use a few arguments to create the cost breakdown. Here are a few examples:

```bash

# Run Terraform Plan and output the results to a file
terraform plan -out tfbinary.tfplan

# Convert the plan binary to JSON so Infracost can read in the plan details
terrform show -json tfbinary.tfplan > tfplan.json

# Run the cost breakdown
infracost breakdown --format html --path plan.json > cost.html

# Cleanup the other files, they're not needed...
rm tfbinary.tfplan tfplan.json
```
