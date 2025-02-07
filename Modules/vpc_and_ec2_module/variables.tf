variable "region" {
  default = "us-east-1"
}

variable "Private_VPC_Name" {
  type        = string
  description = "This is the name of the VPC"
  default     = "Tomer-VPC"
}

variable "private_Sunbet_Name" {
  type        = string
  description = "This is the name of the private subnet"
  default     = "TomerPrivate-Subnet"
}

variable "public_Sunbet_Name" {
  type        = string
  description = "This is the name of the public subnet"
  default     = "TomerPublic-Subnet"
}

variable "igw_name" {
  type        = string
  description = "This is the name of the IGW"
  default     = "Tomer-IGW"
}

variable "Route_Table" {
  type        = string
  description = "This is the name of the Route Table"
  default     = "Tomer-Route-Table"
}

variable "sg_name" {
  type        = string
  description = "This is the name of the Security Group"
  default     = "Tomer-SG"
}

variable "machine_name" {
  type        = string
  description = "This is the name of the machine"
  default     = "Tomer-VM"
}

variable "vm_size" {
  type        = string
  description = "this is the type of the machine."
  
}

variable "ami_machine" {
    type = string
    description = "this is the AMI of the vm"
    default = "ami-0ff8a91507f77f867"
  
}
variable "subnet_count" {}

variable "vpc_cidr" {
  type        = string
  description = "CIDR range for the VPC"
  default     = "10.0.0.0/16"
}

variable "assign_public_ip" {
  type        = bool
  description = "Whether to assign a public IP to instances"
  default     = true
}
