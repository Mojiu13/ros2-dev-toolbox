# config 目录

> 状态：模块 01 已实现。

## 目录定位

`config/` 集中管理工具箱运行时会变化的配置，避免把工作空间路径、Docker 镜像名、容器名、ROS2 发行版、代理地址、GUI 参数和日志目录写死在各业务脚本中。

本目录只保存配置入口和校验逻辑。本机配置默认生成到：

```text
~/.config/ros2-dev-toolbox/toolbox.env
```

该文件不应包含密码、Token、SSH 私钥或其他敏感信息。

## 已实现脚本

### `init_toolbox_config.sh`

负责首次生成本机配置：

- 写入 ROS2 发行版和 Domain ID；
- 区分宿主机与容器内工作空间路径；
- 写入 Docker 镜像名、标签、容器名、网络和共享内存配置；
- 写入 GPU、GUI、X11 和代理开关；
- 写入日志、归档和备份目录；
- 使用安全的 Shell 转义写入变量值；
- 默认禁止覆盖已有配置；
- 生成后自动调用配置校验器。

基本用法：

```bash
bash config/init_toolbox_config.sh
```

指定主要参数：

```bash
bash config/init_toolbox_config.sh \
  --ros-distro jazzy \
  --host-workspace "$HOME/ros_ws" \
  --container-workspace /root/ros_ws \
  --image-name ros2-jazzy-dev \
  --image-tag latest \
  --container-name ros2_jazzy
```

只有明确传入 `--force` 才会覆盖已有配置。

### `validate_toolbox_config.sh`

负责在其他工作流运行前校验配置：

- 检查配置文件语法和非法行；
- 检查变量是否重复定义；
- 检查必填变量是否存在；
- 检查路径是否使用绝对路径；
- 检查布尔值、ROS Domain ID、镜像名、标签和容器名格式；
- 检查代理配置是否自洽；
- 检查明显的密码、Token、密钥字段；
- 配置无效时返回稳定的非零退出码。

基本用法：

```bash
bash config/validate_toolbox_config.sh
```

校验指定文件：

```bash
bash config/validate_toolbox_config.sh --config /path/to/toolbox.env
```

## 主要配置变量

```text
ROS_DISTRO
ROS_DOMAIN_ID
ROS_LOCALHOST_ONLY
RMW_IMPLEMENTATION
HOST_WORKSPACE
CONTAINER_WORKSPACE
DOCKER_IMAGE_NAME
DOCKER_IMAGE_TAG
DOCKER_CONTAINER_NAME
DOCKER_NETWORK_MODE
DOCKER_SHM_SIZE
ENABLE_GPU
ENABLE_GUI
GUI_DISPLAY
X11_SOCKET
ENABLE_PROXY
HTTP_PROXY_URL
HTTPS_PROXY_URL
NO_PROXY_LIST
LOG_DIR
ARCHIVE_DIR
BACKUP_DIR
```

## 边界

- 不直接安装软件；
- 不保存秘密信息；
- 不实现 Docker、构建、启动或诊断流程；
- 其他目录应通过 `lib/load_toolbox_config.sh` 读取配置，而不是直接重复解析配置文件。
