#### Security Groups ####

# Load balancer
resource "aws_security_group" "bastion_lb" {
  name        = "Load Balancer SG"
  description = "Allow connection to NLB"
  vpc_id      = data.aws_vpc.main.id
}

# Load balancer only accepts traffic on defined SSH port and allowed CIDRs
resource "aws_vpc_security_group_ingress_rule" "lb" {
  for_each          = toset(var.allowed_cidrs)
  security_group_id = aws_security_group.bastion_lb.id
  from_port         = var.ssh_port
  to_port           = var.ssh_port
  ip_protocol       = "tcp"
  cidr_ipv4         = each.key
}

resource "aws_vpc_security_group_egress_rule" "lb" {
  security_group_id = aws_security_group.bastion_lb.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
}


# Bastion Host (EC2)
resource "aws_security_group" "bastion_host" {
  name        = "Bastion Host SG"
  description = "Allow connection between NLB and Bastion"
  vpc_id      = data.aws_vpc.main.id
}

# Bastion Host only accepts traffic from Load Balancer
resource "aws_vpc_security_group_ingress_rule" "host" {
  security_group_id            = aws_security_group.bastion_host.id
  from_port                    = var.ssh_port
  to_port                      = var.ssh_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion_lb.id
}

resource "aws_vpc_security_group_egress_rule" "host" {
  security_group_id = aws_security_group.bastion_host.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
}