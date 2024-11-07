resource "aws_cloudwatch_metric_alarm" "bastion_health" {
  alarm_name          = "bastion_health"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/NetworkELB"
  period              = 60
  statistic           = "Average"
  threshold           = var.desired_num_instances
  alarm_description   = "Number of healthy nodes in Target Group"
  actions_enabled     = "true"
  #   alarm_actions       = [aws_sns_topic.sns.arn]
  #   ok_actions          = [aws_sns_topic.sns.arn]
  dimensions = {
    TargetGroup  = aws_lb_target_group.bastion.arn_suffix
    LoadBalancer = aws_lb.bastion.arn_suffix
  }
}