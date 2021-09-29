# General Terraform Notes

Here are my general notes on Terraform as I come across items worth documenting.

## Reading in JSON files

This might be required when wanting to read in configuration files or state files.

```bash
locals {
  json_data = jsondecode(file("./file.json"))
}

output "json" {
    value = local.json_data.path.to.object
}
```

## Output a template file

This might be useful when you want to output certain data to a separate file for consumption in the next stage of the process.

```bash
data "template_file" "render" {
  template = file("./templates/template.tpl")
  vars = {
    somedata = somevalue
  }
}

output "render" {
  value = data.template_file.render.rendered
}
```

Here is the template file example for some JSON

```bash
# ./templates/template.tpl
{
    "somedata": "${ somedata }"
}
```
