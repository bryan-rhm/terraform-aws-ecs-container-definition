output "json_map_encoded" {
  description = "JSON string encoded container definitions for use with other terraform resources such as aws_ecs_task_definition"
  value       = local.json_map
}

