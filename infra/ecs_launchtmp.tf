resource "aws_launch_template" "ecs_lt" {
 name_prefix   = "ecs-template"
 image_id      = "ami-05df9ff28520b44e8"
 instance_type = "t3.xlarge"

 key_name = aws_key_pair.core_instance_access.key_name
 vpc_security_group_ids = [aws_security_group.security_group.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

 block_device_mappings {
   device_name = "/dev/xvda"
   ebs {
     volume_size = 30
     volume_type = "gp2"
   }
 }

 tag_specifications {
   resource_type = "instance"
   tags = {
     Name = "ecs-instance"
   }
 }

   user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${aws_ecs_cluster.core.name}" >> /etc/ecs/ecs.config
    echo "ECS_ENABLE_SPOT_INSTANCE_DRAINING=true" >> /etc/ecs/ecs.config
  EOF
  )
}