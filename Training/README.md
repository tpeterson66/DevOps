# DevOps Training Plan

The following sections will dive into solid training options to get spun up specific topics as they relate to DevOps as a whole.

## Azure Services

- networking
- PassS
- Private Endpoint
- Service Endpoint
- Application Basics

## Git and Source Code Management

The foundation of DevOps is source code management, more specifically, Git. From the Git Website; "Git is a free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency". Git has been used by software development workflows for many years and is used in the largest open-source projects including Linux. Git is hosted by many services today including GitHub, Azure DevOps, GitLab, etc. Git can certainly be very complicated, however, it can also be used within simple projects with a single contributor to ensure the code is versioned and maintained. Here are a few links that I recommend for getting spun up on Git.

### Links

- <https://docs.microsoft.com/en-us/devops/develop/git/what-is-git>
- <https://www.youtube.com/watch?v=RGOj5yH7evk>

### Objectives

- Understand how to clone a repo to your local machine
- Understand how to create a local branch
- Understand branching on the remote server (DevOps/Github)
- Understand how to create a Pull Request or Merge Request
- Understand how to pull changes down from the remote to your local machine

## Terraform

Terraform is the industry leader in Infrastructure as code and provides a cloud agnostic tool that can be used to provision infrastructure for many use-cases. Here are some general training links that can be used to get up-to-speed on Terraform.

- <https://www.youtube.com/watch?v=tomUWcQ0P3k>
- <https://www.youtube.com/watch?v=l5k1ai_GBDE>
- <https://docs.microsoft.com/en-us/azure/developer/terraform/>
- <https://learn.hashicorp.com/collections/terraform/azure-get-started>
 
 I also have a Terrachallange repository which can be used to test your knowledge of Terraform using a quick example. <https://github.com/tpeterson66/Terrachallenge/>

### Providers

Terraform provides a platform where other vendors can publish their code to interact with their solution. These are call providers and are typically managed in part by Hashicorp and the vendor. Azure has a team dedicated to providing a quality provider, which is routinely updated with new features and services. Become familiar with the documentation, how to read it, where its at, and how to look for current and new issues using Github. Authenticating using the providers can also be tricky. Its important to understand how the providers function and the various ways you can authenticate. There are providers for all types of systems and they can all be used within the same project.

- <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs>
- <https://registry.terraform.io/browse/providers>
- <https://github.com/hashicorp/terraform-provider-azurerm>

### Resources

Terraform can be used to build simple or complex environments with various resource types. Most resources are easy to deploy, however, some can be more complicated. Its important to understand how the base resources are deployed before you can dig into the more complex items.

### Variables

Variables are incredible important and allow you to reuse code within the same project, or, other projects. Understanding how to use variables, locals, secrets, etc. is important to the success of Terraform in production use-cases. Take a look at the following list and ensure you're comfortable with how these are used.

- <https://www.terraform.io/docs/language/values/variables.html>
- tfvars
- variables - types, descriptions, defaults
- .auto.tfvars

### Expressions

Expressions are slightly more complicate but they unlock the power of Terraform and provide a programmatic solution to repeating code.

- <https://www.terraform.io/docs/language/expressions/index.html>

### Modules

Modules are used to provide a packaged solution or module of Terraform code, which can be used multiple times or in multiple projects. It is important to understand how modules are created, consumed, updated, and managed within the project.

- <https://www.terraform.io/docs/language/modules/develop/index.html>

## Azure DevOps

### Boards

### Repositories

### Pipelines

### Advanced Pipeline Configuration
