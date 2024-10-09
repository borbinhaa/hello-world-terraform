project_name          = "hello-world"
image_tag             = "latest"
github_connection_arn = "arn:aws:codeconnections:us-east-1:XXXXXXXXX:connection/XXXXXXXXXXXXXXX" # never commit that value
github_repo           = "borbinhaa/my-service"
github_branch         = "main"
public_subnets        = ["10.100.0.0/24", "10.100.1.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b", "us-east-1c"]
app_port              = 8080