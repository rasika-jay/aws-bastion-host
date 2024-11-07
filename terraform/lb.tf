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
  port              = 22

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bastion.arn
  }
}

resource "aws_lb_target_group" "bastion" {
  name     = "bastion"
  port     = 22
  protocol = "TCP"
  vpc_id   = data.aws_vpc.main.id

  lifecycle {
    create_before_destroy = true
  }
}