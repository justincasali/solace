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
}

variable "backup_timeout" {
  description = "backup lambda and sqs timeout"
}

variable "restore_timeout" {
  description = "restore lambda and sqs timeout"
}
