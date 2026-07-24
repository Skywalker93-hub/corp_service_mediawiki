// Application Load Balancer (Internal)
resource "aws_lb" "proxy_alb" {
  name               = "proxy-alb-int"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.subnet2.id,
    aws_subnet.subnet3.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "proxy-alb-int"
  }
}

// Target Group for HTTP
resource "aws_lb_target_group" "proxy_alb_tg" {
  name     = "proxy-alb-tg-int"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_net.id

  health_check {
    protocol            = "HTTP"
    path                = "/"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "proxy-alb-tg-int"
  }
}

// Listener for HTTP
resource "aws_lb_listener" "proxy_listener_http" {
  load_balancer_arn = aws_lb.proxy_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.proxy_alb_tg.arn
  }
}

// Attach proxy 1 to Target Group
resource "aws_lb_target_group_attachment" "proxy1_att" {
  target_group_arn = aws_lb_target_group.proxy_alb_tg.arn
  target_id        = aws_instance.nginxproxy1.id
  port             = 80
}

// Attach proxy 2 to Target Group
resource "aws_lb_target_group_attachment" "proxy2_att" {
  target_group_arn = aws_lb_target_group.proxy_alb_tg.arn
  target_id        = aws_instance.nginxproxy2.id
  port             = 80
}
