bucket         = "customer-terraform-state-bucket"
key            = "tfstate/ClientA/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-lock-table"
encrypt        = true