resource "aws_sqs_queue" "notificar_qeue" {
  name                      = "notificar-qeue"
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notificar_qeue_dlq.arn
    maxReceiveCount     = 4
  })
  tags = {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "notificar_qeue_dlq" {
  name                      = "notificar-qeue-dlq"
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  tags = {
    Environment = "production"
  }
}