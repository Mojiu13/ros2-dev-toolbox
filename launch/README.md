# launch 目录规划

> 状态：规划阶段。当前仅记录职责，不包含脚本实现。

## 目录定位

`launch/` 用于提供日常运行入口，把需要多次输入、容易遗漏、需要统一参数的 ROS2 启动命令封装成清晰的工作流入口。

本目录只负责启动、停止和任务入口编排，不负责深入诊断，也不负责实现 MoveIt2、controller 或节点本身的业务逻辑。

## 基础启动入口

### `run_ros_node.sh`

负责运行指定 ROS2 节点：

- 加载正确的 ROS2 基础环境和工作空间 overlay；
- 接收包名和可执行程序名；
- 支持传入节点名称、namespace、参数和 remap；
- 检查包和可执行程序是否存在；
- 记录启动命令和日志位置；
- 节点退出后返回真实退出码；
- 不把任意字符串直接拼接成不安全命令。

### `run_ros_launch.sh`

负责运行指定 launch 文件：

- 加载 ROS2 和工作空间环境；
- 接收 package、launch 文件和 launch arguments；
- 检查 launch 文件是否可被 ROS2 找到；
- 创建本次运行日志目录；
- 记录实际传入参数；
- 捕获 Ctrl+C 并等待子进程正常退出；
- 启动失败时指向对应 launch 日志。

### `launch_robot_description.sh`

负责启动机器人模型显示所需基础系统：

- 加载 URDF 或 Xacro；
- 启动 `robot_state_publisher`；
- 按需要启动 `joint_state_publisher`；
- 设置 `robot_description`；
- 检查 base frame 和关节状态来源；
- 启动后验证关键 TF 是否出现；
- 不负责启动 controller 或 MoveIt2。

### `start_rviz.sh`

负责启动 RViz：

- 检查容器 GUI 链路；
- 加载指定 RViz 配置；
- 检查配置文件是否存在；
- 设置必要的 ROS2 环境；
- 保存 RViz 输出日志；
- 启动失败时区分 DISPLAY、OpenGL、配置文件和 ROS2 环境问题。

## 完整机器人系统入口

### `start_robot_stack.sh`

负责按确定顺序启动完整机械臂开发系统：

- 执行启动前健康检查；
- 启动机器人描述和 TF；
- 启动 ros2_control 与 controller_manager；
- 加载并激活必要 controller；
- 启动 MoveIt2；
- 启动 RViz；
- 检查关键节点、topic、action 和 controller；
- 任一关键阶段失败时停止后续阶段；
- 保存统一运行日志和进程信息。

### `stop_robot_stack.sh`

负责安全停止完整系统：

- 阻止新的任务进入；
- 取消仍在运行的任务；
- 停止 MoveIt2 和任务节点；
- 安全停止 controller；
- 停止 robot_state_publisher、RViz 和其他子进程；
- 等待正常退出后再清理残留进程；
- 保留运行日志和最终状态快照。

## 任务执行入口

### `run_robot_task.sh`

负责启动指定机械臂任务节点：

- 检查完整机器人系统是否健康；
- 检查任务节点包和入口；
- 传入目标、模式和配置；
- 记录任务开始时间和 Git 状态；
- 观察任务退出码；
- 任务失败时触发诊断信息收集；
- 不在脚本中硬编码具体运动轨迹。

### `run_pick_place_task.sh`

负责启动 arm 与 gripper 协调任务：

- 检查机械臂和夹爪 controller；
- 检查对应 action server；
- 按任务配置运行预抓取、抓取、抬升、移动和放置流程；
- 记录每一步成功、失败或超时；
- 某一步失败时停止后续动作；
- 调用任务节点完成业务逻辑，脚本只负责编排与观察。

### `cancel_robot_task.sh`

负责取消当前任务：

- 定位当前任务进程和 action goal；
- 请求任务节点停止接收新动作；
- 请求取消当前 action；
- 检查取消是否被接受；
- 检查 controller 是否仍在执行；
- 超时或拒绝取消时进入安全停止流程；
- 不直接把强制杀进程作为第一手段。

### `safe_stop_robot.sh`

负责在异常情况下进入安全停止状态：

- 停止新的任务请求；
- 取消当前 MoveIt2 或 controller action；
- 请求 controller 保持或停止；
- 保存当前 joint state、TF 和 controller 状态；
- 输出尚未停止的进程和 action；
- 必要时逐级升级停止手段；
- 真实硬件场景下必须与设备厂商安全机制配合。

## 推荐执行顺序

1. `run_ros_node.sh` 或 `run_ros_launch.sh` 用于单模块测试；
2. `launch_robot_description.sh` 验证模型与 TF；
3. ros2_control 和 MoveIt2 各自完成独立验证；
4. `start_robot_stack.sh` 启动完整系统；
5. `run_robot_task.sh` 执行任务；
6. `stop_robot_stack.sh` 完成收尾。

## 边界

- 启动脚本不负责安装缺失依赖；
- 不在启动入口中隐藏自动清理构建目录等破坏性操作；
- controller 细节归 `ros2_control/`；
- MoveIt2 规划执行细节归 `moveit/`；
- 故障收集、进程清理和健康检查归 `diagnostics/`。
