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
