variable "region" {
  default = "us-east-1"

}
variable "instance_type" {
  default = "t2.micro"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "subnet_az" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}