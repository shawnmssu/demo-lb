Demo 演示步骤：
- 创建 ulb  绑定 eip，并创建报文转发模式的 listener
- 构建 packer 镜像，其中镜像中已配置网卡，安装了nginx（ 设置了开机自启）
- 使用 packer 创建的镜像创建云主机并挂载到 ulb 上，使用 nc 扫描 nginx 服务是否开启
