variable "env" {
  description = "The environment (e.g., production, staging, dev)"
  type        = string

  validation {
    condition     = contains(["production", "staging"], var.env)
    error_message = "The 'env' variable must be one of 'production' or 'staging'."
  }
}

variable "project" {
  description = "The project name"
  default     = "metaboatrace"
}

variable "aurora_security_group_id" {
  description = "Security group ID for the Aurora cluster"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones for the RDS cluster"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "database_name" {
  description = "The name of the database"
  default     = "boatrace_origin_data"
}

variable "aurora_cluster_instance_size" {
  type        = number
  description = "The number of instances of Aurora cluster"
}

variable "serverless_v2_max_capacity" {
  description = "Serverless V2 Max Capacity"
  type        = number
}

variable "serverless_v2_min_capacity" {
  description = "Serverless V2 Min Capacity"
  type        = number
}
