#### Load Balancer Config ####

resource "aws_lb" "bastion" {
  name                             = "bastion"
  internal                         = false
  load_balancer_type               = "network"
  subnets                          = data.aws_subnets.public.ids
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false
  security_groups                  = [aws_security_group.bastion_lb.id]
}

resource "aws_lb_listener" "ssh" {
  load_balancer_arn = aws_lb.bastion.arn
  protocol          = "TCP"
  port              = var.ssh_port

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bastion.arn
  }
}

resource "aws_lb_target_group" "bastion" {
  name     = "bastion"
  port     = var.ssh_port
  protocol = "TCP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    port                = var.ssh_port
    protocol            = "tcp"
    timeout             = 30
    unhealthy_threshold = 3
  }

  lifecycle {
    create_before_destroy = true
  }
}