provider "aws" {

  region = var.region

}
resource "time_sleep" "wait_for_ip" {
create_duration = "30s" # Wait for 1 minute to allow AWS to allocate the IP

}


resource "aws_instance" "vm" {
  ami           = "ami-0ff8a91507f77f867"  # Amazon Linux 2 AMI in us-east-1
  instance_type = var.vm_size
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id  = aws_subnet.public.id # connection to the public subnet we created in task1.
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

  depends_on = [time_sleep.wait_for_ip, aws_instance.vm]
}


/*
for creating the LB, we also needed to do 2 subnets, so i created addition public subnet, 
then we need to create Auto Scalling group with template,
and then we need to do the "Forwarding by the port" like we did in the UI
i added a screen shot if you dont want to run this program. 


btw it was very chanllging and fun!



*/



resource "aws_lb" "custom_lb" {
  name               = "TomerK-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets           = [aws_subnet.public.id,aws_subnet.new_public.id] # שימוש בתת-הרשתות הקיימות

  enable_deletion_protection = false

  tags = {
    Name = var.lb_name
  }
}

 // the forwarding like we did in the UI. (here is much more easy!)
resource "aws_lb_target_group" "custom_tg" {
  name     = "TomerK-tg-tf"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom_vpc.id

  
  tags = {
    Name = "Custom Target Group"
  }
}

#after checking we have to add listner so we can make a role that every time we see http request we will target it to the ec2
  resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.custom_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.custom_tg.arn
  }
}


resource "aws_launch_template" "custom_lt" {
  name_prefix   = "custom-lt-"
  image_id      = "ami-0ff8a91507f77f867"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "TomerMachines!"
    }
  }
}



resource "aws_autoscaling_group" "custom_asg" {
  vpc_zone_identifier = [aws_subnet.public.id,aws_subnet.new_public.id] 
  desired_capacity    = 1
  min_size           = 1
  max_size           = 3

  launch_template {
    id      = aws_launch_template.custom_lt.id
    version = "$Latest"
    

  }

  target_group_arns = [aws_lb_target_group.custom_tg.arn]
  
   depends_on = [
    aws_lb.custom_lb,
    aws_lb_listener.http
  ]
}
