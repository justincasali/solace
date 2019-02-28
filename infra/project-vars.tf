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
  description = "request lambda & sqs timeout"
  default     = 15
}

variable "backup_count" {
  description = "backup sqs max receive count"
  default     = 3
}

variable "backup_timeout" {
  description = "backup lambda & sqs timeout"
  default     = 30
}

variable "restore_count" {
  description = "restore sqs max receive count"
  default     = 3
}

variable "restore_timeout" {
  description = "restore lambda & sqs timeout"
  default     = 30
}
