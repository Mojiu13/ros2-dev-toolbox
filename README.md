# ROS2 Dev Toolbox

用于集中管理 ROS2、Docker、MoveIt2 和 ros2_control 开发过程中频繁使用的操作脚本。

本仓库不存放具体机器人功能包源码，而是把重复执行、容易输错、需要经常调整的命令封装成可复用、可配置的工作流入口。

## 当前状态

`WORKFLOW_INDEX.md` 中模块 01–19 的规划脚本已经全部创建，覆盖：

```text
宿主机检查
→ Docker 镜像与容器
→ GUI / GPU / 网络验证
→ ROS2 工作空间初始化与构建
→ ROS2 工程模板
→ 节点、Launch、RViz 与机器人任务
→ ROS2 图、接口、URDF 与 TF 观察
→ ros2_control
→ MoveIt2
→ 健康检查与故障诊断
→ 实验记录与日志归档
→ 清理、备份、恢复与仓库维护
```

完整脚本目录与中文任务名称见 [`WORKFLOW_INDEX.md`](WORKFLOW_INDEX.md)。

## 目录结构

```text
ros2-dev-toolbox/
├── config/         # 本机配置生成与校验
├── lib/            # 日志、错误处理、配置加载与公共函数
├── setup/          # 宿主机、Docker、NVIDIA、依赖清单与恢复
├── docker/         # 镜像、容器、X11、GPU、网络与镜像迁移
├── workspace/      # 工作空间初始化、依赖、构建、清理与备份
├── templates/      # Python/C++ 包、Launch、YAML 和 Shell 模板
├── launch/         # 节点、Launch、RViz、机器人栈与任务入口
├── inspect/        # node、topic、service、action、parameter、URDF、TF
├── ros2_control/   # Controller、硬件接口和关节轨迹
├── moveit/         # MoveIt2 环境、Demo、规划、执行和 Planning Scene
├── diagnostics/    # 健康检查、诊断、清理、质量检查与完整性验证
└── docs/           # 实验记录、系统快照、日志归档和脚本索引
```

## 快速开始

克隆并进入仓库：

```bash
git clone git@github.com:Mojiu13/ros2-dev-toolbox.git
cd ros2-dev-toolbox
```

创建本机配置：

```bash
bash config/init_toolbox_config.sh
```

校验配置：

```bash
bash config/validate_toolbox_config.sh
```

加载配置：

```bash
source lib/load_toolbox_config.sh
```

检查全部脚本语法、索引覆盖和本机配置：

```bash
bash diagnostics/validate_toolbox.sh
```

GitHub Contents API 创建的脚本可能没有可执行位。需要直接 `./script.sh` 调用时，在本地执行：

```bash
bash diagnostics/validate_toolbox.sh --fix-permissions --yes
```

也可以始终使用：

```bash
bash path/to/script.sh
```

## 参数设计

脚本优先读取统一配置，同时允许命令行覆盖。常见可配置对象包括：

```text
ROS_DISTRO
ROS_DOMAIN_ID
HOST_WORKSPACE
CONTAINER_WORKSPACE
DOCKER_IMAGE_REFERENCE
DOCKER_CONTAINER_NAME
CONTROLLER_MANAGER
MOVE_GROUP_NODE
JOINT_STATES_TOPIC
```

大多数构建、启动和运行入口允许使用 `--` 将后续参数原样传给 `docker`、`colcon`、`ros2 launch` 或 ROS2 节点。

## 安全约定

- 清理、删除、格式化和恢复环境等高影响操作默认只预览或要求确认；
- 进程清理要求显式提供 PID，不使用模糊匹配批量终止；
- 日志归档不自动删除原始文件；
- 本机配置不应保存密码、Token、SSH 私钥或其他秘密；
- `diagnostics/check_secrets.sh` 可在提交前执行基础敏感信息检查；
- `launch/safe_stop_robot.sh` 只是软件层停止助手，不能替代真实机器人的硬件急停与安全系统。

## 验证边界

脚本已经按通用参数化原则生成，并提供仓库级语法与覆盖检查入口。但 ROS2 CLI、ros2_control、MoveIt2、Docker、GPU 和真实机械臂相关命令仍需在目标 Ubuntu / ROS2 Jazzy 环境中逐模块验证。
