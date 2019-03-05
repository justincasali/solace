variable "env" {
  description = "project environment"
}

variable "region" {
  description = "aws infrastructure region"
}

variable "profile" {
  description = "aws credential profile"
}

variable "max_segments" {
  description = "maximum segments permitted per task"
  default     = 64
}

variable "backup_attempts" {
  description = "backup lambda attempts per batch"
  default     = 3
}

variable "backup_timeout" {
  description = "backup lambda and sqs timeout, time inbetween attempts"
  default     = 30
}

variable "backup_spacing" {
  description = "backup batch spacing in seconds"
  default     = 0
}

variable "restore_attempts" {
  description = "restore lambda attempts per batch"
  default     = 3
}

variable "restore_timeout" {
  description = "backup lambda and sqs timeout, time inbetween attempts"
  default     = 30
}

variable "restore_spacing" {
  description = "restore batch spacing in seconds"
  default     = 0
}

variable "compression_level" {
  description = "zlib compression level"
  default     = -1
}

variable "request_timeout" {
  description = "request lambda and sqs timeout"
  default     = 15
}

variable "redrive_timeout" {
  description = "redrive lambda and sqs timeout"
  default     = 15
}
