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

variable "compression_level" {
  description = "zlib compression level, -1 is default compromise"
  default     = -1
}

variable "backup_count" {
  description = "backup sqs max receive count"
  default     = 3
}

variable "backup_timeout" {
  description = "backup lambda & sqs timeout"
  default     = 30
}

variable "backup_delay" {
  description = "backup sqs delay seconds"
  default     = 0
}

variable "restore_count" {
  description = "restore sqs max receive count"
  default     = 3
}

variable "restore_timeout" {
  description = "restore lambda & sqs timeout"
  default     = 30
}

variable "restore_delay" {
  description = "restore sqs delay seconds"
  default     = 0
}
