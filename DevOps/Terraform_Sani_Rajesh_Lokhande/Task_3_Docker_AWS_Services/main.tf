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

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.test_sani_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1b"

  tags = {
    Name = "sani-public-subnet_2"
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

resource "aws_security_group" "sani_test_tf_sg" {
  name        = "sani_test_tf_sg"
  description = "Open common application network interface ports"

  vpc_id      = aws_vpc.test_sani_vpc.id 

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
    protocol    = "tcp"5
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all outbound traffic from inside the server to the internet
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "backend_repo" {
  name                 = "jenkins_cicd_sani_rajesh_lokhande-backend" # The name of your Docker image container
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # Automatically scans your built code for safety updates
  }

  tags = {
    Environment = "Dev"
    Project     = "DevOps-tutedude"
  }
}

resource "aws_ecr_repository" "frontend_repo" {
  name                 = "jenkins_cicd_sani_rajesh_lokhande-frontend" # The name of your Docker image container
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # Automatically scans your built code for safety updates
  }

  tags = {
    Environment = "Dev"
    Project     = "DevOps-tutedude"
  }
}

resource "terraform_data" "run_local_ansible" {
  # Wait until both backend and frontend ECR repositories are created
  depends_on = [
    aws_ecr_repository.backend_repo,
    aws_ecr_repository.frontend_repo
  ]

  provisioner "local-exec" {
    # Runs the playbook locally, passing ECR repository URLs straight to Ansible variables
    command = <<EOT
      ansible-playbook -i "localhost," -c local docker_ecr_image_push.yml \
        --extra-vars "backend_repo=${aws_ecr_repository.backend_repo.repository_url} frontend_repo=${aws_ecr_repository.frontend_repo.repository_url}"
    EOT
    environment = {
      AWS_ACCESS_KEY_ID     = var.access_key
      AWS_SECRET_ACCESS_KEY = var.secret_key
    }
  }
}

# 1. Create the Core ECS Cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = "sani-devops-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# 3. Backend Task Definition
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "sani-backend-task"
  network_mode             = "awsvpc" # Required for Fargate
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256    # 0.25 vCPU
  memory                   = 512    # 512 MB RAM
  execution_role_arn       = "arn:aws:iam::881893827429:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "jenkins_cicd_sani_rajesh_lokhande-backend"
      image     = "${aws_ecr_repository.backend_repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}

# 5. Frontend Task Definition
resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "sani-frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "arn:aws:iam::881893827429:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "jenkins_cicd_sani_rajesh_lokhande-frontend"
      image     = "${aws_ecr_repository.frontend_repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
}

resource "aws_lb" "student_LB" {
  name               = "sani-app-alb"
  internal           = false # Internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sani_test_tf_sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "sani-app-alb"
  }
}
no
resource "aws_lb_target_group" "backend_tg" {
  name        = "sani-backend-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.test_sani_vpc.id
  target_type = "ip" # Required for Fargate network mode 'awsvpc'

  health_check {
    path                = "/"
    port                = "5000"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "frontend_tg" {
  name        = "sani-frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.test_sani_vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = "3000"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ALB Listener for Backend (Port 5000)
resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.student_LB.arn
  port              = "5000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}


# ALB Listener for Frontend (Port 3000)
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.student_LB.arn
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}


# 4. Backend ECS Fargate Service
resource "aws_ecs_service" "backend_service" {
  name            = "sani-backend-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]
    security_groups  = [aws_security_group.sani_test_tf_sg.id]
    assign_public_ip = true # Required to allow Fargate to reach out and pull from ECR
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = "jenkins_cicd_sani_rajesh_lokhande-backend"
    container_port   = 5000
  }
}


# 6. Frontend ECS Fargate Service
resource "aws_ecs_service" "frontend_service" {
  name            = "sani-frontend-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]
    security_groups  = [aws_security_group.sani_test_tf_sg.id]
    assign_public_ip = true
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "jenkins_cicd_sani_rajesh_lokhande-frontend"
    container_port   = 3000
  }
}
