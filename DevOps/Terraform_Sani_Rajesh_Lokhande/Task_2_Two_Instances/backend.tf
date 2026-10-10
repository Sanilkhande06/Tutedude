terraform {
  backend "s3" {
    bucket = "sani-terraform-state-bucket-101010" 
    key    = "Task2/terraform.tfstate"
    region = "eu-north-1"
  }
}