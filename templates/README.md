# templates 目录规划

> 状态：规划阶段。当前仅记录职责，不包含脚本实现。

## 目录定位

`templates/` 用于保存可重复生成的 ROS2 工程骨架和脚本骨架。它的目标是减少手工创建 package、launch、参数文件和工具脚本时的遗漏，但不替代对 ROS2 工程结构的理解。

模板生成流程只创建新文件或新目录，不负责构建、运行或修改已有项目业务代码。

## 计划脚本

### `create_python_package.sh`

负责生成标准 `ament_python` 包骨架：

- 获取包名、节点名和依赖；
- 校验 ROS2 包命名；
- 创建 `package.xml`、`setup.py`、`setup.cfg`、资源索引和 Python 模块目录；
- 创建最小节点入口；
- 创建测试与 launch 目录占位；
- 检查目标路径冲突；
- 创建后执行结构校验，但不自动构建整个工作空间。

### `create_cpp_package.sh`

负责生成标准 `ament_cmake` 包骨架：

- 获取包名、可执行程序名和依赖；
- 创建 `package.xml`、`CMakeLists.txt`、`src/`、`include/`；
- 创建最小 `rclcpp` 节点入口；
- 设置安装规则；
- 创建 launch、config 和测试目录占位；
- 检查包名、目标名和目录名一致性。

### `validate_ros_package.sh`

负责检查已有 ROS2 包结构：

- 检查 `package.xml`；
- 判断 `ament_python` 或 `ament_cmake` 类型；
- 检查 `setup.py`、`setup.cfg`、`CMakeLists.txt` 和资源索引；
- 检查依赖声明与代码引用是否明显不一致；
- 检查 console script、安装目标和 launch/config 安装规则；
- 检查包名、模块名和目录名；
- 只报告结构问题，不自动改写项目。

### `create_launch_template.sh`

负责生成标准 Python launch 文件：

- 创建基础 launch 描述；
- 预留节点、参数、namespace、remap 和条件启动位置；
- 支持声明 launch argument；
- 提供日志和输出配置位置；
- 检查目标文件是否存在；
- 生成后不自动启动。

### `create_parameter_template.sh`

负责生成 ROS2 参数 YAML 骨架：

- 创建节点名和 `ros__parameters` 层级；
- 预留常见标量、列表和路径参数示例位置；
- 避免 YAML 缩进和节点名层级错误；
- 支持生成通用参数文件或指定节点参数文件；
- 不填写无法确认的真实业务参数。

### `create_script_template.sh`

负责生成本工具箱统一风格的 Shell 脚本骨架：

- 创建 shebang 和严格模式位置；
- 引入统一配置与公共库；
- 预留帮助信息、参数解析、主函数和退出处理；
- 预留日志和高风险操作确认位置；
- 设置推荐文件名；
- 设置可执行权限；
- 不自动填充具体业务命令。

## 计划模板资源

- `ament_python` 包模板；
- `ament_cmake` 包模板；
- Python launch 模板；
- 参数 YAML 模板；
- Bash 工作脚本模板；
- 诊断报告模板；
- 实验记录模板；
- README 模板。

## 设计要求

- 模板必须保持最小、清晰、可删除；
- 生成内容应显式标注需要用户替换的位置；
- 不在模板中写死用户名、工作空间路径、容器名和 ROS2 发行版；
- 不把所有可能功能塞进一个庞大模板；
- 生成后必须能被 `validate_ros_package.sh` 或工具箱检查流程验证。

## 边界

- 不负责构建新生成的包；
- 不负责安装依赖；
- 不负责运行 launch；
- 不覆盖已有文件；
- 不在模板中保存敏感信息。
