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

variable "subnet_ids" {
  description = "A list of subnet IDs for the ECS tasks"
  type        = list(string)
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "crawler_target_group_arn" {
  description = "The ARN of the target group for the ECS service for the crawler app"
  type        = string
}

variable "crawler_ecs_task_cpu" {
  type        = number
  description = "The CPU for crawler ECS task"
  default     = 256
}

variable "crawler_ecs_task_memory" {
  type        = number
  description = "The memory for crawler ECS task"
  default     = 512
}

variable "crawler_security_group_id" {
  description = "Security group ID for the crawler app"
  type        = string
}
