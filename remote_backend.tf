resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state-spot"

# prevent accidental deletion of this s3 bucket
    lifecycle{
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "enabled"{
      bucket = aws_s3_bucket.terraform_state.id
      versioning_configuration{
        status = "Enabled"
      }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute{
    name = "LockID"
    type = "S"
  }
}

# terraform {
#   backend "s3"{
#     bucket = "terraform-up-and-running-state-spot"
#     key = "dev/terraform.tfstate"
#     region = "us-east-1"
#     dynamodb_table = "terraform-up-and-running-locks"
#     encrypt = true
#   }
# }