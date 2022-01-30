# Create a Target Groups for Load Balancer
resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = var.port_http
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id # Referencing the default VPC
}
# Create a listener for  load balancer
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.moon-lb.arn # Referencing our load balancer
  port              = var.port_http
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn # Referencing our tagrte group
  }
}

#Create an application load balancer
resource "aws_alb" "moon-lb" {
  name               = "moon-lb" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = var.port_http # Allowing traffic in from port 80
    to_port     = var.port_http
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol 
    cidr_blocks = [var.all_cidr] # Allowing traffic out to all IP addresses
  }
}