provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_credentials.access_key
  secret_key = var.aws_credentials.secret_key
}


resource "aws_sqs_queue" "queue_process_data" {
  name                       = var.queue_process_data.name
  visibility_timeout_seconds = var.queue_process_data.visibility_timeout_seconds
  delay_seconds              = var.queue_process_data.delay_seconds
  message_retention_seconds  = var.queue_process_data.message_retention_seconds
  receive_wait_time_seconds  = var.queue_process_data.receive_wait_time_seconds
}

resource "aws_iam_role" "lambda" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda" {
  policy_arn = "${aws_iam_policy.lambda.arn}"
  role = "${aws_iam_role.lambda.name}"
}

resource "aws_iam_policy" "lambda" {
  policy = "${data.aws_iam_policy_document.lambda.json}"
}

data "aws_iam_policy_document" "lambda" {
  statement {
    sid       = "AllowSQSPermissions"
    effect    = "Allow"
    resources = ["arn:aws:sqs:*"]

    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
  }

  statement {
    sid       = "AllowInvokingLambdas"
    effect    = "Allow"
    resources = ["arn:aws:lambda:*:*:function:*"]
    actions   = ["lambda:InvokeFunction"]
  }

  statement {
    sid       = "AllowCreatingLogGroups"
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
    actions   = ["logs:CreateLogGroup"]
  }

  statement {
    sid       = "AllowWritingLogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*:*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

data "archive_file" "lambda" {
  type = "zip"
  source_dir = "${path.module}/function"
  output_path  = "${path.module}/process_data.js.zip"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.s3.bucket
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket_object" "lambda" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "process_data_js.zip"
  source = data.archive_file.lambda.output_path
  etag   = filemd5(data.archive_file.lambda.output_path)
}

resource "aws_lambda_function" "lambda" {
  function_name = "process_data_js"
  handler = "processData.handler"
  role = aws_iam_role.lambda.arn
  runtime = "nodejs12.x"
  s3_bucket        = aws_s3_bucket_object.lambda.bucket
  s3_key           = aws_s3_bucket_object.lambda.key

  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  timeout = 30
  memory_size = 128
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size = 1
  event_source_arn = aws_sqs_queue.queue_process_data.arn
  enabled = true 
  function_name = aws_lambda_function.lambda.arn
}