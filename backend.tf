terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}


resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-terraform-state-bucket"
}

resource "aws_s3_bucket_object" "directory" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "terraform-state-folder/"
}

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