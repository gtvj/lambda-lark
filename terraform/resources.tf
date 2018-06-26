# Declare S3 bucket resource
resource "aws_s3_bucket" "lambda-lark-bucket" {
  bucket = "lambda-lark-bucket"
  region = "eu-west-2"
  acl    = "private"
}

# Declare S3 bucket resource
resource "aws_s3_bucket" "lambda-lark-bucket-backup" {
  bucket = "lambda-lark-bucket-backup"
  region = "eu-west-2"
  acl    = "private"
}

# Provide S3 bucket notification resource
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.lambda-lark-bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.s3_file_backup_terraform.arn}"

    events = [
      "s3:ObjectCreated:*",
    ]
  }
}

# Give S3 ability to invoke Lambda
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.s3_file_backup_terraform.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.lambda-lark-bucket.arn}"
}

# Declare lambda
resource "aws_lambda_function" "s3_file_backup_terraform" {
  filename         = "../index.js.zip"                          # Path to local zipped code
  function_name    = "s3_file_backup_terraform"
  role             = "${aws_iam_role.iam_for_lambda.arn}"       # Assign role
  handler          = "index.handler"                            # Function entry point
  source_code_hash = "${base64sha256(file("../index.js.zip"))}"
  runtime          = "nodejs8.10"

  environment {
    variables = {
      Name = "s3_file_backup_terraform"
    }
  }
}

# Declare IAM role and use 'assume_role_policy' to stipulate that the role can be assumed by lambda(s)
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = "${file("lambda-can-assume-role.json")}"
}

# Define IAM policy and attach it to role
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = "${aws_iam_role.iam_for_lambda.id}"

  policy = "${file("lambda-policy.json")}"
}
