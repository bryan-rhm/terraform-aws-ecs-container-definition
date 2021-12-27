provider "aws" {
  region = "us-east-2"
}

module "ecs_container_definition" {
  source           = "../../"
  container_name   = "name"
  container_image  = "orion/awesomeapp:v1"
  container_memory = 512

  environment = [
    {
      name  = "string_var"
      value = "I am a string"
    },
    {
      name  = "true_boolean_var"
      value = true
    },
    {
      name  = "false_boolean_var"
      value = false
    },
    {
      name  = "integer_var"
      value = 42
    }
  ]
}

output "json" {
  description = "Container definition in JSON format"
  value       = module.ecs_container_definition.json_map_encoded
}

resource "aws_ecs_task_definition" "task" {
  family                = "foo"
  container_definitions = "[${module.ecs_container_definition.json_map_encoded}]"
}