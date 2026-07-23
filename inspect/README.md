# inspect 目录规划

> 状态：规划阶段。当前仅记录职责，不包含脚本实现。

## 目录定位

`inspect/` 用于观察 ROS2 系统当前实际状态。它不负责改变系统配置，也不主动修复问题，而是把 node、topic、service、action、parameter、TF、URDF 和通信图等信息以统一方式展示出来。

该目录的定位是“看清系统正在发生什么”，为学习、调试和故障判断提供证据。

## ROS2 通信观察

### `inspect_nodes.sh`

负责查看节点状态：

- 列出当前可发现节点；
- 显示指定节点的 publisher、subscriber、service、action 和 parameter；
- 检查重复节点名和 namespace；
- 标记关键节点是否存在；
- 区分 ROS2 daemon 缓存与真实运行节点；
- 不自动重启或结束任何节点。

### `inspect_topics.sh`

负责查看 topic 状态：

- 列出 topic 和消息类型；
- 显示指定 topic 的 publisher 与 subscriber；
- 支持查看一次消息和持续观察；
- 检查 QoS 兼容性提示；
- 检查无发布者、无订阅者或类型冲突；
- 对大型消息避免默认持续输出全部内容。

### `inspect_services.sh`

负责查看 service 状态：

- 列出 service 和接口类型；
- 显示指定 service 的服务节点；
- 查看接口定义；
- 支持在明确参数下执行测试调用；
- 区分 service 不存在、类型错误和调用超时；
- 测试调用不得默认执行高风险设备操作。

### `inspect_actions.sh`

负责查看 action 状态：

- 列出 action 名称和类型；
- 显示 action server 与 client；
- 查看 goal、feedback 和 result 接口；
- 检查 FollowJointTrajectory 等关键 action server；
- 支持观察测试 goal 的反馈与结果；
- 不默认向真实机械臂发送动作目标。

### `inspect_parameters.sh`

负责查看节点参数：

- 列出指定节点参数；
- 获取参数值和类型；
- 查看参数描述与可修改状态；
- 对比参数文件和运行时实际值；
- 支持只读检查和经确认后的临时修改；
- 不把运行时修改当作配置文件已经更新。

### `show_ros_graph.sh`

负责显示节点通信图：

- 启动图形化通信图或导出静态结果；
- 标记节点和 topic 连接；
- 支持过滤系统内部 topic；
- 帮助识别孤立节点和意外连接；
- 保存图像或结构化结果供文档使用；
- 不把通信图存在连接等同于消息内容正确。

### `measure_topic_rate.sh`

负责测量 topic 实际频率：

- 接收目标 topic；
- 测量平均频率、波动和样本数量；
- 支持设置观察时长；
- 用于 timer、传感器和 `/joint_states`；
- 区分无消息、频率过低和发布不稳定；
- 结果应记录测试时间和当前系统负载。

## 机器人模型与 TF 观察

### `validate_robot_description.sh`

负责检查 URDF 或 Xacro：

- 检查目标文件存在；
- 展开 Xacro；
- 检查 XML 和 URDF 语法；
- 汇总 link、joint、joint type 和 parent-child 关系；
- 检查重复名称、缺失引用和明显的树结构问题；
- 检查常见 origin、axis 和 limit 缺失；
- 生成检查后的临时 URDF，但不覆盖源文件。

### `inspect_tf_tree.sh`

负责查看完整 TF 树：

- 生成当前 frame 关系图；
- 检查树是否断裂；
- 检查重复 frame 和多个父节点异常；
- 查看关键 frame 的发布者、频率和时间；
- 识别静态 TF 与动态 TF；
- 保存结果供正常状态和异常状态对比。

### `check_tf_transform.sh`

负责检查两个 frame 间变换：

- 接收 source frame 和 target frame；
- 持续或单次查询变换；
- 显示平移、旋转和时间戳；
- 检查 frame 不存在、链路断裂和数据过期；
- 用于检查 `world`、`base_link`、末端和传感器 frame；
- 不对变换正确性做脱离模型定义的主观判断。

## 使用原则

- 优先只读；
- 每次输出应标明观察对象和时间；
- 支持人类可读摘要与原始输出保存；
- 对无限输出命令设置合理中止方式；
- 观察脚本不隐藏底层使用的 ROS2 CLI；
- 关键结论必须能追溯到实际命令结果。

## 边界

- 不负责 controller 生命周期操作；
- 不负责 MoveIt2 规划测试；
- 不负责进程清理和 daemon 重置；
- 不负责修改 URDF、参数文件或系统配置；
- 发现异常后把证据交给 `diagnostics/` 或对应功能目录处理。
