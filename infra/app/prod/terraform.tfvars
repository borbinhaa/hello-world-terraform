environment         = "prod"

app_name            = "hello-world"
app_port            = 8080
image_tag           = "latest"
public_subnets      = ["10.100.0.0/24", "10.100.1.0/24"]
region              = "us-east-1"
availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
codestar_connection = "arn:aws:codeconnections:us-east-1:XXXXXXXX:connection/XXXXXXXXXXXXXXXX" // TODO - não comitar # never commit that value
github_repo         = "borbinhaa/hello-world-terraform"
github_branch       = "main"
access_key = "XXXXXXXXXXX"
secret_key = "XXXXXXXXXXXXXXXXXXXX"