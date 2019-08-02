output "instance_id_list" {
  value = ucloud_instance.web.*.id
}

output "lb_private_ip" {
  value = ucloud_lb.default.private_ip
}
