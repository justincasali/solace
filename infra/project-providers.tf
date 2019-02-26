provider "aws" {
  version = "~> 1.60"
  region  = "${var.region}"
  profile = "${var.profile}"
}

provider "archive" {
  version = "~> 1.1"
}
