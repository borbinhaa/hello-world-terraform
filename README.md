# Hello-world-terraform

This projects main objective is to provide an automated CI/CD pipeline using **GitHub Actions**, **Amazon CodePipeline**, and **Terraform** to manage infrastructure as code (IaC). The main idea is to automate the provisioning and management of cloud infrastructure, as well as the building and deployment of applications.

## Features

- Automated infrastructure provisioning using **Terraform**
- Continuous deployment of applications using **GitHub Actions** and **Amazon CodePipeline**
- Integration with **AWS** for infrastructure management
- Caching of Terraform state using **GitHub Actions** cache for deployment process optimization
- Build and push Docker images to an Amazon ECR repository
- Deploy applications in an ECS (or EKS) cluster

## Requirements

- **Terraform** = 1.9.7
- **AWS CLI** configured with the appropriate permissions
- **Terraform variables correctly configured**
- **GitHub Actions** configured with the following secrets and appropriate permissions:
    - `AWS_ACCESS_KEY_ID`
    - `AWS_SECRET_ACCESS_KEY`
    - `AWS_REGION`
    - `IMAGE_TAG` (Docker image tag. Ex: latest)

## Project Structure

```
├── infra/
│   ├── main.tf               # Main Terraform file
│   ├── variables.tf          # Variable definitions
│   ├── outputs.tf            # Terraform outputs
│   ├── dev/                  # Configuration files for the development environment
│   │   └── terraform.tfvars  # Environment-specific variables for development
│   ├── prod/                 # Configuration files for the prod environment
│   │   └── terraform.tfvars  # Environment-specific variables for prod
├── .github/
│   └── workflows/
│       └── deploy-dev.yml    # Infrastructure deployment file with GitHub Actions
│       └── destroy-dev.yml   # Infrastructure destruction file with GitHub Actions
├── src/                      # Spring Boot project
└── README.md                 # Project documentation
```

## How to Use

### Cloning the Project

```bash
git clone https://github.com/borbinhaa/hello-world-terraform.git
cd hello-world-terraform
```

### CI/CD Pipeline

- The ```develop``` branch uses GitHub Actions to update the service and deploy infrastructure
- The ```main``` branch uses Amazon CodePipeline for service updates, and infrastructure deployment must be done manually

#### Configs ```develop```

- Create project variables in GitHub:
    - Settings > Secrets and variables > Actions
    - Add the variables: ```AWS_ACCESS_KEY_ID```, ```AWS_SECRET_ACCESS_KEY```, ```AWS_REGION```, ```IMAGE_TAG```
- Alterar as variáveis do arquivo ```/infra/app/dev/terraform.tfvars```

#### Running ```develop```

- Committing to the develop branch will automatically trigger an action that will deploy the infrastructure and start the service
- To remove the infrastructure, run the ```Destroy DEV Environment``` action with the ```develop``` branch selected

#### Configs ```main```

- [Create an AWS connection with GitHub.](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-github.html)
- Update the variables in the file ```/infra/app/prod/terraform.tfvars```

#### Como rodar ```develop```

```bash
cd infra/app
# View the plan for the services that will be deployed
terraform plan -var-file="prod/terraform.tfvars"
# Deploy the infrastructure
terraform apply -var-file="dev/terraform.tfvars" -auto-approve
# Destroy the infrastructure
terraform destroy -var-file="dev/terraform.tfvars" -auto-approve
```

## Some things I would change before using it in a real project

- Use the same CI/CD technology for both branches; I used two different ones to learn them
- Save the Terraform state using the **S3 backend** instead of GitHub Actions cache
- Deploy the service in **private subnets** in AWS
- Use a **Load Balancer** with ECS
- Implement **Autoscaling** for the ECS cluster