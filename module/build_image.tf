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
