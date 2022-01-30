
# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = var.az1
}
#Create a default subnet b  
resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = var.az2
}
#Create a default subnet c
resource "aws_default_subnet" "default_subnet_c" {
  availability_zone =var.az3
}