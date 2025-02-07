provider "aws" {
  region = var.region
}


resource "time_sleep" "wait_for_ip" {
  create_duration = "1m" 
}

resource "aws_instance" "vm" {
  ami                    = "ami-0ff8a91507f77f867"  # Amazon Linux 2 AMI ב-us-east-1
  instance_type          = var.vm_size
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.public.id 
  associate_public_ip_address = true  

  tags = {
    Name = var.machine_name
  }
}


resource "null_resource" "validate_ip" {
  provisioner "local-exec" {
    command = <<EOT
                retries=4
                interval=30
                for i in $(seq 1 $retries); do
                  if [ -z "${aws_instance.vm.public_ip}" ]; then
                    echo "Attempt $i: Public IP address not assigned yet, retrying in $interval seconds..."
                    sleep $interval
                  else
                    echo "Public IP address assigned: ${aws_instance.vm.public_ip}"
                    exit 0
                  fi
                done
                echo "ERROR: Public IP address was not assigned after $retries attempts." >&2
                exit 1
                EOT
  }
    triggers = {
  always_run = timestamp()
  }

  depends_on = [time_sleep.wait_for_ip, aws_instance.vm]
}
