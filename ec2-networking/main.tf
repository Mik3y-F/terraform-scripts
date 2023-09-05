terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region = "eu-west-1"
}

variable "ssh_port" {
  default = "22"
}

variable "http_port" {
  default = "8080"
}

variable "public_cidr_block" {
  default = "10.0.0.0/24"
}

variable "private_cidr_block" {
  default = "10.0.1.0/24"
}

variable "availability_zone" {
  default = "eu-west-1a"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "main_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main"
  }
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gateway.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "PrivateRouteTable"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet.id
}


resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_cidr_block

  # Typically in a production env, you would have multiple subnets in different AZs
  availability_zone = var.availability_zone

  tags = {
    Name = "PublicSubnet"
  }

}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_cidr_block

  # Typically in a production env, you would have multiple subnets in different AZs
  availability_zone = var.availability_zone

  tags = {
    Name = "PrivateSubnet"
  }

}

resource "aws_key_pair" "nerium_admin" {
  key_name   = "nerium-admin"
  public_key = file("~/.ssh/nerium.pub")
}

resource "aws_security_group" "SGPublic" {
  name        = "SGPublic"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "SGPrivate" {
  name        = "SGPrivate"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "public_instance" {
  ami                         = "ami-01b1f2cdbfcb3644e"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.SGPublic.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.http_port} &
              EOF

  key_name = aws_key_pair.nerium_admin.key_name

  tags = {
    Name = "public_instance"
  }

  depends_on = [aws_internet_gateway.main_gateway, aws_key_pair.nerium_admin]
}


resource "aws_instance" "private_instance" {
  ami                         = "ami-01b1f2cdbfcb3644e"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet.id
  vpc_security_group_ids      = [aws_security_group.SGPrivate.id]
  associate_public_ip_address = false

  key_name = aws_key_pair.nerium_admin.key_name

  tags = {
    Name = "private_instance"
  }
}


output "public_ip" {
  value       = aws_instance.public_instance.public_ip
  description = "The public IP address of the web server"
}
