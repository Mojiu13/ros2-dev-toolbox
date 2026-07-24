# `moveit/` 目录

> 状态：已实现。

`moveit/` 负责 MoveIt2 环境、Demo、系统状态、Controller 映射、规划、执行、轨迹和 Planning Scene 观察。

## 已实现脚本

- `check_moveit_environment.sh`
- `start_moveit_demo.sh`
- `inspect_moveit_system.sh`
- `check_moveit_controllers.sh`
- `test_moveit_planning.sh`
- `test_moveit_execution.sh`
- `inspect_moveit_trajectory.sh`
- `inspect_planning_scene.sh`

## 示例

检查环境：

```bash
bash moveit/check_moveit_environment.sh
```

启动可替换的 Demo：

```bash
bash moveit/start_moveit_demo.sh \
  --package moveit_resources_panda_moveit_config \
  --launch-file demo.launch.py
```

运行自定义规划或执行测试节点：

```bash
bash moveit/test_moveit_execution.sh \
  --package my_py_pkg \
  --executable moveitpy_closed_loop \
  -- --ros-args -p planning_group:=panda_arm
```

查看轨迹和 Planning Scene：

```bash
bash moveit/inspect_moveit_trajectory.sh --topic /display_planned_path --once
bash moveit/inspect_planning_scene.sh --topic /monitored_planning_scene
```

## 层级边界

```text
Task Node
→ MoveIt2 规划与执行
→ FollowJointTrajectory Action
→ ros2_control Controller
→ hardware interface
```

本目录负责 MoveIt2 层；底层 Controller 由 `ros2_control/` 管理，完整启动编排由 `launch/` 管理。

## 验证重点

- `move_group` 是否存在；
- planning group 和当前状态是否有效；
- MoveIt Controller 映射与 Action namespace 是否正确；
- 轨迹的 `joint_names`、points 和 `time_from_start` 是否合理；
- Planning Scene、碰撞物体和起始状态是否同步。
