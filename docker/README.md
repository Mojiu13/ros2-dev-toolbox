# `docker/` 目录

> 状态：已实现。

`docker/` 负责 ROS2 开发镜像和容器的生命周期，以及 X11、GPU、网络、ROS2 discovery 和镜像迁移验证。

## 功能分组

### 镜像

- `validate_docker_files.sh`
- `build_ros_image.sh`
- `rebuild_ros_image.sh`
- `inspect_ros_image.sh`
- `remove_ros_image.sh`
- `export_ros_image.sh`
- `import_ros_image.sh`

### 容器生命周期

- `create_ros_container.sh`
- `start_ros_container.sh`
- `stop_ros_container.sh`
- `restart_ros_container.sh`
- `enter_ros_container.sh`
- `inspect_ros_container.sh`
- `show_container_logs.sh`
- `recreate_ros_container.sh`

### GUI、GPU 和网络

- `setup_x11_access.sh`
- `test_container_gui.sh`
- `test_container_gpu.sh`
- `test_container_network.sh`
- `test_ros2_discovery.sh`

## 参数覆盖

脚本优先读取统一配置，也支持命令行覆盖：

```text
DOCKER_IMAGE_REFERENCE
DOCKER_CONTAINER_NAME
HOST_WORKSPACE
CONTAINER_WORKSPACE
DOCKER_NETWORK_MODE
DOCKER_SHM_SIZE
ENABLE_GPU
ENABLE_GUI
```

创建容器示例：

```bash
bash docker/create_ros_container.sh \
  --container ros2_jazzy \
  --image ros2-jazzy-dev:latest \
  --host-workspace "$HOME/ros_ws" \
  --container-workspace /root/ros_ws \
  --network host \
  --gpu 1 \
  --gui 1
```

构建镜像并透传参数：

```bash
bash docker/build_ros_image.sh \
  --image ros2-jazzy-dev:latest \
  --dockerfile Dockerfile \
  --context . \
  -- --build-arg HTTP_PROXY=http://host.docker.internal:7897
```

验证容器：

```bash
bash docker/test_container_gui.sh --container ros2_jazzy
bash docker/test_container_gpu.sh --container ros2_jazzy
bash docker/test_container_network.sh --container ros2_jazzy
bash docker/test_ros2_discovery.sh --container ros2_jazzy --domain-id 0
```

## 安全边界

- 镜像删除和容器重建要求确认；
- 工作空间默认通过 bind mount 保存到宿主机；
- X11 授权应按用户精确开放，不使用无范围限制的长期授权；
- 导入镜像前应确认归档来源；
- Dockerfile 只决定镜像内容，GUI、GPU 和网络是否可用还取决于容器创建参数。
