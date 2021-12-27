provider "aws" {
  region = "us-east-2"
}

module "ecs_container_definition_first" {
  source           = "../../"
  container_name   = "name"
  container_image  = "orion/awesomeapp:v1"
  container_memory = 512

  port_mappings = [
    {
      containerPort = 8080
      hostPort      = 80
      protocol      = "tcp"
    },
    {
      containerPort = 8081
      hostPort      = 443
      protocol      = "udp"
    }
  ]
}

module "ecs_container_definition_second" {
  source           = "../../"
  container_name   = "name2"
  container_image  = "orion/awesomeapp:v1"
  container_memory = 256

  port_mappings = [
    {
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
    },
    {
      containerPort = 8081
      hostPort      = 444
      protocol      = "udp"
    }
  ]
}

output "first_container_json" {
  description = "Container definition in JSON format"
  value       = module.ecs_container_definition_first.json_map_encoded
}

output "second_container_json" {
  description = "Container definition in JSON format"
  value       = module.ecs_container_definition_second.json_map_encoded
}

resource "aws_ecs_task_definition" "task" {
  family = "foo"
  container_definitions = "[${module.ecs_container_definition_first.json_map_encoded}, ${module.ecs_container_definition_second.json_map_encoded}]"
}