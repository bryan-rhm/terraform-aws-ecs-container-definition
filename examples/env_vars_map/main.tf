provider "aws" {
  region = "us-east-2"
}

module "ecs_container_definition" {
  source          = "../../"
  container_name  = "name"
  container_image = "orion/awesomeapp:v1"
  container_memory = 512

  map_environment = {
    "string_var"        = "I am a string"
    "true_boolean_var"  = true
    "false_boolean_var" = false
    "integer_var"       = 42
  }
}

output "json" {
  description = "Container definition in JSON format"
  value       = module.ecs_container_definition.json_map_encoded
}

resource "aws_ecs_task_definition" "task" {
  family                = "foo"
  container_definitions = "[${module.ecs_container_definition.json_map_encoded}]"
}