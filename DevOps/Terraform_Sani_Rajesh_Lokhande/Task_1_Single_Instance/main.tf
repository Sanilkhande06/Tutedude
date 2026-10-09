# 1. Declare the Required Providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Pins the major provider version to prevent breaking updates
    }
  }
  required_version = ">= 1.5.0" # Ensures your local Terraform binary version is compatible
}

# 2. Configure the AWS Provider Authentication Context
provider "aws" {
  region = "eu-north-1" # The target AWS geographic deployment region
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
    cidr_blocks = ["0.0.0.0/0"] # For safety, substitute with your own personal IP address
  }

  ingress {
    description = "HTTP web traffic"
    from_port   = 3000
    to_port     = 5500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all outbound traffic from inside the server to the internet
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Define the EC2 Compute Instance Resource
resource "aws_instance" "sani_test_tf_instance" {
  ami                    = "ami-0aba19e56f3eaec05" # Ubuntu 22.04 LTS AMI ID (Double check this value for your region!)
  instance_type          = "t3.micro"              # The hardware instance sizing class tier
  key_name               = "assignments"
  vpc_security_group_ids = [aws_security_group.sani_test_tf_sg.id]

  tags = {
    Name        = "Terraform"
    Environment = "Development"
  }
}

# 5. GENERATE THE ANSIBLE INVENTORY FILE DYNAMICALLY
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/hosts.tpl", {
    web_ips = [aws_instance.sani_test_tf_instance.public_ip]
  })
  filename = "${path.module}/hosts" # Automatically creates 'hosts' in your root directory
}

# 6. Output Parameters (Prints information to the terminal window after creation)
output "server_public_ip" {
  value       = aws_instance.sani_test_tf_instance.public_ip
  description = "The public IP address allocated to your new server instance"
}
