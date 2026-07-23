# ros2_control 目录规划

> 状态：规划阶段。当前仅记录职责，不包含脚本实现。

## 目录定位

`ros2_control/` 负责 controller_manager、controller 生命周期、hardware interface、FollowJointTrajectory 和关节名称一致性的检查与操作。

该目录连接机器人描述、硬件接口和 MoveIt2 执行层。它既要支持 fake hardware，也要为以后接入真实机械臂保留明确边界。

## 计划脚本

### `launch_ros2_control.sh`

负责启动 ros2_control 基础系统：

- 加载包含 ros2_control 标签的机器人描述；
- 启动 controller_manager；
- 加载硬件插件或 fake hardware；
- 启动 joint_state_broadcaster；
- 按配置加载主要控制器；
- 检查 controller_manager service 是否可用；
- 检查 `/joint_states` 是否开始更新；
- 启动失败时区分机器人描述、硬件插件、参数文件和 controller 插件问题。

### `inspect_controllers.sh`

负责查看 controller 当前状态：

- 列出 controller 名称、类型和生命周期状态；
- 区分 unloaded、inactive 和 active；
- 检查预期 controller 是否存在；
- 检查 controller 对应 action server；
- 显示 controller 声明的关节和接口；
- 对比当前状态与配置文件期望；
- 只观察，不自动切换状态。

### `load_controller.sh`

负责加载指定 controller：

- 检查 controller_manager 是否运行；
- 检查目标 controller 是否已加载；
- 检查 controller 类型和参数配置；
- 请求加载 controller；
- 验证加载后的状态；
- 加载失败时输出插件、参数和接口相关信息；
- 不自动激活，除非调用流程明确要求。

### `activate_controller.sh`

负责配置并激活指定 controller：

- 检查 controller 是否已加载；
- 检查所需 command/state interface；
- 检查接口是否被其他 controller 占用；
- 依次完成 configure 和 activate；
- 验证 controller 状态和 action server；
- 激活失败时显示资源冲突或接口缺失；
- 不在未确认时停用其他 controller。

### `deactivate_controller.sh`

负责安全停用指定 controller：

- 检查 controller 当前状态；
- 检查是否有活动轨迹或 action goal；
- 请求取消或等待任务结束；
- 执行 deactivate；
- 验证接口是否释放；
- 不卸载 controller；
- 真实硬件环境下要保留安全保持策略。

### `switch_controllers.sh`

负责在控制器之间切换：

- 接收待停止和待启动 controller 集合；
- 检查资源接口冲突；
- 检查目标 controller 是否已加载和可配置；
- 使用统一切换请求完成停止与启动；
- 支持严格和尽力切换模式；
- 切换后检查所有目标状态；
- 失败时尽量保持系统处于可判断状态，而不是半切换状态。

### `inspect_hardware_interfaces.sh`

负责查看硬件接口：

- 列出 state interface 和 command interface；
- 显示接口是否 available；
- 显示 command interface 是否被 claimed；
- 显示具体由哪个 controller 占用；
- 对比 URDF ros2_control 标签和运行时接口；
- 辅助定位 controller 无法激活、关节不动或状态缺失问题。

### `send_joint_trajectory.sh`

负责绕过 MoveIt2，直接测试 joint_trajectory_controller：

- 检查 FollowJointTrajectory action server；
- 读取目标 controller 的关节顺序；
- 检查输入轨迹点、时间和关节数量；
- 发送测试 goal；
- 观察 feedback、result 和取消能力；
- 记录 controller 接收、执行和结束状态；
- 默认只允许 fake hardware 或明确确认的安全目标；
- 不把 action 接受等同于轨迹成功执行。

### `check_joint_name_consistency.sh`

负责检查贯穿系统的关节名称：

- 读取 URDF 中的关节；
- 读取 SRDF planning group；
- 读取 ros2_control 配置；
- 读取 controller YAML；
- 读取 MoveIt controller 映射；
- 对比 trajectory 中的 `joint_names`；
- 检查名称、数量、顺序和缺失项；
- 输出冲突发生在哪一层；
- 不自动重命名任何配置。

## 推荐执行顺序

1. 检查机器人描述中的 ros2_control 配置；
2. `launch_ros2_control.sh`；
3. `inspect_hardware_interfaces.sh`；
4. `inspect_controllers.sh`；
5. 加载并激活目标 controller；
6. `send_joint_trajectory.sh` 独立验证执行链路；
7. `check_joint_name_consistency.sh` 处理配置不一致；
8. 独立验证成功后再接入 MoveIt2。

## 关键验收条件

- controller_manager 可访问；
- joint_state_broadcaster 为 active；
- `/joint_states` 持续更新；
- 目标 controller 为 active；
- 所需接口 available 且正确 claimed；
- FollowJointTrajectory action server 存在；
- 直接发送安全轨迹可以得到明确 result；
- 关节名称在各层一致。

## 边界

- 不负责运动规划；
- 不负责生成复杂轨迹；
- 不负责修改 URDF 和 YAML；
- 不把 fake hardware 成功直接推断为真实硬件安全可用；
- 真实设备急停、限位和安全控制必须服从厂商系统。
