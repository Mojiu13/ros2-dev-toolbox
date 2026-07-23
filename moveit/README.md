# moveit 目录规划

> 状态：规划阶段。当前仅记录职责，不包含脚本实现。

## 目录定位

`moveit/` 负责 MoveIt2 环境检查、demo 启动、系统观察、controller 映射检查、规划测试、执行测试、轨迹检查和 Planning Scene 检查。

该目录只处理 MoveIt2 规划与执行层。底层 controller 和 hardware interface 由 `ros2_control/` 管理，完整系统启动编排由 `launch/` 管理。

## 计划脚本

### `check_moveit_environment.sh`

负责检查 MoveIt2 运行前提：

- 检查当前 ROS2 发行版；
- 检查 MoveIt2 核心包；
- 检查 MoveItPy、MoveIt config 和 demo 资源；
- 检查规划插件和 planning pipeline；
- 检查机器人描述、SRDF、kinematics 和 joint limits 配置是否存在；
- 检查工作空间 overlay 是否正确；
- 输出缺失包、版本冲突和配置缺失；
- 只检查，不自动安装或修改配置。

### `start_moveit_demo.sh`

负责启动指定 MoveIt2 demo：

- 读取机器人 MoveIt config；
- 启动 `move_group`；
- 启动 fake hardware 或对应控制系统；
- 启动必要 controller；
- 启动 RViz MotionPlanning 插件；
- 检查关键节点、参数和 action；
- 保存统一启动日志；
- 区分 MoveIt2、RViz、controller 和 GUI 启动错误。

### `inspect_moveit_system.sh`

负责查看 MoveIt2 当前系统状态：

- 检查 `move_group` 是否存在；
- 查看机器人描述和语义描述参数；
- 查看 planning group；
- 查看 planning pipeline 和 planner plugin；
- 查看运动学、关节限制和执行参数；
- 检查当前状态监视器是否获得 joint state；
- 检查 MoveIt2 提供的 service 和 action；
- 不修改运行时参数。

### `check_moveit_controllers.sh`

负责检查 MoveIt2 与 ros2_control 的 controller 映射：

- 读取 MoveIt controller 配置；
- 检查 controller 名称；
- 检查 action namespace 和 action 类型；
- 检查 MoveIt2 规划组关节与 controller 关节；
- 检查对应 controller 是否 active；
- 检查 FollowJointTrajectory action server 是否存在；
- 输出名称、namespace、关节或状态不一致的位置；
- 不自动改写 YAML。

### `test_moveit_planning.sh`

负责只测试规划，不执行轨迹：

- 检查 MoveIt2 系统状态；
- 设置当前状态作为起始状态；
- 接收安全的 named target、joint goal 或 pose goal；
- 调用规划；
- 输出规划是否成功、错误码和耗时；
- 保存规划轨迹摘要；
- 检查目标不可达、起始状态无效和碰撞等常见失败；
- 不调用 controller 执行。

### `test_moveit_execution.sh`

负责测试完整 plan + execute 链路：

- 先执行任务前检查；
- 设置当前状态和安全目标；
- 完成规划；
- 规划成功后才提交执行；
- 观察 MoveIt2 controller 选择；
- 观察 FollowJointTrajectory goal、feedback 和 result；
- 区分 plan failed 与 execute failed；
- 保存规划结果、执行结果和最终 joint state；
- 默认面向 fake hardware，真实硬件需要额外安全确认。

### `inspect_moveit_trajectory.sh`

负责查看 MoveIt2 输出轨迹：

- 显示 `joint_names`；
- 显示轨迹点数量；
- 查看 position、velocity、acceleration 和 effort 字段；
- 查看每个点的 `time_from_start`；
- 检查关节数量和点维度是否一致；
- 检查时间是否严格递增；
- 对比速度和加速度缩放前后的轨迹时长；
- 只分析轨迹，不修改轨迹或发送执行。

### `inspect_planning_scene.sh`

负责检查 Planning Scene：

- 查看当前机器人状态；
- 检查 Planning Scene 是否持续更新；
- 列出世界碰撞物体和附着物体；
- 检查 Allowed Collision Matrix；
- 检查起始状态碰撞；
- 检查目标状态碰撞；
- 辅助定位 `panda_hand - panda_link5` 等碰撞问题；
- 输出证据，不自动放宽碰撞规则。

## 推荐执行顺序

1. `check_moveit_environment.sh`
2. 独立完成 ros2_control 验证
3. `start_moveit_demo.sh`
4. `inspect_moveit_system.sh`
5. `check_moveit_controllers.sh`
6. `test_moveit_planning.sh`
7. `inspect_moveit_trajectory.sh`
8. `test_moveit_execution.sh`
9. 失败时使用 `inspect_planning_scene.sh` 和 `diagnostics/` 收集证据

## 关键验收条件

- `move_group` 正常运行；
- robot description 与 SRDF 正确加载；
- planning group 可用；
- current state 正常更新；
- planning pipeline 可用；
- 简单安全目标能够规划；
- MoveIt2 能找到正确 controller；
- 执行结果和最终 joint state 可验证。

## 边界

- 不负责 controller_manager 的生命周期操作；
- 不负责修复 URDF、SRDF 或 YAML；
- 不把 RViz 中显示轨迹等同于机器人已执行；
- 不把规划成功等同于执行成功；
- 不在检查脚本中自动禁用碰撞或扩大关节限制。
