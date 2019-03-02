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
  description = "maximum segments per task"
  default     = 64
}

variable "compression_level" {
  description = "zlib compression level"
  default     = -1
}

variable "request_timeout" {
  default = 15
}

variable "backup_task" {
  type = "map"

  default = {
    count   = 3
    timeout = 30
    delay   = 0
  }
}

variable "restore_task" {
  type = "map"

  default = {
    count   = 3
    timeout = 30
    delay   = 0
  }
}

variable "redrive_timeout" {
  default = 15
}
