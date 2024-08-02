# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Use the S3 bucket module
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-terraform-state-bucket"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

# Create a DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "terraform-locks"
  }
}

# Create a directory in the S3 bucket
resource "aws_s3_bucket_object" "directory" {
  bucket = module.s3_bucket.bucket
  key    = "terraform-state-folder/"
}

# Store the Terraform state file in the S3 bucket
terraform {
  backend "s3" {
    bucket         = module.s3_bucket.bucket
    key            = "terraform-state-folder/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
  }
}