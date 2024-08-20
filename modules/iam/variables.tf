variable "env" {
  description = "The environment (e.g., prod, staging, dev)"
  type        = string

  validation {
    condition     = contains(["prod", "staging", "dev"], var.env)
    error_message = "The 'env' variable must be one of 'prod', 'staging', or 'dev'."
  }
}

variable "project" {
  description = "The project name"
  default     = "realworld-example"
}
