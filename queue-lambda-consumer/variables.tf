variable "aws_credentials" {
  description = "Need access_key and secret_key aws-cli"
}

variable "queue_process_data" {
  description = "Data to created queue used to send message to after consumed"
}

variable "s3" {
  description = "S3 data. Example: bucket and file make upload"
}