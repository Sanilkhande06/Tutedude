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

# 3. Define a Security Group (Firewall) Rule
resource "aws_security_group" "sani_test_tf_sg" {
  name        = "sani_test_tf_sg"
  description = "Open common application network interface ports"

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
