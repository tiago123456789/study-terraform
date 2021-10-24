provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_credentials.access_key
  secret_key = var.aws_credentials.secret_key
}

variable "aws_credentials" {
  description = "Need access_key and secret_key aws-cli"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0747bdcabd34c712a"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}