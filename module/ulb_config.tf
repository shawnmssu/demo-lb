# Specify the provider and access details
provider "ucloud" {
  region = var.region
}

# Create Load Balancer
resource "ucloud_lb" "default" {
  name = "tf-example-lb"
  tag  = "tf-example"
}

resource "ucloud_eip" "default" {
  internet_type = "bgp"
  charge_mode   = "traffic"
  bandwidth     = 20
}

resource "ucloud_eip_association" "default" {
  eip_id      = ucloud_eip.default.id
  resource_id = ucloud_lb.default.id
}

resource "ucloud_lb_listener" "default" {
  name             = "tf-example-lb"
  listen_type      = "packets_transmit"
  load_balancer_id = ucloud_lb.default.id
  protocol         = "tcp"
  port             = 80
}

