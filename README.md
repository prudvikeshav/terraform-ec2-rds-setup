# 🌟 Terraform AWS EC2 RDS Setup

---
This repository contains Terraform configuration files to set up a basic AWS infrastructure. It provisions a VPC, subnets, EC2 instances, an RDS instance, and necessary networking components.

## 🛠️ Overview

This Terraform setup includes:

- **VPC**: A Virtual Private Cloud (VPC) with DNS support and hostnames enabled.
- **Subnets**: Two subnets across different availability zones.
- **Security Groups**: A security group allowing inbound traffic on common ports (22, 80, 443, 3306).
- **Network Interfaces**: Two network interfaces for the EC2 instances.
- **Internet Gateway**: For allowing internet access.
- **Route Table**: For routing traffic to the internet.
- **EC2 Instances**: Two EC2 instances using specified AMI and instance type.
- **RDS Instance**: A MySQL RDS instance in the specified subnets.

## 📋 Prerequisites

- [Terraform](https://www.terraform.io/downloads): Ensure Terraform is installed on your local machine.
- [AWS CLI](https://aws.amazon.com/cli/): Configure AWS CLI with the following command:

    ```bash
    aws configure
    ```

    This command will prompt you for your AWS Access Key ID, Secret Access Key, default region name, and output format. Make sure to provide the appropriate credentials with sufficient permissions to create the resources.

## 🛠️ Configuration

### 📂 Files

- **[main.tf](https://github.com/prudvikeshav/terraform-ec2-rds-setup/blob/main/main.tf)**: Contains the primary Terraform configuration, including resource definitions.
- **[variables.tf](https://github.com/prudvikeshav/terraform-ec2-rds-setup/blob/main/variables.tf)**: Defines the variables used in the Terraform configuration.
- **[terraform.tfvars](https://github.com/prudvikeshav/terraform-ec2-rds-setup/blob/main/variables.tf)**: Contains the values for the variables.

### 🔧 Variables

Update the `terraform.tfvars` file with your specific settings:

```hcl
vpc_cidr_block      = "10.1.0.0/16"
subnet_a_cidr_block = "10.1.1.0/24"
subnet_b_cidr_block = "10.1.2.0/24"
availability_zone_a = "us-east-1a"
availability_zone_b = "us-east-1b"
instance_type       = "t2.micro"
key_name            = "my-ec2-key"
db_username         = "admin"
db_password         = "securePassword123"
```

### 🔑 Key Pair

Replace the path to your public SSH key in the `main.tf` file:

```hcl
public_key = file("~/.ssh/id_rsa.pub") # Replace with the path to your public key
```

## 🚀 Usage

1. **Initialize Terraform**: Run the following command to initialize Terraform and download necessary providers:

    ```bash
    terraform init
    ```

2. **Plan the Deployment**: Review the changes Terraform will make:

    ```bash
    terraform plan
    ```

3. **Apply the Configuration**: Apply the configuration to create the resources:

    ```bash
    terraform apply
    ```

4. **Destroy the Infrastructure**: To remove all resources created by this configuration:

    ```bash
    terraform destroy
    ```

## 📦 Outputs

After applying the Terraform configuration, the following outputs will be available:

- **`route_table_id`**: The ID of the route table created.
- **`instance_1_id`**: The ID of the first EC2 instance.
- **`instance_2_id`**: The ID of the second EC2 instance.

## ⚠️ Notes

- Ensure that the AMI ID specified is valid and available in the specified AWS region.
- The database password in `terraform.tfvars` should be kept secure and not hardcoded in production environments.

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/prudvikeshav/terraform-ec2-rds-setup/blob/main/LICENSE) file for details.
