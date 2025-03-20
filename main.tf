
#Define the AWS region
provider "aws" {
    region = "us-east-1"
}

#Create an IAM user for Terraform
resource "aws_iam_user" "terraform_user" {
    name = "terraform-user"
}

#Create an IAM policy for read-only access to AWS resources
resource "aws_iam_policy" "readonly_policy" {
    name = "ReadOnlyAccess-Terraform"
    description = "Provides read-only access to AWS resources"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "ec2:Describe*",
                    "s3:Get*",
                    "s3:List*",
                    ]
                Effect = "Allow"
                Resource = "*"
            }
        ]
    })
}

#Attach the policy to the user
resource "aws_iam_user_policy_attachment" "readonly_attachment" {
    user = aws_iam_user.terraform_user.name
    policy_arn = aws_iam_policy.readonly_policy.arn
}

#Create an S3 bucket with encryption enabled
resource "aws_s3_bucket" "secure_bucket" {
    bucket = "secure-terraform-bucket-${random_string.suffix.result}"
}

#Generate a random suffix for the bucket name
resource "random_string" "suffix" {
    length = 6
    special = false
    upper = false
}

#Enable encryption for the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
    bucket = aws_s3_bucket.secure_bucket.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "block_public_access" {
    bucket = aws_s3_bucket.secure_bucket.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

#Output the bucket name
output "bucket_name" {
    value = aws_s3_bucket.secure_bucket.bucket
}
