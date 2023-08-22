provider "aws" {
  region = "us-west-2"  # Choose your desired region
}

resource "aws_security_group" "services_sg" {
  name = "services-sg"

  // Define your security group rules here
}

resource "aws_launch_configuration" "service_lc" {
  name_prefix   = "service-lc"
  image_id      = "template_name"  # Replace with your desired AMI ID
  instance_type = "t2.micro"      # Replace with your desired instance type

  // Other configuration settings
}

resource "aws_autoscaling_group" "service_asg" {
  name                 = "service-asg"
  launch_configuration = aws_launch_configuration.service_lc.name
  min_size             = 2
  max_size             = 5
  desired_capacity     = 2

  // Other auto scaling settings
}

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  enable_deletion_protection = false  # Disable this in production

  subnets = ["subnet1", "subnet2"]  # Replace with your subnet IDs

  enable_http2      = true
  enable_cross_zone_load_balancing = true

  enable_deletion_protection = false  # Disable this in production

  enable_http2      = true
  enable_cross_zone_load_balancing = true

  security_groups = [aws_security_group.services_sg.id]

  enable_deletion_protection = false  # Disable this in production

  enable_http2      = true
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_target_group" "app_tg" {
  name        = "app-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "vpc-a"  # Replace with your VPC ID

  health_check {
    enabled = true
    interval = 30
    path = "/"
    protocol = "HTTP"
    matcher = "200-299"
    timeout = 10
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.app_tg.arn
    type             = "forward"
  }
}
