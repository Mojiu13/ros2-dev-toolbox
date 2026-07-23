# setup 目录规划

> 状态：规划阶段。当前仅记录职责，不包含脚本实现。

## 目录定位

`setup/` 负责从一台新的 Ubuntu 主机开始，建立能够运行本工具箱的基础开发条件。它覆盖宿主机检查、基础工具、Docker、NVIDIA 容器支持、代理、依赖清单和环境恢复，不负责具体 ROS2 工程构建与机器人任务运行。

## 计划脚本

### `check_host_system.sh`

负责确认宿主机是否满足基础要求：

- 识别 Ubuntu 版本、内核版本和系统架构；
- 检查 CPU、内存、磁盘和文件系统空间；
- 检查当前用户、用户组和 sudo 能力；
- 检查 Git、curl、wget、Bash 等基础命令；
- 检查时间、时区、DNS 和软件源基本状态；
- 输出环境摘要和不满足项；
- 只检查，不擅自修改系统。

### `install_host_dependencies.sh`

负责安装工具箱在宿主机侧需要的基础软件：

- 安装下载、压缩、版本控制和网络诊断工具；
- 安装 Docker 安装过程需要的依赖；
- 安装 X11、权限和进程观察相关工具；
- 检查已安装版本，避免无意义重复安装；
- 记录实际安装和跳过的软件；
- 软件源不可用时明确报告失败位置。

### `setup_docker.sh`

负责建立宿主机 Docker 环境：

- 检查 Docker Engine、CLI 和 Compose 能力；
- 在缺失时执行安装流程；
- 检查并启动 Docker 服务；
- 配置当前用户的 Docker 使用权限；
- 检查 daemon 配置文件；
- 运行最小容器验证；
- 区分“未安装”“服务未启动”“权限不足”和“daemon 配置错误”。

### `check_nvidia_environment.sh`

负责确认宿主机 NVIDIA 环境：

- 检查显卡是否被系统识别；
- 检查驱动版本和 `nvidia-smi`；
- 检查 NVIDIA 内核模块；
- 检查 `/dev/nvidia*` 设备节点；
- 检查 Secure Boot、内核升级或 DKMS 造成的常见异常；
- 判断问题属于硬件识别、驱动、内核模块还是用户空间工具；
- 输出是否具备向容器暴露 GPU 的前提。

### `setup_nvidia_container_toolkit.sh`

负责建立 GPU 容器运行条件：

- 检查 NVIDIA Container Toolkit 是否安装；
- 配置 Docker 的 NVIDIA runtime；
- 检查 daemon 配置变化；
- 重启 Docker 服务并验证状态；
- 运行最小 GPU 容器测试；
- 将宿主机驱动故障与容器 runtime 故障分开报告。

### `check_proxy.sh`

负责检查开发环境可能使用的代理：

- 检查 HTTP、HTTPS、ALL_PROXY 和 NO_PROXY；
- 检查本地代理端口是否监听；
- 测试宿主机直连与代理连接；
- 判断 Docker 构建、Docker daemon 和容器内是否需要分别配置代理；
- 检查 localhost、宿主机地址和容器地址混用问题；
- 只输出建议，不在未确认时修改全局代理。

### `export_dependency_manifest.sh`

负责导出环境依赖清单：

- 记录 Ubuntu、内核和架构；
- 记录 Docker 与 NVIDIA 组件版本；
- 记录 apt 软件包和 Python 依赖；
- 记录 ROS2 发行版和相关二进制包；
- 记录源码仓库版本信息；
- 生成可用于审计和重建环境的清单；
- 不导出密码、Token 和私有凭据。

### `restore_development_environment.sh`

负责根据已保存的配置和依赖清单恢复开发环境：

- 检查目标主机是否兼容；
- 恢复基础工具、Docker 和 NVIDIA 容器支持；
- 恢复配置文件和目录结构；
- 调用镜像构建、源码恢复、依赖安装和工作空间构建流程；
- 每个阶段独立验证，失败时停止后续步骤；
- 不把“命令执行完成”误判为“环境已可用”。

### `init_toolbox_repository.sh`

负责在需要时初始化工具箱仓库骨架：

- 创建约定目录；
- 创建 README、LICENSE、`.gitignore` 和配置示例；
- 检查目标目录是否已有 Git 仓库；
- 避免覆盖已有文件；
- 仅用于仓库初始化，不负责实现业务脚本。

## 推荐执行顺序

1. `check_host_system.sh`
2. `install_host_dependencies.sh`
3. `setup_docker.sh`
4. `check_nvidia_environment.sh`
5. `setup_nvidia_container_toolkit.sh`
6. `check_proxy.sh`
7. 进入 `docker/` 的镜像与容器工作流

## 边界

- 不负责 ROS2 工作空间的日常构建；
- 不负责启动 RViz、MoveIt2 或 controller；
- 不在未确认时升级内核、卸载驱动或大范围修改软件源；
- 恢复流程应调用其他目录已有能力，而不是复制同一套实现。
