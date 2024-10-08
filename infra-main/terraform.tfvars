project_name          = "hello-world"
image_tag             = "latest"
github_connection_arn = "arn:aws:codeconnections:us-east-1:250203222255:connection/2790decc-880d-43e8-96a7-c13bd54a8192" // TODO - não comitar
github_repo           = "borbinhaa/my-service"
github_branch         = "main"
public_subnets        = ["10.100.0.0/24", "10.100.1.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b", "us-east-1c"]
app_port              = 8080