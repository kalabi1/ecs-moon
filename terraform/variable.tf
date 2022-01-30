variable "az1" {
    default = "eu-west-2a"
    description = "availability zone to use"
}
variable "az2" {
    default = "eu-west-2b"
    description = "availability zone to use"
}

variable "az3" {
    default = "eu-west-2c"
    description = "availability zone to use"
}
variable "port_http" {
    default = 80
    description = "port for http and load balancer"
}
variable "all_cidr" {
    default = "0.0.0.0/0"
    description = "cidr block for all"
}
variable "memory" {
    default = 512
    description = "memory unit attached to the container"
}
variable "cpu" {
    default = 256
    description = "cpu unit attached to the container"
}
variable "port_container" {
    default = 3000
    description = "port attahced to the container"
}
