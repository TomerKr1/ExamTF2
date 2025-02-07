module "vpc_and_ec2" {
  source = "./vpc_and_ec2_module"

  region                = "us-east-1"
  vpc_cidr             = "10.0.0.0/16"
  Private_VPC_Name     = "Tomer-VPC"
  private_Sunbet_Name  = "TomerPrivate-Subnet"
  public_Sunbet_Name   = "TomerPublic-Subnet"
  igw_name             = "Tomer-IGW"
  Route_Table          = "Tomer-Route-Table"
  sg_name              = "Tomer-SG"
  machine_name         = "Tomer-VM"
  vm_size              = "t2.micro"
  subnet_count         = 2 // i didnt know how to use it, but i asked for it.
  assign_public_ip     = true
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.vpc_and_ec2.ec2_public_ip
}
