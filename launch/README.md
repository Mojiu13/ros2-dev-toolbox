# `launch/` 目录

> 状态：已实现。

`launch/` 提供日常运行入口，把 ROS2 节点、Launch 文件、RViz、机器人栈和任务命令封装成可配置脚本。

## 功能分组

### 通用入口

- `run_ros_node.sh`
- `run_ros_launch.sh`
- `start_rviz.sh`

### 机器人系统

- `launch_robot_description.sh`
- `start_robot_stack.sh`
- `stop_robot_stack.sh`

### 任务入口

- `run_robot_task.sh`
- `run_pick_place_task.sh`
- `cancel_robot_task.sh`
- `safe_stop_robot.sh`

## 示例

```bash
bash launch/run_ros_node.sh \
  --package my_pkg \
  --executable my_node \
  -- --ros-args -p rate:=10.0
```

```bash
bash launch/run_ros_launch.sh \
  --package my_robot_moveit_config \
  --launch-file demo.launch.py \
  -- use_rviz:=true
```

```bash
bash launch/start_rviz.sh --config config/robot.rviz
```

## 停止机制

`stop_robot_stack.sh` 使用显式 PID 文件停止已知启动实例，而不是通过模糊进程名称批量终止。启动编排脚本需要在项目层负责记录对应 PID。

`safe_stop_robot.sh` 可以请求停用指定 Controller 或向指定 PID 发送中断信号，但它只是软件层辅助工具。

## 安全边界

- 真实机器人运动前应先运行任务级预检；
- 真实机械臂必须保留厂商急停、限位和硬件安全链；
- `cancel_robot_task.sh` 的通用取消能力受 ROS2 CLI 版本和 Action 客户端实现影响；
- 本目录不实现具体任务算法，也不替代 `ros2_control/` 和 `moveit/` 的专项检查。
