variable "region" {
  default = "us-west-2"
}

variable "alb_name" {
  default = "alb-name"
}

variable "certificate_arn" {
  default = "arn:aws:acm:us-west-2:593233425183:certificate/8b3686e2-84b8-4c16-b5dc-967fc017d09c"
}

variable "instance_tags" {
    type = "map"
    default = {
        "instance_name" = "Unicanova"
        "instance_env"  = "dev"
    }
}

variable "security_groups" {
  type    = "list"
  default = []
}

variable "vpcid" {
  default = ""
}

variable "http_map" {
  type = "map"
  default = {
    "name"               = "http-dev"
    "backend_protocol"   = "HTTP"
    "backend_port"       = "80"
    "stickiness_enabled" = false
  }
}

variable "socket_map" {
  type = "map"
  default = {
    "name"               = "socket-dev"
    "backend_protocol"   = "HTTP"
    "backend_port"       = "80"
  }
}
variable "http_redirect_map" {
  type = "map"
  default = {
    "name"               = "http-redirect-dev"
    "backend_protocol"   = "HTTP"
    "backend_port"       = "8080"
    "stickiness_enabled" = false
  }
}
