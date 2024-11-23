resource "aws_ecs_capacity_provider" "main" {
 name = "${terraform.workspace}-ecs-core-provider"

 auto_scaling_group_provider {
   auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

   managed_scaling {
     maximum_scaling_step_size = 1000
     minimum_scaling_step_size = 1
     status                    = "ENABLED"
     target_capacity           = 3
   }
 }
}

resource "aws_ecs_cluster_capacity_providers" "core" {
 cluster_name = aws_ecs_cluster.core.name

 capacity_providers = [aws_ecs_capacity_provider.main.name]

 default_capacity_provider_strategy {
   base              = 1
   weight            = 100
   capacity_provider = aws_ecs_capacity_provider.main.name
 }
}

resource "aws_iam_role" "ecs_instance" {
  name = "${terraform.workspace}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${terraform.workspace}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance.name
}