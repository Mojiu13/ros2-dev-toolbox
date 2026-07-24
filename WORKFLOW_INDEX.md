# ROS2 Dev Toolbox 完整工作流目录

> 状态：模块 01–19 的规划脚本已全部实现；模块 20 是完整工作流顺序，不对应单独脚本目录。
>
> 本文件只提供脚本索引和简略任务名称。每个脚本的具体职责、输入输出与边界，请查看所属目录的 `README.md`。
>
> 安全约定：清理、删除、格式化、依赖恢复等高影响操作默认预览或要求确认；路径、镜像、容器、包、节点、Topic、Action 和 Controller 等关键参数均可通过配置或命令行覆盖。

## 01. 全局配置与公共能力（已实现）

- `config/init_toolbox_config.sh` — 初始化工具箱配置
- `config/validate_toolbox_config.sh` — 校验工具箱配置
- `lib/load_toolbox_config.sh` — 加载并导出工具箱配置
- `lib/common.sh` — 提供通用基础函数
- `lib/logging.sh` — 提供统一日志输出
- `lib/error_handling.sh` — 提供统一异常与清理处理

## 02. 宿主机环境准备（已实现）

- `setup/check_host_system.sh` — 检查宿主机系统条件
- `setup/install_host_dependencies.sh` — 安装宿主机基础依赖
- `setup/setup_docker.sh` — 安装并配置 Docker
- `setup/check_nvidia_environment.sh` — 检查 NVIDIA 驱动环境
- `setup/setup_nvidia_container_toolkit.sh` — 配置 NVIDIA 容器支持
- `setup/check_proxy.sh` — 检查代理与网络配置

## 03. Docker 镜像管理（已实现）

- `docker/validate_docker_files.sh` — 校验 Docker 构建文件
- `docker/build_ros_image.sh` — 构建 ROS2 开发镜像
- `docker/rebuild_ros_image.sh` — 无缓存重建 ROS2 镜像
- `docker/inspect_ros_image.sh` — 检查 ROS2 镜像内容
- `docker/remove_ros_image.sh` — 删除指定 ROS2 镜像

## 04. Docker 容器生命周期（已实现）

- `docker/create_ros_container.sh` — 创建 ROS2 开发容器
- `docker/start_ros_container.sh` — 启动 ROS2 开发容器
- `docker/stop_ros_container.sh` — 停止 ROS2 开发容器
- `docker/restart_ros_container.sh` — 重启 ROS2 开发容器
- `docker/enter_ros_container.sh` — 进入 ROS2 容器终端
- `docker/inspect_ros_container.sh` — 检查 ROS2 容器状态
- `docker/show_container_logs.sh` — 查看 ROS2 容器日志
- `docker/recreate_ros_container.sh` — 删除并重建 ROS2 容器

## 05. GUI、GPU 与网络验证（已实现）

- `docker/setup_x11_access.sh` — 配置容器 X11 访问
- `docker/test_container_gui.sh` — 测试容器 GUI 显示
- `docker/test_container_gpu.sh` — 测试容器 GPU 访问
- `docker/test_container_network.sh` — 测试容器网络连接
- `docker/test_ros2_discovery.sh` — 测试 ROS2 节点发现

## 06. ROS2 工作空间初始化（已实现）

- `workspace/create_ros_workspace.sh` — 创建 ROS2 工作空间
- `workspace/check_workspace_structure.sh` — 检查工作空间结构
- `workspace/init_rosdep.sh` — 初始化 rosdep
- `workspace/install_workspace_dependencies.sh` — 安装工作空间依赖
- `workspace/import_workspace_repositories.sh` — 批量导入源码仓库

## 07. ROS2 工作空间构建（已实现）

- `workspace/build_workspace.sh` — 完整构建工作空间
- `workspace/build_package.sh` — 构建指定 ROS2 包
- `workspace/build_up_to_package.sh` — 构建至指定 ROS2 包
- `workspace/clean_package.sh` — 清理指定包构建结果
- `workspace/clean_workspace.sh` — 清理整个工作空间
- `workspace/rebuild_workspace.sh` — 清理并重建工作空间
- `workspace/inspect_build_failure.sh` — 分析最近构建失败

## 08. 环境加载与开发终端（已实现）

- `workspace/source_ros_environment.sh` — 加载 ROS2 基础环境
- `workspace/source_workspace.sh` — 加载工作空间环境
- `workspace/inspect_overlay_environment.sh` — 检查 Overlay 加载顺序
- `workspace/open_ros_terminal.sh` — 打开已配置开发终端

## 09. ROS2 工程模板（已实现）

- `templates/create_python_package.sh` — 创建 Python ROS2 包
- `templates/create_cpp_package.sh` — 创建 C++ ROS2 包
- `templates/validate_ros_package.sh` — 校验 ROS2 包结构
- `templates/create_launch_template.sh` — 创建 Launch 文件模板
- `templates/create_parameter_template.sh` — 创建参数 YAML 模板
- `templates/create_script_template.sh` — 创建标准 Shell 脚本模板

## 10. ROS2 系统启动（已实现）

- `launch/run_ros_node.sh` — 启动指定 ROS2 节点
- `launch/run_ros_launch.sh` — 启动指定 Launch 文件
- `launch/launch_robot_description.sh` — 启动机器人模型与 TF
- `launch/start_rviz.sh` — 启动 RViz
- `launch/start_robot_stack.sh` — 启动完整机械臂系统
- `launch/stop_robot_stack.sh` — 停止完整机械臂系统
- `launch/run_robot_task.sh` — 执行预设机械臂任务
- `launch/run_pick_place_task.sh` — 执行抓取放置任务
- `launch/cancel_robot_task.sh` — 取消正在执行的任务
- `launch/safe_stop_robot.sh` — 安全停止机器人系统

## 11. ROS2 系统观察（已实现）

- `inspect/inspect_nodes.sh` — 查看 ROS2 节点
- `inspect/inspect_topics.sh` — 查看 ROS2 Topic
- `inspect/inspect_services.sh` — 查看 ROS2 Service
- `inspect/inspect_actions.sh` — 查看 ROS2 Action
- `inspect/inspect_parameters.sh` — 查看 ROS2 Parameter
- `inspect/show_ros_graph.sh` — 显示 ROS2 通信图
- `inspect/measure_topic_rate.sh` — 测量 Topic 发布频率
- `inspect/validate_robot_description.sh` — 校验 URDF 与 Xacro
- `inspect/inspect_tf_tree.sh` — 查看 TF 树
- `inspect/check_tf_transform.sh` — 查询 Frame 变换

## 12. ros2_control 工作流（已实现）

- `ros2_control/launch_ros2_control.sh` — 启动 ros2_control 系统
- `ros2_control/inspect_controllers.sh` — 查看 Controller 状态
- `ros2_control/load_controller.sh` — 加载指定 Controller
- `ros2_control/activate_controller.sh` — 激活指定 Controller
- `ros2_control/deactivate_controller.sh` — 停用指定 Controller
- `ros2_control/switch_controllers.sh` — 切换运行中的 Controller
- `ros2_control/inspect_hardware_interfaces.sh` — 查看硬件接口状态
- `ros2_control/send_joint_trajectory.sh` — 直接发送关节轨迹
- `ros2_control/check_joint_name_consistency.sh` — 检查关节名称一致性

## 13. MoveIt2 工作流（已实现）

- `moveit/check_moveit_environment.sh` — 检查 MoveIt2 环境
- `moveit/start_moveit_demo.sh` — 启动 MoveIt2 演示系统
- `moveit/inspect_moveit_system.sh` — 查看 MoveIt2 系统状态
- `moveit/check_moveit_controllers.sh` — 检查 MoveIt Controller 映射
- `moveit/test_moveit_planning.sh` — 测试 MoveIt 轨迹规划
- `moveit/test_moveit_execution.sh` — 测试 MoveIt 规划与执行
- `moveit/inspect_moveit_trajectory.sh` — 查看 MoveIt 规划轨迹
- `moveit/inspect_planning_scene.sh` — 查看 MoveIt Planning Scene

## 14. 健康检查与启动前检查（已实现）

- `diagnostics/check_ros2_health.sh` — 检查 ROS2 基础健康状态
- `diagnostics/check_workspace_health.sh` — 检查工作空间健康状态
- `diagnostics/check_robot_stack_health.sh` — 检查机械臂系统健康状态
- `diagnostics/preflight_check.sh` — 执行系统启动前检查
- `diagnostics/task_preflight_check.sh` — 执行任务开始前检查

## 15. 故障诊断与恢复（已实现）

- `diagnostics/collect_system_diagnostics.sh` — 收集宿主机与容器诊断信息
- `diagnostics/collect_ros_diagnostics.sh` — 收集 ROS2 通信诊断信息
- `diagnostics/collect_robot_diagnostics.sh` — 收集机械臂系统诊断信息
- `diagnostics/find_stale_ros_processes.sh` — 查找残留 ROS2 进程
- `diagnostics/cleanup_ros_processes.sh` — 清理残留 ROS2 进程
- `diagnostics/reset_ros_daemon.sh` — 重置 ROS2 Daemon
- `diagnostics/inspect_network_usage.sh` — 检查网络与端口占用
- `diagnostics/generate_failure_report.sh` — 生成结构化故障报告

## 16. 实验记录与日志归档（已实现）

- `docs/create_run_record.sh` — 创建实验运行记录
- `docs/record_git_state.sh` — 记录当前 Git 状态
- `docs/snapshot_ros_system.sh` — 保存 ROS2 系统快照
- `docs/archive_run_logs.sh` — 归档运行与构建日志

## 17. 清理、磁盘与 Docker 维护（已实现）

- `diagnostics/clean_ros_logs.sh` — 清理过期 ROS2 日志
- `diagnostics/clean_docker_cache.sh` — 清理 Docker 构建缓存
- `diagnostics/prune_docker_resources.sh` — 清理未使用 Docker 资源
- `diagnostics/check_disk_usage.sh` — 检查磁盘空间占用

## 18. 备份、同步与恢复（已实现）

- `workspace/backup_workspace_source.sh` — 备份工作空间源码
- `docker/export_ros_image.sh` — 导出 ROS2 Docker 镜像
- `docker/import_ros_image.sh` — 导入 ROS2 Docker 镜像
- `setup/export_dependency_manifest.sh` — 导出开发环境依赖清单
- `setup/restore_development_environment.sh` — 恢复完整开发环境

## 19. 工具箱仓库维护（已实现）

- `setup/init_toolbox_repository.sh` — 初始化工具箱 Git 仓库
- `diagnostics/lint_shell_scripts.sh` — 检查 Shell 脚本质量
- `diagnostics/format_shell_scripts.sh` — 格式化 Shell 脚本
- `diagnostics/check_secrets.sh` — 检查敏感信息泄露
- `docs/generate_script_index.sh` — 生成脚本索引文档
- `diagnostics/validate_toolbox.sh` — 检查工具箱完整性

## 20. 完整主流程

1. 宿主机环境准备
2. Docker 与 NVIDIA 环境准备
3. ROS2 镜像构建
4. ROS2 容器创建与验证
5. ROS2 工作空间初始化
6. 依赖安装与源码导入
7. 工作空间构建与环境加载
8. 机器人模型、TF 与 RViz 启动
9. ros2_control 与 Controller 启动
10. MoveIt2 启动与规划测试
11. 机械臂任务执行
12. 运行状态验证
13. 实验记录与日志归档
14. 系统安全停止
15. 残留进程与缓存清理
