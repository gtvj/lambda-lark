resource "aws_s3_bucket" "gtvj_files" {
  bucket = "${element(var.bucket_names, count.index)}"

  region = "eu-west-2"

  acl = "private"

  count = "${length(var.bucket_names)}"

  tags {
    Name = "lambda-lark"
  }
}

variable "bucket_names" {
  description = "Names for the S3 buckets"
  type        = "list"

  default = ["lambda-lark-bucket", "lambda-lark-bucket-backup"]
}
