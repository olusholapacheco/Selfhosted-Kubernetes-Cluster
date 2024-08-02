terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket2024"
    key            = "my-my-terraform-state-bucket2024/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}