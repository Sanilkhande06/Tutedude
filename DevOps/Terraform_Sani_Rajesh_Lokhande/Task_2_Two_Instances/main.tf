# 1. Declare the Required Providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

# 2. Configure the AWS Provider Authentication Context
provider "aws" {
  region = "eu-north-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "test_sani_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "test-sani-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.test_sani_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1a"

  tags = {
    Name = "sani-public-subnet"
  }
}

resource "aws_internet_gateway" "sani-igw" {
  vpc_id = aws_vpc.test_sani_vpc.id

  tags = {
    Name = "sani-internet-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.test_sani_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sani-igw.id
  }

  tags = {
    Name = "sani-public-route-table"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


# 3. Define a Security Group (Firewall) Rule
resource "aws_security_group" "sani_test_tf_sg" {
  name        = "sani_test_tf_sg"
  description = "Open common application network interface ports"
  vpc_id      = aws_vpc.test_sani_vpc.id 
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP web traffic"
    from_port   = 2500
    to_port     = 5500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Define the EC2 Compute Instance Resource
resource "aws_instance" "sani_test_tf_instance" {
  ami                    = "ami-0aba19e56f3eaec05" 
  count                  = 2 
  instance_type          = "t3.micro"   
  key_name               = "assignments"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sani_test_tf_sg.id]

  tags = {
    Name = "Sani-Instance-${count.index + 1}"
    Environment = "Development"
  }
}

# 5. GENERATE THE ANSIBLE INVENTORY FILE DYNAMICALLY
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/hosts.tpl", {
    web_ips = [aws_instance.sani_test_tf_instance[0].public_ip, aws_instance.sani_test_tf_instance[1].public_ip]
  })
  filename = "${path.module}/hosts"
}

# 6. Output Parameters (Prints information to the terminal window after creation)
output "server_public_ip" {
  value       = aws_instance.sani_test_tf_instance[*].public_ip
  description = "The public IP address allocated to BOTH EC2 instances"
}
