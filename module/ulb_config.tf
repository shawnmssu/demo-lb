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

# Query image
data "ucloud_images" "source" {
  availability_zone = var.zone
  name_regex        = "^CentOS 7.[1-2] 64"
  image_type        = "base"
}

resource "null_resource" "build_image" {
  triggers = {
    ulb_id = ucloud_lb.default.id
  }

  provisioner "local-exec" {
    command = <<EOF
        packer build \
          -var 'lb_public_ip=${ucloud_eip.default.public_ip}' \
          -var 'password=${var.instance_password}'\
          -var 'region=${var.region}'\
          -var 'zone=${var.zone}'\
          -var 'image_name=${var.image_name}'\
          -var 'source_image_id=${data.ucloud_images.source.images[0].id}'\
          ${path.module}/packer/ulb_config.json
    EOF
  }
}

# Query image
data "ucloud_images" "default" {
  depends_on        = [null_resource.build_image]
  availability_zone = var.zone
  name_regex        = "^lb-packets-transmit-test"
  image_type        = "custom"
//  most_recent       = true
}

# Create web servers
resource "ucloud_instance" "web" {
  availability_zone = var.zone
  instance_type     = "n-basic-2"
  image_id          = data.ucloud_images.default.images[0].id
  root_password     = var.instance_password

  name  = "tf-example-lb-${format(var.count_format, count.index + 1)}"
  tag   = "tf-example"
  count = var.instance_count
}

# Attach instances to Load Balancer
resource "ucloud_lb_attachment" "default" {
  load_balancer_id = ucloud_lb.default.id
  listener_id      = ucloud_lb_listener.default.id
  resource_id      = ucloud_instance.web[count.index].id
  port             = 80
  count            = var.instance_count
}

resource "null_resource" "nginx" {
  triggers = {
    ulb_attachment_ids = "${join(",", ucloud_lb_attachment.default.*.id)}"
  }

  provisioner "local-exec" {
    command = "nc -vz ${ucloud_eip.default.public_ip} 80"
  }
}
