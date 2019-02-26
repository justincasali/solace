variable "project" {
  description = "project name"
}

variable "release" {
  description = "project release"
}

variable "region" {
  description = "aws infrastructure region"
}

variable "profile" {
  description = "aws credential profile"
}

variable "request_timeout" {
  description = "request lambda and sqs timeout"
  default     = 30
}

variable "backup_timeout" {
  description = "backup lambda and sqs timeout"
  default     = 30
}

variable "restore_timeout" {
  description = "restore lambda and sqs timeout"
  default     = 30
}

variable "request_retry" {
  description = "request sqs retry count"
  default     = 3
}

variable "backup_retry" {
  description = "backup sqs retry count"
  default     = 3
}

variable "restore_retry" {
  description = "restore sqs retry count"
  default     = 3
}
