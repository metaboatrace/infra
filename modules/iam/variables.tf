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
