provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "terraform-backends-for-testing"
    region = "us-east-1"
    key = "backend.tfstate"
    
  }
}
resource "aws_key_pair" "Heimdall-key" {
  key_name   = "Heimdall-infra-${random_pet.server.id}-${random_id.server.dec}"
  public_key = file("./id_rsa.pub")
}

resource "random_id" "server" {
  byte_length = 8
}

resource "random_pet" "server" {
  length = 1
}
