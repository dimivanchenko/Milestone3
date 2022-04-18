#provider "aws" {
#  profile                 = "default" 
#  region                  = "eu-north-1"
#}

#terraform {
#  backend "s3" {
#    bucket         = "dim-for-terragrunt-itacad"
#    key            = "terraform.tfstate"
#    region         = "eu-north-1"
#    encrypt        = true
#  }
#}

resource "aws_instance" "T_UbuntuServer" {
  ami                    = "ami-092cce4a19b438926"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.T_UbuntuSecGr.id]
  key_name= "aws_key"
  
  tags = {
    Name = "T_UbuntuServer"
  }

#  depends_on = [aws_instance.T_AmazonLinuxServer]
}

resource "aws_instance" "T_AmazonLinuxServer" {
  ami           = "ami-013126576e995a769"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.T_AmazonSecGr.id]
  key_name= "aws_key"
  tags = {
    Name = "T_AmazonLinuxServer"
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "aws_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "T_UbuntuSecGr" {
  name        = "T_UbuntuSecGr"
  description = "T_UbuntuSecGr"

  ingress {
    description = "WebServer"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["195.34.128.0/18"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["195.34.128.0/18"]
  }
  ingress {
    description = "SMTP"
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "T_UbuntuSecGr"
  }
}

resource "aws_security_group" "T_AmazonSecGr" {
  name        = "T_AmazonSecGr"
  description = "T_AmazonSecGr"

  ingress {
    description = "SQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.T_UbuntuServer.public_ip}/32"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["195.34.128.0/18"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "T_AmazonSecGr"
  }
}

resource "local_file" "public_ip" {
  content  = <<EOT
[app_servers]
${aws_instance.T_UbuntuServer.public_ip}

[sql_servers]
${aws_instance.T_AmazonLinuxServer.public_ip}
  EOT
  file_permission   = "0664"
  filename          = "~/Ansible/hosts.txt"
}

resource "local_file" "vars_for_Ansible" {
  content  = <<EOT
---
appIP: ${aws_instance.T_UbuntuServer.public_ip}

sqlIP: ${aws_instance.T_AmazonLinuxServer.public_ip}
  EOT
  file_permission   = "0664"
  filename          = "~/Ansible/vars.yml"
}



output "Ununtu_Ip_Address" {
  value = aws_instance.T_UbuntuServer.public_ip
}

output "DB_Ip_Address" {
  value = aws_instance.T_AmazonLinuxServer.public_ip
}
