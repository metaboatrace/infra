output "bucket_name" {
  description = "The name of the S3 bucket for SageMaker"
  value       = aws_s3_bucket.sagemaker_bucket.bucket
}

output "role_arn" {
  description = "The ARN of the SageMaker execution role"
  value       = aws_iam_role.sagemaker_execution_role.arn
}
