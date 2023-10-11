# Terraform Azure Infrastructure Deployment

This repository contains Terraform configuration files for deploying a simple infrastructure on Microsoft Azure. The deployment includes two virtual machines with associated network security groups, a PostgreSQL database, and a Flask application in Python 3.

## Introduction
This Terraform project simplifies the process of deploying a basic infrastructure on Microsoft Azure, consisting of:

- Two virtual machines (VMs) to host your application and database.

- Network Security Groups (NSGs) to control inbound and outbound traffic.

- A PostgreSQL database server running on one of the VMs.

- A Flask application running on the other VM.

This infrastructure can serve as a starting point for more complex Azure-based projects.

## Prerequisites
Before you can deploy this infrastructure, ensure that you have the following prerequisites:

**Azure Account:** You must have an active Microsoft Azure account.

**Terraform:** Install Terraform on your local machine.

    To install Terraform, find the appropriate package for your system and download it as a zip archive.

    After downloading Terraform, unzip the package. Terraform runs as a single binary named terraform. Any other files in the package can be safely removed and Terraform will still function.

    Finally, make sure that the terraform binary is available on your PATH. This process will differ depending on your operating system.

**Azure Service Principal:** Create an Azure Service Principal with the necessary permissions and configure it in your environment.

## Configuration
Before deploying the infrastructure, you need to configure your variables in the terraform/variables.tf file. The variables include details such as VM sizes, resource group, virtual network, and more. Review and customize them according to your needs.

In addition, you need to create a *secrets.tfvars* file that contains the nesseceary secret values. The files content should look like this: password-db = "my-secert-password".




## Deployment

To deploy the infrastructure, follow these steps:

1. Clone this repository to your local machine:

   ```bash
   git clone https://github.com/LiyaKeidar1/terraformLibrary.git
   cd your-repo
   ```

2. Initialize the Terraform working directory:

   ```bash
   terraform init
   ```

3. Deploy the infrastructure:

   ```bash
   terraform apply
   ```

4. Review the planned changes and confirm by typing 'yes' when prompted.


## Tear Down

If you want to tear down the infrastructure, you can do so by running:

```bash
terraform destroy
```

Review the planned changes and confirm by typing 'yes' when prompted.

