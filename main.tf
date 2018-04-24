provider "aws" {
  region = "${var.aws_region}"
}


data "aws_vpc" "default" {
  default = "${var.vpcid == "" ? true : false}"
  id      = "${var.vpcid}"
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_instances" "instance_data" {
  instance_tags {
    Name = "${lookup(var.instance_tags, "instance_name")}"
    Type = "${lookup(var.instance_tags, "instance_env")}"
  }
}

module "alb" {
  source                        = "terraform-aws-modules/alb/aws"
  load_balancer_name            = "my-alb"
  security_groups               = ["sg-0d295673"]
  log_bucket_name               = "alb-bucket"
  log_location_prefix           = "alb"
  subnets                       = ["${data.aws_subnet_ids.default.ids}"]
  tags                          = "${map("Environment", "test")}"
  vpc_id                        = "${data.aws_vpc.default.id}"
  https_listeners               = "${list(map("certificate_arn", var.certificate_arn, "port", 443, "target_group_index", 0))}"
  https_listeners_count         = "1"
  http_tcp_listeners            = "${list(map("port", "80", "protocol", "HTTP", "target_group_index", 1))}"
  http_tcp_listeners_count      = "1"
  target_groups                 = "${list(var.http_map,
                                          var.socket_map,
                                          var.http_redirect_map
                                   )}"
  target_groups_count           = "3"
}

resource "aws_lb_target_group_attachment" "tg_attach_http" {
  count            = "${length(data.aws_instances.instance_data.ids)}"
  target_group_arn = "${module.alb.target_group_arns[0]}"
  target_id        = "${data.aws_instances.instance_data.ids[count.index]}"
}

resource "aws_lb_target_group_attachment" "tg_attach_redirect" {
  count            = "${length(data.aws_instances.instance_data.ids)}"
  target_group_arn = "${module.alb.target_group_arns[1]}"
  target_id        = "${data.aws_instances.instance_data.ids[count.index]}"
}

resource "aws_lb_target_group_attachment" "tg_attach_socket" {
  count            = "${length(data.aws_instances.instance_data.ids)}"
  target_group_arn = "${module.alb.target_group_arns[2]}"
  target_id        = "${data.aws_instances.instance_data.ids[count.index]}"
}

resource "aws_lb_listener_rule" "socket" {
  listener_arn = "${module.alb.https_listener_arns[0]}"
  priority     = 5

  action {
    type             = "forward"
    target_group_arn = "${module.alb.target_group_arns[2]}"
  }

  condition {
    field  = "path-pattern"
    values = ["/socket.io/*"]
  }
}
