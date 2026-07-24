# `templates/` 目录

> 状态：已实现。

`templates/` 用于生成 ROS2 工程骨架和常用配置文件，减少手工创建时的遗漏。模板只创建新内容，不负责构建或运行项目。

## 已实现脚本

| 脚本 | 用途 |
|---|---|
| `create_python_package.sh` | 创建 `ament_python` 包，可传入依赖 |
| `create_cpp_package.sh` | 创建 `ament_cmake` 包，可传入依赖 |
| `validate_ros_package.sh` | 检查 `package.xml`、构建类型和文件结构 |
| `create_launch_template.sh` | 生成最小 Python Launch 文件 |
| `create_parameter_template.sh` | 生成 ROS2 参数 YAML |
| `create_script_template.sh` | 生成启用 Bash 严格模式的脚本骨架 |

## 示例

```bash
bash templates/create_python_package.sh \
  --workspace "$HOME/ros_ws" \
  --name my_python_pkg \
  --dependencies "rclpy std_msgs"
```

```bash
bash templates/create_cpp_package.sh \
  --workspace "$HOME/ros_ws" \
  --name my_cpp_pkg \
  --dependencies "rclcpp std_msgs"
```

```bash
bash templates/create_launch_template.sh \
  --output "$HOME/ros_ws/src/my_pkg/launch/demo.launch.py" \
  --package my_pkg \
  --executable demo_node \
  --name demo_node
```

## 边界

- 模板不会覆盖既有业务逻辑；
- 创建包后仍需人工检查 `package.xml`、`setup.py`、`CMakeLists.txt` 和安装规则；
- 参数 YAML 和 Launch 模板是最小骨架，不代表完整机器人项目配置。
