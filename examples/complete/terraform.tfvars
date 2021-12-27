region                       = "us-east-2"
container_name               = "test-name"
container_image              = "orion/awesomeapp:v1"
container_memory             = 512
container_memory_reservation = 256
container_cpu                = 10
container_environment = [
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