resource "aws_ecs_cluster" "core" {
  name = "${terraform.workspace}-ecs-core"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}