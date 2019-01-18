terraform {
  backend "s3" {
    bucket = "170120191813-icelab1"
    key    = "application/terraform.tfstate"
    region = "eu-west-1"
  }
}
