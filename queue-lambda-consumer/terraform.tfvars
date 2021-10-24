aws_credentials = {
  access_key = ""
  secret_key = ""
}

s3 = {
  bucket         = "my-terraform-test-bucket-tiagorosadacosta123456789"
  file_to_upload = "./hello.txt"
}

queue_process_data =  {
  name                       = "process_data"
  visibility_timeout_seconds = 300
  delay_seconds              = 90
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 10
}