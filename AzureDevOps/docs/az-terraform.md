# Azure DevOps to support Terraform CI/CD

Infrastructure as Code is very powerful but comes with some challenges when operational needing to support the deployments. Writing and deploying the code from your local machine is simple and does not require pipelines, Git, branches, service connections, and more to get up and running. When working on infrastructure as a team, you're often required to collaborate on the same project code which is where Git and pipelines come into play.

This doc assumes you understand the fundamentals of Terraform, Git, and pipelines and are able to understand the configuration files accordingly.

## TerraformTaskV1 vs. TerraformTaskV2

I've run into an issue with TerraformTaskV1 on newer versions of Terraform. <https://github.com/microsoft/azure-pipelines-extensions/issues/942> provides insight to the issue. Essentially, "There's a new release (0.1.9) out now with a TerraformTaskV2 with support for the new configuration format. V1 should be used for Terraform <0.12 and V2 for later versions." The correct task to use is:

```yaml
  - task: TerraformTaskV2@2
```
