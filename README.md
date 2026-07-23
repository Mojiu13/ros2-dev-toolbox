# ROS2 Dev Toolbox

用于集中管理 ROS 2、Docker、MoveIt 2 和 ros2_control 开发过程中频繁使用的操作脚本。

本仓库的目标不是存放 ROS 2 功能包源码，而是把重复执行、容易输错、需要经常调整的命令封装为可复用脚本。

## 目录结构

```text
ros2-dev-toolbox/
├── setup/          # 宿主机与 ROS 2 基础环境准备
├── docker/         # 镜像构建、容器启动、进入容器和 GUI 配置
├── workspace/      # colcon 构建、清理、source 和依赖安装
├── launch/         # 启动 ROS 2、RViz、仿真和演示系统的入口脚本
├── inspect/        # 查看 node、topic、service、action、parameter 和 TF
├── diagnostics/    # 环境检查、故障定位和诊断信息收集
├── moveit/         # MoveIt 2 启动、规划执行和配置检查脚本
├── ros2_control/   # controller 与 hardware interface 检查脚本
├── lib/            # 多个脚本共享的 Shell 函数
├── config/         # 脚本读取的默认配置和环境变量示例
├── docs/           # 使用说明、脚本规范和故障记录
└── templates/      # 新脚本与新环境配置模板
```

## 使用原则

1. 一个脚本只承担一个清楚的任务。
2. 默认采用 Bash，并使用 `#!/usr/bin/env bash`。
3. 新脚本建议启用：

   ```bash
   set -Eeuo pipefail
   ```

4. 会修改系统、删除文件或停止进程的脚本，必须明确提示风险。
5. 路径、容器名和 ROS 发行版等可变信息放入 `config/`，避免散落在脚本中。
6. 通用日志、错误处理和环境检查函数放入 `lib/`。
7. 不提交密码、Token、SSH 私钥或其他敏感信息。

## 脚本命名建议

```text
动词_对象.sh
```

例如：

```text
build_workspace.sh
clean_workspace.sh
start_ros_container.sh
enter_ros_container.sh
check_controllers.sh
collect_ros_diagnostics.sh
```

## 当前状态

仓库骨架已建立，后续按实际学习和开发需求逐步加入脚本。
