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

variable "max_segments" {
  description = "maximum segments & concurrent lambdas per task"
  default     = 64
}

variable "compression_level" {
  description = "zlib compression level, -1 is default compromise"
  default     = -1
}

variable "request_timeout" {
  default = 15
}

variable "redrive_timeout" {
  default = 15
}

variable "backup_queue" {
  type = "map"

  default = {
    count   = 3
    timeout = 30
    delay   = 0
  }
}

variable "restore_queue" {
  type = "map"

  default = {
    count   = 3
    timeout = 30
    delay   = 0
  }
}
