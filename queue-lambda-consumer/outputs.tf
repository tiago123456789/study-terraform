output "arn_queue" {
    description = "ARN the queue created by terraform"
    value = aws_sqs_queue.queue_process_data.arn
}

output "url_queue" {
    description = "ARN the queue created by terraform"
    value = aws_sqs_queue.queue_process_data.url
}