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

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}
