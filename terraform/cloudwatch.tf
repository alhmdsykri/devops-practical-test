resource "aws_cloudwatch_log_group" "app" {
    name              = "/todo-webapi/application"
    retention_in_days = 7
  }

  resource "aws_cloudwatch_log_group" "system" {
    name              = "/todo-webapi/system"
    retention_in_days = 7
  }

  resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
    alarm_name          = "todo-ec2-high-cpu"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 120
    statistic           = "Average"
    threshold           = 80
    alarm_description   = "EC2 CPU usage > 80%"
    dimensions = {
      InstanceId = aws_instance.app.id
    }
  }

  resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
    alarm_name          = "todo-rds-high-cpu"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/RDS"
    period              = 120
    statistic           = "Average"
    threshold           = 80
    alarm_description   = "RDS CPU usage > 80%"
    dimensions = {
      DBInstanceIdentifier = aws_db_instance.mysql.identifier
    }
  }

  resource "aws_cloudwatch_metric_alarm" "rds_storage" {
    alarm_name          = "todo-rds-low-storage"
    comparison_operator = "LessThanThreshold"
    evaluation_periods  = 1
    metric_name         = "FreeStorageSpace"
    namespace           = "AWS/RDS"
    period              = 300
    statistic           = "Average"
    threshold           = 2000000000
    alarm_description   = "RDS free storage < 2GB"
    dimensions = {
      DBInstanceIdentifier = aws_db_instance.mysql.identifier
    }
  }