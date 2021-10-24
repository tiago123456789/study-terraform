provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_credentials.access_key
  secret_key = var.aws_credentials.secret_key
}

variable "aws_credentials" {
  description = "Need access_key and secret_key aws-cli"
}

variable "s3" {
  description = "S3 data. Example: bucket and file make upload"
}


resource "aws_sqs_queue" "terraform_queue" {
  name                      = "terraform-example-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  tags = {
    Environment = "dev"
  }
}

resource "aws_s3_bucket" "b" {
  bucket = var.s3.bucket
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.b.bucket
  key    = "hello_world.txt"
  source = var.s3.file_to_upload
}