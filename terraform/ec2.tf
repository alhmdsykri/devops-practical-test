data "aws_ami" "ubuntu" {             
    most_recent = true
    owners      = ["099720109477"]
    filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
  }

  resource "aws_instance" "app" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.ec2.id]
    key_name               = var.key_pair_name
    iam_instance_profile   = aws_iam_instance_profile.ec2.name

    user_data = base64encode(file("${path.module}/../scripts/deploy.sh"))

    tags = { Name = "todo-webapi-server" }
  }

  output "ec2_public_ip" {
    value       = aws_instance.app.public_ip
    description = "Public IP EC2 instance"
  }

  output "s3_bucket_name" {
    value       = aws_s3_bucket.app.bucket
    description = "Nama S3 bucket untuk binary app"
  }