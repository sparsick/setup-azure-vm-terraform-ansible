# setup-azure-vm-terraform-ansible
Demo how to provision VMs in Azure with Terraform and Ansible

## Setup Azure Infrastructure With Terraform

This sample is tested with Terraform v0.15.3.

You need to [install Terraform](https://www.terraform.io/downloads.html) to run the sample.

In the folder `setup-aure-infra` there is Terraform script that setup following Azure resources:

- Resource group
- Virtual Network
- Subnet
- Public IP
- Network Security group and rule
- Network Interface
- Linux Virtual Machine

As Terraform Provider [hashicorp/azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) is used.

Before running the terraform script, you have to decide which [authentication method](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure) you want to use for Terraform.

After set up the authentication method, you can run the Terraform scripts:

```shell
cd setup-azure-infra
terraform init # install the Terraform provider need only once
terraform plan # show with resource will be created
terraform apply # create the Azure resources
terraform destroy # destroy all Azure resources
```

After a `terraform apply` the IP address of the Vm will be shown.

```shell
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

public_ip_address = "20.94.225.48"
```

## Server provisioning with Ansible

## Local Setup

You need to [install Ansible](https://docs.ansible.com/ansible-core/devel/installation_guide/intro_installation.html), the following Python lib and Ansible Collection that is defined in `requirements.yml`:

```shell
cd vm-provisioning
pip install azure-cli
ansible-galaxy collection install -r requirements.yml
```

Before running the sample, you have to decide which [authentication method](https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_inventory.html#parameter-auth_source) you want to use for Ansible.

In `inventory/demo.azure_rm.yml` (it is important that the file ends with `azure_rm.yml`) you defined which VM should be provisioned.
In this sample all VM from the resource group `hero-app-rg`.
Furthermore, in this sample the VMs will be groups by further information, in this case in tags.

You can list all VM of this resource group with

```shell
cd vm-provisioning
ansible-inventory -i inventory/demo.azure_rm.yml --graph
@all:
  |--@tag_app_hero:
  |  |--hero-app-vm_7892
  |--@ungrouped:
```

In this sample there is one VM that is also tagged with `app=hero`.
Therefore, it is list in the group `@tag_app_hero`.

To start the provisioning all VM of the defined resource group, you run

```shell
 ansible-playbook  -i inventory/demo.azure_rm.yml install-hero-app.yml
```

If you want to limit to a specific Vm of the resource group, you have to limit it with the help of the tags.

```shell
 ansible-playbook  -i inventory/demo.azure_rm.yml install-hero-app.yml --limit=tag_app_hero
```

After that you can call the sample app in your browser (http://public_ip_address/hero ).
The public ip address is shown in the terraform output.

### More information
- [Dynamic Inventory / Inventory Plugins in Ansible ](https://docs.ansible.com/ansible/latest/plugins/inventory.html)
- [Azure Inventory Plugin in Ansible](https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_inventory.html#ansible-collections-azure-azcollection-azure-rm-inventory)
- [Tutorial Azure Provisioning with Ansible](https://docs.microsoft.com/en-us/azure/developer/ansible/dynamic-inventory-configure?tabs=ansible)
