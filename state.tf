provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "keep-latest"
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }

  tags = {
    Name = "terraform-state"
  }
}

resource "aws_s3_bucket_object" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket
  key    = "terraform.tfstate"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "terraform-locks"
  }
}
