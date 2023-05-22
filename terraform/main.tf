provider "aws" {
  region = var.aws_region
  ########################################
  #   login aws on github action workflow
  shared_credentials_files = ["/home/lawrence/.aws/credentials"]
  ########################################
  # access_key = "AKIAVJTYHS7LVFWANOLT"
  # secret_key = "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"
}