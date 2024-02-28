resource "aws_sqs_queue" "atualiza_status_pedido_qeue" {
  name                      = "atualiza-status-pedido-qeue"
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.atualiza_status_pedido_qeue_dlq.arn
    maxReceiveCount     = 4
  })
  tags = {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "atualiza_status_pedido_qeue_dlq" {
  name                      = "atualiza-status-pedido-qeue-dlq"
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  tags = {
    Environment = "production"
  }
}