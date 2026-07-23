# workspace 目录规划

> 状态：规划阶段。当前仅记录职责，不包含脚本实现。

## 目录定位

`workspace/` 负责 ROS2 工作空间从创建、依赖安装、源码导入、构建、清理、环境加载，到备份的完整生命周期。

本目录面向 `/root/ros_ws` 或用户配置的其他工作空间。所有脚本都必须明确区分：

- 工作空间根目录；
- `src/` 源码目录；
- `build/` 构建中间产物；
- `install/` 安装与 overlay；
- `log/` 构建日志。

## 工作空间初始化

### `create_ros_workspace.sh`

负责创建标准 ROS2 工作空间：

- 读取目标工作空间路径；
- 创建根目录和 `src/`；
- 检查父目录权限；
- 检查目标路径是否已经包含工作空间；
- 避免覆盖已有源码；
- 输出新工作空间的绝对路径；
- 创建后不自动构建空工作空间，除非流程明确要求。

### `check_workspace_structure.sh`

负责判断当前路径是否为有效工作空间：

- 检查 `src/`；
- 检查 `build/`、`install/`、`log/` 的状态；
- 检查目录所有权和写权限；
- 检查是否误在 `src/` 内再次创建工作空间；
- 检查嵌套工作空间和残留 overlay；
- 识别空工作空间、未构建工作空间和已构建工作空间。

### `init_rosdep.sh`

负责建立 rosdep 使用条件：

- 检查 rosdep 是否安装；
- 检查系统是否已经初始化；
- 仅在必要时执行初始化；
- 更新 rosdep 索引；
- 处理代理、证书和软件源错误；
- 区分 root 初始化与普通用户更新步骤；
- 避免重复初始化导致误导性错误。

### `install_workspace_dependencies.sh`

负责安装源码包声明的系统依赖：

- 扫描 `src/` 下的 `package.xml`；
- 根据当前 ROS2 发行版解析依赖；
- 跳过工作空间源码中已经提供的依赖；
- 安装可解析依赖；
- 汇总无法解析、无对应规则和安装失败的依赖；
- 保存安装日志；
- 不把依赖安装成功等同于源码一定能够构建。

### `import_workspace_repositories.sh`

负责从 `.repos` 文件导入源码：

- 检查 `.repos` 文件格式；
- 把仓库导入 `src/`；
- 保留指定分支、标签或 commit；
- 检查目标目录已经存在时的状态；
- 避免静默覆盖本地修改；
- 汇总成功、跳过和失败的仓库；
- 导入完成后记录精确版本。

## 构建工作流

### `build_workspace.sh`

负责完整构建当前工作空间：

- 检查工作空间结构；
- 加载 `/opt/ros/<distro>/setup.bash`；
- 确认没有加载错误的 overlay；
- 使用统一 colcon 参数构建全部包；
- 支持符号链接安装模式；
- 保存终端输出和 colcon 日志；
- 汇总成功、失败、跳过和中止的包；
- 明确指出第一个真正失败的包。

### `build_package.sh`

负责构建指定包：

- 校验包名是否存在；
- 支持一个或多个目标包；
- 只构建目标包及必要部分；
- 保留其他包已有构建结果；
- 构建后检查目标可执行程序或资源是否进入 `install/`；
- 输出后续需要 source 的提示。

### `build_up_to_package.sh`

负责构建指定包及其依赖链：

- 解析目标包；
- 构建依赖和目标包；
- 不构建无关下游包；
- 适合大型工作空间的局部验证；
- 输出实际参与构建的包集合。

### `clean_package.sh`

负责只清理指定包的构建结果：

- 定位该包在 `build/`、`install/` 和日志中的相关内容；
- 检查路径边界；
- 显示将删除的内容；
- 避免误删其他包；
- 用于解决单包缓存、入口点或 CMake 状态异常。

### `clean_workspace.sh`

负责清理整个工作空间的构建产物：

- 只允许删除当前工作空间下的 `build/`、`install/` 和 `log/`；
- 绝不删除 `src/`；
- 删除前显示绝对路径和预计范围；
- 要求明确确认；
- 处理权限和只读文件；
- 删除后重新检查目录状态。

### `rebuild_workspace.sh`

负责从干净状态重新构建：

- 调用工作空间检查；
- 清理旧构建结果；
- 更新或重新检查依赖；
- 执行完整构建；
- 构建完成后加载并验证 overlay；
- 适合处理缓存污染，不应成为每次开发的默认动作。

### `inspect_build_failure.sh`

负责分析最近一次构建失败：

- 定位最新 colcon 日志；
- 找到第一个失败包；
- 提取编译器、CMake、Python 打包或依赖错误；
- 区分根因错误和后续连锁中止；
- 显示相关包路径和日志位置；
- 生成便于复制到问题记录中的摘要；
- 不自动修改源码。

## 环境加载与开发终端

### `source_ros_environment.sh`

负责加载 ROS2 基础环境：

- 根据配置定位 `/opt/ros/<distro>/setup.bash`；
- 检查文件存在；
- 加载后检查 `ROS_DISTRO`；
- 检查 `ros2` 命令；
- 防止意外加载错误发行版；
- 明确该脚本需要被 source，而不是作为普通子进程执行。

### `source_workspace.sh`

负责加载工作空间 overlay：

- 先加载正确的 ROS2 基础环境；
- 检查 `install/setup.bash`；
- 加载当前工作空间；
- 验证包是否可被 `ros2 pkg` 发现；
- 显示当前 overlay 顺序；
- 未构建时不伪装为加载成功。

### `inspect_overlay_environment.sh`

负责检查环境覆盖关系：

- 查看 `AMENT_PREFIX_PATH`、`CMAKE_PREFIX_PATH` 和 Python 路径；
- 查看 ROS2 发行版；
- 识别加载过的多个工作空间；
- 检查旧工作空间是否排在新工作空间前面；
- 辅助定位“代码已修改但运行的仍是旧版本”；
- 输出建议的清理和重新加载顺序。

### `open_ros_terminal.sh`

负责打开配置完成的开发终端：

- 确认目标容器或宿主机环境；
- 自动进入工作空间；
- 加载 ROS2 与 overlay；
- 设置终端标题或提示符信息；
- 显示容器名、ROS2 发行版、Domain ID 和 Git 分支；
- 不在加载失败时继续给出可用终端假象。

## 备份

### `backup_workspace_source.sh`

负责备份可重建工作空间所需内容：

- 备份 `src/`；
- 排除 `build/`、`install/` 和 `log/`；
- 保存 `.repos` 文件和依赖清单；
- 保存 Git 分支、commit 和未提交状态摘要；
- 为归档生成时间戳和校验信息；
- 不默认包含大型数据集、模型和私密配置。

## 推荐执行顺序

1. `create_ros_workspace.sh`
2. `init_rosdep.sh`
3. `import_workspace_repositories.sh`
4. `install_workspace_dependencies.sh`
5. `build_workspace.sh`
6. `source_workspace.sh`
7. `inspect_overlay_environment.sh`

## 边界

- 不负责安装 Docker 或创建容器；
- 不负责具体节点、MoveIt2 或 controller 启动；
- 不在构建脚本中偷偷修改源码；
- 清理操作必须严格限定在工作空间根目录内；
- 工程模板由 `templates/` 管理，运行入口由 `launch/` 管理。
