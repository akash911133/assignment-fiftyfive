bucket         = "aws-platform-infra-bucket"
key            = "tfstate/ClientB/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-lock-table"
encrypt        = true
