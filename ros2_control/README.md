# `ros2_control/` 目录

> 状态：已实现。

`ros2_control/` 负责 Controller 生命周期、hardware interface、FollowJointTrajectory 和关节名称一致性相关操作。所有 Controller 命令都允许覆盖 controller manager 路径。

## 已实现脚本

- `launch_ros2_control.sh`
- `inspect_controllers.sh`
- `load_controller.sh`
- `activate_controller.sh`
- `deactivate_controller.sh`
- `switch_controllers.sh`
- `inspect_hardware_interfaces.sh`
- `send_joint_trajectory.sh`
- `check_joint_name_consistency.sh`

## 示例

```bash
bash ros2_control/inspect_controllers.sh --manager /controller_manager
```

```bash
bash ros2_control/load_controller.sh \
  --controller panda_arm_controller \
  --manager /controller_manager \
  --set-state active
```

```bash
bash ros2_control/switch_controllers.sh \
  --manager /controller_manager \
  --deactivate forward_position_controller \
  --activate panda_arm_controller \
  --strict
```

直接发送轨迹：

```bash
bash ros2_control/send_joint_trajectory.sh \
  --action /panda_arm_controller/follow_joint_trajectory \
  --goal-file config/panda_goal.yaml
```

## 参数化原则

以下内容不写死：

```text
Controller 名称
controller manager 路径
Action 名称和类型
轨迹 Goal 文件
URDF、Controller YAML、MoveIt YAML 路径
```

## 安全边界

- 激活、停用和切换 Controller 会改变运行状态；
- 直接发送轨迹会绕过 MoveIt 规划和碰撞检查；
- 在真实机械臂上发送轨迹前必须验证关节名、单位、范围、时间单调性和硬件安全条件；
- `check_joint_name_consistency.sh` 使用通用文本提取，只能作为初筛，复杂 YAML 应人工复核。
