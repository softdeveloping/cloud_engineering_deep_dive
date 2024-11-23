resource "aws_ecs_service" "ecs_service" {
 name            = "${terraform.workspace}-ecs-service"
 cluster         = aws_ecs_cluster.core.id
 task_definition = aws_ecs_task_definition.ecs_task_definition.arn
 desired_count   = 2

 network_configuration {
   subnets         = aws_subnet.core_public[*].id
   security_groups = [aws_security_group.security_group.id]
 }

 force_new_deployment = true
 placement_constraints {
   type = "distinctInstance"
 }

 triggers = {
   redeployment = timestamp()
 }

 capacity_provider_strategy {
   capacity_provider = aws_ecs_capacity_provider.main.name
   weight            = 100
 }

 load_balancer {
   target_group_arn = aws_lb_target_group.ecs_tg.arn
   container_name   = "dockergs"
   container_port   = 80
 }

 depends_on = [aws_autoscaling_group.ecs_asg]
}

resource "aws_iam_role" "ecs_task" {
  name = "${terraform.workspace}-backend-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}