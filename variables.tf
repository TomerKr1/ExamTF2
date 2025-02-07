variable "region" {
  default = "us-east-1"
}

variable "Private_VPC_Name" {
    type = string
    description = "This is the name of the VPC"
    default = "Tomer-VPC"
  
}

variable "private_Sunbet_Name" {
    type = string
    description = "This is the name of the private subnet"
    default = "TomerPrivate-Subnet"
  
}
variable "public_Sunbet_Name" {
    type = string
    description = "This is the name of the public subnet"
    default = "TomerPublic-Subnet"
  
}
variable "igw_name" {

   type = string
    description = "This is the name of the GETWAY "
    default = "Tomer-IGW"
}



variable "Route_Table" {

   type = string
    description = "This is the name of the RouteTable "
    default = "Tomer-Route-Table"
}
variable "sg_name" {

   type = string
    description = "This is the name of the Security group "
    default = "Tomer-SG"
}
variable "machine_name" {

   type = string
    description = "This is the name of the machine "
    default = "Tomer-VM"
}
variable "vm_size" {
default = "t2.micro"
}
variable "lb_name" {
type = string
    description = "This is the name of the LB "
    default = "Tomer-lb"
}

variable "ami_machine" {
    type = string
    description = "this is the AMI of the vm"
    default = "ami-0ff8a91507f77f867"
  
}