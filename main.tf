
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



#Create a VPC
