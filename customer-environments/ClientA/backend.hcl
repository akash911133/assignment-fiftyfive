bucket         = "terraform-aws-infra-statebucket"
key            = "tfstate/ClientA/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-lock-table"
encrypt        = true