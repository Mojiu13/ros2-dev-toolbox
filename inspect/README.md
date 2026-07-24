# `inspect/` 目录

> 状态：已实现。

`inspect/` 用于只读观察 ROS2 系统当前状态，为学习、调试和故障判断提供证据。它不主动修改节点、Controller 或机器人状态。

## 已实现脚本

| 脚本 | 观察对象 |
|---|---|
| `inspect_nodes.sh` | 节点列表和指定节点接口 |
| `inspect_topics.sh` | Topic、类型、Publisher 和 Subscriber |
| `inspect_services.sh` | Service、类型和接口定义 |
| `inspect_actions.sh` | Action 列表和指定 Action 状态 |
| `inspect_parameters.sh` | 节点参数、描述和值 |
| `show_ros_graph.sh` | `rqt_graph` 通信图 |
| `measure_topic_rate.sh` | Topic 实际发布频率 |
| `validate_robot_description.sh` | Xacro 展开和 URDF 校验 |
| `inspect_tf_tree.sh` | 生成 TF frame 图 |
| `check_tf_transform.sh` | 实时查看两个 Frame 的变换 |

## 示例

```bash
bash inspect/inspect_nodes.sh --node /move_group
bash inspect/inspect_topics.sh --topic /joint_states --verbose
bash inspect/inspect_parameters.sh --node /move_group --parameter planning_pipelines
bash inspect/measure_topic_rate.sh --topic /joint_states --window 50
```

验证模型：

```bash
bash inspect/validate_robot_description.sh \
  --input robot.urdf.xacro \
  --output /tmp/robot.urdf \
  -- prefix:=demo_
```

查看 TF：

```bash
bash inspect/check_tf_transform.sh --source base_link --target tool0
```

## 边界

- 观察结果反映的是当前 ROS graph，旧 daemon 缓存可能需要先重置；
- `validate_robot_description.sh` 只检查模型语法和基础结构，不验证 MoveIt SRDF 或 Controller 配置；
- Topic 频率和 TF 观察脚本可能持续运行，需要使用 `Ctrl+C` 结束。
