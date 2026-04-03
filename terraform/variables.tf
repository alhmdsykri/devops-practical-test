variable "aws_region" {
  default = "ap-southeast-1"
}

variable "db_username" {
  default = "tempAdmin"
}

variable "db_password" {
  default   = "!tempAdmin954*"
  sensitive = true
}

variable "key_pair_name" {
  description = "Nama EC2 Key Pair yang sudah dibuat di AWS Console"
  type        = string
}


