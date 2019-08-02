module "cn-bj2" {
  source = "./module"
  region = "cn-bj2"
  zone   = "cn-bj2-02"
  instance_count = 2
  instance_password = "ucloud_2019"
}
