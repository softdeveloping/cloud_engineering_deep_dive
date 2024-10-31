resource "aws_subnet" "ecs_subnet" {
  vpc_id            = aws_vpc.core.id
  cidr_block        = "10.0.100.0/24"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${terraform.workspace}-infra-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${terraform.workspace}-infra-cluster"
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "my-ecs-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "app1-container"
      image     = "nginx:latest"
      cpu       = 128
      memory    = 256
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
    },
    {
      name      = "app2-container"
      image     = "httpd:latest"
      cpu       = 128
      memory    = 256
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 8080
      }]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 2

  launch_type = "EC2"
}



# IAM Role for ECS Instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "${terraform.workspace}-infra-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "ec2.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


# IAM Instance Profile
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ecs_instance_role.name
}

