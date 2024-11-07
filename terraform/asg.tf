#### AutoScaling Configuration ####

resource "aws_autoscaling_attachment" "bastion" {
  autoscaling_group_name = aws_autoscaling_group.bastion.name
  lb_target_group_arn    = aws_lb_target_group.bastion.arn
}

resource "aws_launch_template" "bastion" {
  name_prefix                          = "bastion-"
  image_id                             = data.aws_ami.bastion.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = var.instance_type
  key_name                             = "bastion"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.bastion_host.id]
    delete_on_termination       = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Bastion"
    }
  }
}

resource "aws_autoscaling_group" "bastion" {
  name_prefix               = "bastion-"
  max_size                  = var.desired_num_instances
  min_size                  = var.desired_num_instances
  vpc_zone_identifier       = data.aws_subnets.private.ids
  force_delete              = true
  health_check_grace_period = 300
  health_check_type         = "ELB"
  default_instance_warmup   = 60
  target_group_arns         = [aws_lb_target_group.bastion.arn]
  protect_from_scale_in     = true
  termination_policies      = ["OldestLaunchTemplate", "OldestInstance", "ClosestToNextInstanceHour"]

  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }

  instance_maintenance_policy {
    max_healthy_percentage = 110
    min_healthy_percentage = 100
  }
}