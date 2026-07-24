# `setup/` 目录

> 状态：已实现。

`setup/` 负责从 Ubuntu 宿主机基线开始，检查并准备 Docker、NVIDIA 容器支持、网络代理和依赖恢复条件。它不负责 ROS2 工作空间构建或机器人任务执行。

## 已实现脚本

| 脚本 | 任务 |
|---|---|
| `check_host_system.sh` | 输出系统、内核、架构、CPU、内存、磁盘和基础命令状态 |
| `install_host_dependencies.sh` | 参数化安装宿主机基础工具；默认只预览 |
| `setup_docker.sh` | 检查 Docker 和 daemon，可选启动服务 |
| `check_nvidia_environment.sh` | 检查 GPU、驱动、内核模块和设备节点 |
| `setup_nvidia_container_toolkit.sh` | 配置 NVIDIA 容器 runtime；默认只预览 |
| `check_proxy.sh` | 查看代理环境并测试多个 URL |
| `export_dependency_manifest.sh` | 导出 apt、pip、ROS2、VCS 和 Docker 依赖清单 |
| `restore_development_environment.sh` | 按 apt、pip、repos、build 阶段恢复环境；默认只预览 |
| `init_toolbox_repository.sh` | 初始化新的工具箱仓库目录骨架 |

## 常用示例

```bash
bash setup/check_host_system.sh
bash setup/check_nvidia_environment.sh --json
bash setup/check_proxy.sh --clear-defaults --url https://github.com
```

预览宿主机依赖安装：

```bash
bash setup/install_host_dependencies.sh
```

明确执行：

```bash
bash setup/install_host_dependencies.sh --execute --yes
```

导出环境清单：

```bash
bash setup/export_dependency_manifest.sh \
  --workspace "$HOME/ros_ws" \
  --output "$HOME/backups/ros2-manifest"
```

分阶段恢复：

```bash
bash setup/restore_development_environment.sh \
  --manifest "$HOME/backups/ros2-manifest" \
  --stage repos

bash setup/restore_development_environment.sh \
  --manifest "$HOME/backups/ros2-manifest" \
  --stage repos --execute --yes
```

## 安全边界

- 安装和恢复操作默认不执行，必须显式使用 `--execute`；
- 恢复环境建议分阶段运行，不建议直接从未知清单执行 `--stage all`；
- 本目录不保存密码、Token、私钥或账户凭据；
- Docker 官方软件源安装方式仍应依据目标 Ubuntu 版本人工确认。
