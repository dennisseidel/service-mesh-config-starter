provider "aws" {
  # access_key = "${var.aws_access_key}" use environment variables
  # secret_key = "${var.aws_secret_key}" use environment variables
  region  = "${var.region}" # e.g. "us-east-1"
}
