
provider "aws" {

  region = var.region

}
/* ------------------------------ Task 1 , 2, ------------------------------------*/
resource "time_sleep" "wait_for_ip" {
create_duration = "30s" # Wait for 30 seconds allow AWS to allocate the IP

}


resource "aws_instance" "vm" {
  ami           = var.ami_machine  # Amazon Linux 2 AMI in us-east-1
  instance_type = var.vm_size
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id  = aws_subnet.public.id # connection to the public subnet we created in task1.
  associate_public_ip_address = true  
  
  tags = {
    Name = var.machine_name
  }
  provisioner "local-exec" {
    command = "echo 'Created VM Success! ${var.ami_machine} '"
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





/*----------------------------- Task Task 4: Deploy an Application Load Balancer with Auto Scaling ------------------------- */


/*
for creating the LB, we also needed to do 2 subnets, so i created addition public subnet, 
then we need to create Auto Scalling group with template,
and then we need to do the "Forwarding by the port" like we did in the UI
i added a screen shot if you dont want to run this program. 


btw it was very chanllging and fun!

Also, if we want to create Lb, we need to create Listene that will forawrd
each LB has his own SG so 

LB (checking SG ) --> Listener  will "listen" to request from port and make check protocol & port --> Target Group 
the target group has VPC and he contains the instance we want to forward -- > the EC2 gets the request.




*/



resource "aws_lb" "custom_lb" {
  name               = "TomerK-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id] // has his own SG
  subnets           = [aws_subnet.public.id,aws_subnet.new_public.id]  

  enable_deletion_protection = false

  tags = {
    Name = var.lb_name
  }
    lifecycle {
    ignore_changes = [security_groups]  // ignoring changes of SG.
  }
}
/*
creating a Load balancer Target group, the port 80 is the port that the LB will send to the Ec2
 we will write the VPC so it means we can target evey ec2 instance in our VPC.

 i asked my self 'why the hell we should write the Port and the protocol again?! we already did that in the listener?

 so - every target in our group can be connecter to a port and protocol  and the target will direct the request to the right 
 "path"
e
 The listener moving the Request after checking to the Target, and the target will delever the request to the right instance by the "health"
 the LB will choose which of the instance we have in the TG we will take!

 */

resource "aws_lb_target_group" "custom_tg" {
  name     = "TomerK-tg-tf"
  port     = 80  //  The port on which targets receive traffic, unless overridden when registering a specific target. Required when
  protocol = "HTTP" //  The protocol to use for routing traffic to the targets. Should be one of "TCP", "TLS", "UDP", "TCP_UDP", "HTTP" or "HTTPS
  vpc_id   = aws_vpc.custom_vpc.id

  
  tags = {
    Name = "Custom Target Group"
  }
}

// now after the Lb moving the request, we will use the listener to move it to the Target group
// ** its important to notice that we need to first create the TG because the Listener MUST know where he should send the requests


  resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.custom_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.custom_tg.arn
  }
}


/*
this is the template of the ec2 we will create
*/
resource "aws_launch_template" "custom_lt" {
  
  image_id      = var.ami_machine
  instance_type = var.vm_size
  vpc_security_group_ids = [aws_security_group.sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "TomerMachines!"
    }
  }
}


 // making the mx and min instances as we needed. 
resource "aws_autoscaling_group" "custom_asg" {
  vpc_zone_identifier = [aws_subnet.public.id,aws_subnet.new_public.id]  // where the ASG will put the instances.
  desired_capacity    = 1
  min_size           = 1
  max_size           = 3

  launch_template {
    id      = aws_launch_template.custom_lt.id
    version = "$Latest" 
     

  }

  target_group_arns = [aws_lb_target_group.custom_tg.arn] //each instance that we create, will be connecting to the Target Group
  
  /*
  we want to make sure that we are creating the LB and the Listener before the ASG
  */
   depends_on = [
    aws_lb.custom_lb,  
    aws_lb_listener.http
  ]
}
