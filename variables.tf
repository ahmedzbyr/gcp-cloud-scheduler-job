variable "name" {
  description = "Name of the job"
  type        = string
}

variable "description" {
  description = "A human-readable description for the job. This string must not contain more than 500 characters."
  type        = string

  validation {
    condition     = length(var.description) < 500
    error_message = "Description must not contain more than 500 characters."
  }
}

variable "time_zone" {
  description = "Specifies the time zone to be used in interpreting schedule. The value of this field must be a time zone name from the tz database."
  type        = string
  default     = null
}

variable "retry_config" {
  description = "Retry config for the job"
  type        = any
  default     = null
}

variable "pubsub_target" {
  description = "Pub/Sub target"
  type        = any
  default     = null
}

variable "http_target" {
  description = "HTTP target"
  type        = any
  default     = null
}

variable "region" {
  description = "Region where the scheduler job resides."
  type        = string
  default     = "us-central1"
}

variable "project" {
  description = "The ID of the project in which the resource belongs. "
  type        = string
}

