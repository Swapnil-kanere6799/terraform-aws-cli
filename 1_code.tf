terraform {
  cloud {
    organization = "swapnil-birul"
    workspaces {
      name = "swapnil-birul"
    }
  }
}

# Specify the provider
provider "aws" {
  region = "us-west-2"  # Update the region as necessary
}

# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main_vpc"
  }
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main_igw"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"  # Modify the CIDR block if needed
  availability_zone       = "us-west-2a"    # Adjust the availability zone if needed
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet"
  }
}

# Create a Security Group for the EC2 instance
resource "aws_security_group" "instance_sg" {
  name        = "instance_security_group"
  description = "Allow SSH and HTTP access to the EC2 instance"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow SSH from any IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP from any IP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"  # Update with a valid Amazon Linux 2 AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.instance_sg.name]
  associate_public_ip_address = true  # Ensure the instance gets a public IP

  tags = {
    Name = "web_server"
  }
}
