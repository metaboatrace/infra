output "bucket_name" {
  description = "The name of the S3 bucket for SageMaker"
  value       = aws_s3_bucket.sagemaker_bucket.bucket
}
