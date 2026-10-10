terraform {
  backend "s3" {
    bucket = "sani-terraform-state-bucket-101010" 
    key    = "Task1/terraform.tfstate"
    region = "eu-north-1"
  }
}