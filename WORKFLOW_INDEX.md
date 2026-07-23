# ROS2 Dev Toolbox 完整工作流目录

> 状态：规划阶段。当前仅建立工作流目录与职责文档，尚未实现任何脚本。

## 01. 全局配置与公共能力

- `config/init_toolbox_config.sh`
- `config/validate_toolbox_config.sh`
- `lib/load_toolbox_config.sh`
- `lib/common.sh`
- `lib/logging.sh`
- `lib/error_handling.sh`

## 02. 宿主机环境准备

- `setup/check_host_system.sh`
- `setup/install_host_dependencies.sh`
- `setup/setup_docker.sh`
- `setup/check_nvidia_environment.sh`
- `setup/setup_nvidia_container_toolkit.sh`
- `setup/check_proxy.sh`

## 03. Docker 镜像管理

- `docker/validate_docker_files.sh`
- `docker/build_ros_image.sh`
- `docker/rebuild_ros_image.sh`
- `docker/inspect_ros_image.sh`
- `docker/remove_ros_image.sh`

## 04. Docker 容器生命周期

- `docker/create_ros_container.sh`
- `docker/start_ros_container.sh`
- `docker/stop_ros_container.sh`
- `docker/restart_ros_container.sh`
- `docker/enter_ros_container.sh`
- `docker/inspect_ros_container.sh`
- `docker/show_container_logs.sh`
- `docker/recreate_ros_container.sh`

## 05. GUI、GPU 与网络验证

- `docker/setup_x11_access.sh`
- `docker/test_container_gui.sh`
- `docker/test_container_gpu.sh`
- `docker/test_container_network.sh`
- `docker/test_ros2_discovery.sh`

## 06. ROS2 工作空间初始化

- `workspace/create_ros_workspace.sh`
- `workspace/check_workspace_structure.sh`
- `workspace/init_rosdep.sh`
- `workspace/install_workspace_dependencies.sh`
- `workspace/import_workspace_repositories.sh`

## 07. ROS2 工作空间构建

- `workspace/build_workspace.sh`
- `workspace/build_package.sh`
- `workspace/build_up_to_package.sh`
- `workspace/clean_package.sh`
- `workspace/clean_workspace.sh`
- `workspace/rebuild_workspace.sh`
- `workspace/inspect_build_failure.sh`

## 08. 环境加载与开发终端

- `workspace/source_ros_environment.sh`
- `workspace/source_workspace.sh`
- `workspace/inspect_overlay_environment.sh`
- `workspace/open_ros_terminal.sh`

## 09. ROS2 工程模板

- `templates/create_python_package.sh`
- `templates/create_cpp_package.sh`
- `templates/validate_ros_package.sh`
- `templates/create_launch_template.sh`
- `templates/create_parameter_template.sh`
- `templates/create_script_template.sh`

## 10. ROS2 系统启动

- `launch/run_ros_node.sh`
- `launch/run_ros_launch.sh`
- `launch/launch_robot_description.sh`
- `launch/start_rviz.sh`
- `launch/start_robot_stack.sh`
- `launch/stop_robot_stack.sh`
- `launch/run_robot_task.sh`
- `launch/run_pick_place_task.sh`
- `launch/cancel_robot_task.sh`
- `launch/safe_stop_robot.sh`

## 11. ROS2 系统观察

- `inspect/inspect_nodes.sh`
- `inspect/inspect_topics.sh`
- `inspect/inspect_services.sh`
- `inspect/inspect_actions.sh`
- `inspect/inspect_parameters.sh`
- `inspect/show_ros_graph.sh`
- `inspect/measure_topic_rate.sh`
- `inspect/validate_robot_description.sh`
- `inspect/inspect_tf_tree.sh`
- `inspect/check_tf_transform.sh`

## 12. ros2_control 工作流

- `ros2_control/launch_ros2_control.sh`
- `ros2_control/inspect_controllers.sh`
- `ros2_control/load_controller.sh`
- `ros2_control/activate_controller.sh`
- `ros2_control/deactivate_controller.sh`
- `ros2_control/switch_controllers.sh`
- `ros2_control/inspect_hardware_interfaces.sh`
- `ros2_control/send_joint_trajectory.sh`
- `ros2_control/check_joint_name_consistency.sh`

## 13. MoveIt2 工作流

- `moveit/check_moveit_environment.sh`
- `moveit/start_moveit_demo.sh`
- `moveit/inspect_moveit_system.sh`
- `moveit/check_moveit_controllers.sh`
- `moveit/test_moveit_planning.sh`
- `moveit/test_moveit_execution.sh`
- `moveit/inspect_moveit_trajectory.sh`
- `moveit/inspect_planning_scene.sh`

## 14. 健康检查与启动前检查

- `diagnostics/check_ros2_health.sh`
- `diagnostics/check_workspace_health.sh`
- `diagnostics/check_robot_stack_health.sh`
- `diagnostics/preflight_check.sh`
- `diagnostics/task_preflight_check.sh`

## 15. 故障诊断与恢复

- `diagnostics/collect_system_diagnostics.sh`
- `diagnostics/collect_ros_diagnostics.sh`
- `diagnostics/collect_robot_diagnostics.sh`
- `diagnostics/find_stale_ros_processes.sh`
- `diagnostics/cleanup_ros_processes.sh`
- `diagnostics/reset_ros_daemon.sh`
- `diagnostics/inspect_network_usage.sh`
- `diagnostics/generate_failure_report.sh`

## 16. 实验记录与日志归档

- `docs/create_run_record.sh`
- `docs/record_git_state.sh`
- `docs/snapshot_ros_system.sh`
- `docs/archive_run_logs.sh`

## 17. 清理、磁盘与 Docker 维护

- `diagnostics/clean_ros_logs.sh`
- `diagnostics/clean_docker_cache.sh`
- `diagnostics/prune_docker_resources.sh`
- `diagnostics/check_disk_usage.sh`

## 18. 备份、同步与恢复

- `workspace/backup_workspace_source.sh`
- `docker/export_ros_image.sh`
- `docker/import_ros_image.sh`
- `setup/export_dependency_manifest.sh`
- `setup/restore_development_environment.sh`

## 19. 工具箱仓库维护

- `setup/init_toolbox_repository.sh`
- `diagnostics/lint_shell_scripts.sh`
- `diagnostics/format_shell_scripts.sh`
- `diagnostics/check_secrets.sh`
- `docs/generate_script_index.sh`
- `diagnostics/validate_toolbox.sh`

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
