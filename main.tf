locals {
  # Sort environment variables so terraform will not try to recreate on each plan/apply
  env_vars_keys        = var.map_environment != null ? keys(var.map_environment) : var.environment != null ? [for m in var.environment : lookup(m, "name")] : []
  env_vars_values      = var.map_environment != null ? values(var.map_environment) : var.environment != null ? [for m in var.environment : lookup(m, "value")] : []
  env_vars_as_map      = zipmap(local.env_vars_keys, local.env_vars_values)
  sorted_env_vars_keys = sort(local.env_vars_keys)

  sorted_environment_vars = [
    for key in local.sorted_env_vars_keys :
    {
      name  = key
      value = lookup(local.env_vars_as_map, key)
    }
  ]

  # Sort secrets so terraform will not try to recreate on each plan/apply
  secrets_keys        = var.map_secrets != null ? keys(var.map_secrets) : var.secrets != null ? [for m in var.secrets : lookup(m, "name")] : []
  secrets_values      = var.map_secrets != null ? values(var.map_secrets) : var.secrets != null ? [for m in var.secrets : lookup(m, "valueFrom")] : []
  secrets_as_map      = zipmap(local.secrets_keys, local.secrets_values)
  sorted_secrets_keys = sort(local.secrets_keys)

  sorted_secrets_vars = [
    for key in local.sorted_secrets_keys :
    {
      name      = key
      valueFrom = lookup(local.secrets_as_map, key)
    }
  ]

  mount_points = length(var.mount_points) > 0 ? [
    for mount_point in var.mount_points : {
      containerPath = lookup(mount_point, "containerPath")
      sourceVolume  = lookup(mount_point, "sourceVolume")
      readOnly      = tobool(lookup(mount_point, "readOnly", false))
    }
  ] : var.mount_points

  # https://www.terraform.io/docs/configuration/expressions.html#null
  final_environment_vars = length(local.sorted_environment_vars) > 0 ? local.sorted_environment_vars : null
  final_secrets_vars     = length(local.sorted_secrets_vars) > 0 ? local.sorted_secrets_vars : null

  log_configuration_secret_options = var.log_configuration != null ? lookup(var.log_configuration, "secretOptions", null) : null
  log_configuration_with_null = var.log_configuration == null ? null : {
    logDriver = tostring(lookup(var.log_configuration, "logDriver"))
    options   = tomap(lookup(var.log_configuration, "options"))
    secretOptions = local.log_configuration_secret_options == null ? null : [
      for secret_option in tolist(local.log_configuration_secret_options) : {
        name      = tostring(lookup(secret_option, "name"))
        valueFrom = tostring(lookup(secret_option, "valueFrom"))
      }
    ]
  }
  log_configuration_without_null = local.log_configuration_with_null == null ? null : {
    for k, v in local.log_configuration_with_null :
    k => v
    if v != null
  }
  user = var.firelens_configuration != null ? "0" : var.user

  container_definition = {
    cpu                    = var.container_cpu
    user                   = local.user
    name                   = var.container_name
    image                  = var.container_image
    memory                 = var.container_memory
    command                = var.command
    essential              = var.essential
    entryPoint             = var.entrypoint
    mountPoints            = local.mount_points
    dnsServers             = var.dns_servers
    dnsSearchDomains       = var.dns_search_domains
    ulimits                = var.ulimits
    links                  = var.links
    volumesFrom            = var.volumes_from
    dependsOn              = var.container_depends_on
    privileged             = var.privileged
    portMappings           = var.port_mappings
    healthCheck            = var.healthcheck
    memoryReservation      = var.container_memory_reservation
    environment            = local.final_environment_vars
    environmentFiles       = var.environment_files
    secrets                = local.final_secrets_vars
    dockerLabels           = var.docker_labels
    startTimeout           = var.start_timeout
    stopTimeout            = var.stop_timeout
    systemControls         = var.system_controls
    extraHosts             = var.extra_hosts
    hostname               = var.hostname
    interactive            = var.interactive
    linuxParameters        = var.linux_parameters
    workingDirectory       = var.working_directory
    logConfiguration       = local.log_configuration_without_null
    pseudoTerminal         = var.pseudo_terminal
    disableNetworking      = var.disable_networking
    resourceRequirements   = var.resource_requirements
    firelensConfiguration  = var.firelens_configuration
    repositoryCredentials  = var.repository_credentials
    dockerSecurityOptions  = var.docker_security_options
    readonlyRootFilesystem = var.readonly_root_filesystem
  }

  container_definition_without_null = {
    for k, v in local.container_definition :
    k => v
    if v != null
  }
  json_map = jsonencode(merge(local.container_definition_without_null, var.container_definition))
}