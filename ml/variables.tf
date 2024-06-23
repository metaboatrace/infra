variable "bucket_name" {
  description = "The name of the S3 bucket to use for SageMaker"
  type        = string
}

variable "role_name" {
  description = "The name of the IAM role for SageMaker"
  type        = string
  default     = "sagemaker-execution-role"
}
