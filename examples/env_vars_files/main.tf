provider "aws" {
  region = "us-east-2"
}

module "ecs_container_definition" {
  source           = "../../"
  container_name   = "name"
  container_image  = "orion/awesomeapp:v1"
  container_memory = 512

  environment_files = [
    {
      value = "arn:aws:s3:::s3_bucket_name/envfile_01.env"
      type  = "s3"
    },
    {
      value = "arn:aws:s3:::s3_bucket_name/another_envfile.env"
      type  = "s3"
    }
  ]
}

output "json_map_encoded" {
  description = "Container definition in JSON format"
  value       = module.ecs_container_definition.json_map_encoded
}

resource "aws_ecs_task_definition" "task" {
  family                = "foo"
  container_definitions = "[${module.ecs_container_definition.json_map_encoded}]"
  execution_role_arn    = "arn:aws:iam::173279463787:role/ecsTaskExecutionRole"
}