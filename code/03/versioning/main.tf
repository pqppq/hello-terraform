provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

	# force_destroy = true
}

resource "aws_s3_bucket_versioning" "example" {
	bucket = aws_s3_bucket.terraform_state.id
		versioning_configuration {
			status = "Enabled"
		}
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
	bucket = aws_s3_bucket.terraform_state.id

		rule {
			apply_server_side_encryption_by_default {
				sse_algorithm = "AES256"
			}
		}
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "public_access" {
	bucket = aws_s3_bucket.terraform_state.id

	block_public_acls       = true
	block_public_policy     = true
	ignore_public_acls      = true
	restrict_public_buckets = true
}

# https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws/latest#input_attributes
resource "aws_dynamodb_table" "terraform_locks" {
	name = var.table_name
	billing_mode = "PAY_PER_REQUEST"
	hash_key = "LockID"

	attribute {
		name = "LockID"
		type = "S"
	}
}
