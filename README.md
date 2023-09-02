# Infrastructure Terraform Scripts

This repository contains Terraform scripts for setting up my budgets and configuring templates for my daily use cloud resources.
It also serves as a practice project for working with Terraform.

## Prerequisites

Before running these scripts, make sure you have the following:

- Terraform installed on your local machine
- AWS account credentials configured

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/terraform-scripts.git
   ```

2. Navigate to the project directory:

   ```bash
   cd terraform-scripts
   ```

3. Initialize Terraform:

   ```bash
   terraform init
   ```

4. Modify the `main.tf` file to customize your budget and resource configurations.

5. Apply the Terraform configuration:

   ```bash
   terraform apply
   ```

   This will create the specified budgets and configure the cloud resources.

6. To destroy the created resources, run:

   ```bash
   terraform destroy
   ```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
