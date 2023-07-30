terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CNG-CAP-AmazonLinux2-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "test_vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name    = "test-vpc"
    Purpose = "testing"
  }
}

resource "aws_internet_gateway" "test_internet_gateway" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "test_internet_gateway"
  }
}

resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0"
    gateway_id = aws_internet_gateway.test_internet_gateway.id
  }
  tags = {
    Name = "route_table1"
  }
}
resource "aws_route_table_association" "route_table1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route_table1.id
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 1)
  availability_zone = var.availability_zone[0]

  tags = {
    Name = "Subnet1"
    type = "Public"
  }
}

resource "aws_security_group" "test_sg" {
  name        = "test_sg"
  description = "Allow http"
  vpc_id      = aws_vpc.test_vpc.id

  dynamic "ingress" {
    for_each = var.webserver_sg_rules.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  dynamic "egress" {
    for_each = var.webserver_sg_rules.egress_rules
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = {
    Name = "Allow_http_connection"
  }
}


resource "aws_instance" "web" {
  ami                         = "ami-0f9ce67dcf718d332"
  instance_type               = "t2.micro"
  count                       = 2
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.test_sg.id]
  subnet_id                   = aws_subnet.subnet1.id
  associate_public_ip_address = true
  user_data                   = filebase64("${path.module}/userdata.sh")
  tags = {
    Name = "Webserver-${count.index}"
  }
}
