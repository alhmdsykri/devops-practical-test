resource "aws_db_instance" "mysql" {
    identifier             = "todo-mysql-db"
    engine                 = "mysql"
    engine_version         = "8.0"
    instance_class         = "db.t3.micro"
    allocated_storage      = 20
    db_name                = "MyWebApiDB"
    username               = var.db_username
    password               = var.db_password
    db_subnet_group_name   = aws_db_subnet_group.rds.name
    vpc_security_group_ids = [aws_security_group.rds.id]
    skip_final_snapshot    = true
    publicly_accessible    = false

    tags = { Name = "todo-mysql-db" }
  }

  output "rds_endpoint" {
    value       = aws_db_instance.mysql.address
    description = "RDS MySQL endpoint"
  }