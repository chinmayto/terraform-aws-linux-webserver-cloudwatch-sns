####################################################
# Create VPC and components
####################################################

module "vpc" {
  source                        = "./modules/vpc"
  aws_region                    = var.aws_region
  vpc_cidr_block                = var.vpc_cidr_block
  enable_dns_hostnames          = var.enable_dns_hostnames
  vpc_public_subnets_cidr_block = var.vpc_public_subnets_cidr_block
  aws_azs                       = var.aws_azs
  common_tags                   = local.common_tags
  naming_prefix                 = local.naming_prefix
}

####################################################
# Create Web Server Instances
####################################################

module "web" {
  source             = "./modules/web"
  instance_type      = var.instance_type
  instance_key       = var.instance_key
  common_tags        = local.common_tags
  naming_prefix      = local.naming_prefix
  public_subnets     = module.vpc.public_subnets
  security_group_ec2 = module.vpc.security_group_ec2
}

####################################################
# Create an SNS topic with a email subscription
####################################################
resource "aws_sns_topic" "topic" {
  name = "WebServer-CPU_Utilization_alert"

  tags = merge(local.common_tags, {
    Name = "${local.naming_prefix}-sns-topic"
  })
}

resource "aws_sns_topic_subscription" "topic_email_subscription" {
  count     = length(var.email_address)
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = var.email_address[count.index]
}

####################################################
# Create a cloudwatch alarm for EC2 instances and alarm_actions to SNS topic
####################################################
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60" #seconds
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.topic.arn]

  count      = length(module.web.instance_ids)
  alarm_name = "cpu-utilization-${element(module.web.instance_ids, count.index)}"
  dimensions = {
    InstanceId = element(module.web.instance_ids, count.index)
  }
  tags = merge(local.common_tags, {
    Name = "${local.naming_prefix}-cloudwatch-alarm"
  })
}
