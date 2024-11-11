resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${terraform.workspace}-ecs-cluster"
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${terraform.workspace}-ecs-task"
  container_definitions    = file("${path.module}/container_definitions.json")
  requires_compatibilities = ["EC2"]
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${terraform.workspace}-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "${terraform.workspace}-ecs-container"
    container_port   = 80
  }
}

resource "aws_ecs_capacity_provider" "ecs_provider" {
  name = "${terraform.workspace}-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 75
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 100
    }
    managed_termination_protection = "ENABLED"
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_providers" {
  cluster_name = aws_ecs_cluster.ecs_cluster.id
  capacity_providers = [
    aws_ecs_capacity_provider.ecs_provider.name,
  ]
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_provider.name
    weight            = 1
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  launch_configuration = aws_launch_configuration.ecs_config.id
  vpc_zone_identifier  = aws_subnet.core_private[*].id
  desired_capacity     = 2
  min_size             = 1
  max_size             = 5
}

resource "aws_launch_configuration" "ecs_config" {
  image_id      = "ami-12345678" # Use an appropriate AMI ID
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name
  security_groups      = [aws_security_group.ec2_sg.id]
}

resource "aws_appautoscaling_policy" "cpu_scale_up" {
  name                   = "${terraform.workspace}-ecs-scale-up"
  resource_id            = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension     = "ecs:service:DesiredCount"
  service_namespace      = "ecs"
  policy_type            = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    target_value       = 75.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_out_cooldown = 300
    scale_in_cooldown  = 300
  }
}
