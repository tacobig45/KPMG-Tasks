variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "username" {
}

variable "password" {
    sensitive = true
}

variable "region" {
    type = string
  default = "us-east-1"  
}