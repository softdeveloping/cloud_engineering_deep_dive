resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${terraform.workspace}-core-cluster"
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${terraform.workspace}-web-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "${terraform.workspace}-web-app01"
    image     = "nginx:latest"  # Replace with your own image if needed
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${terraform.workspace}-web-app01-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets         = aws_subnet.core_private[*].id
    assign_public_ip = true
  }
}