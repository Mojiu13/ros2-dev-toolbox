# `workspace/` 目录

> 状态：已实现。

`workspace/` 负责 ROS2 工作空间从创建、依赖安装、源码导入、构建、清理、环境加载，到源码备份的完整生命周期。所有入口都支持通过 `--workspace` 覆盖默认路径。

## 功能分组

### 初始化与依赖

- `create_ros_workspace.sh`
- `check_workspace_structure.sh`
- `init_rosdep.sh`
- `install_workspace_dependencies.sh`
- `import_workspace_repositories.sh`

### 构建与清理

- `build_workspace.sh`
- `build_package.sh`
- `build_up_to_package.sh`
- `clean_package.sh`
- `clean_workspace.sh`
- `rebuild_workspace.sh`
- `inspect_build_failure.sh`

### 环境加载

- `source_ros_environment.sh`
- `source_workspace.sh`
- `inspect_overlay_environment.sh`
- `open_ros_terminal.sh`

### 备份

- `backup_workspace_source.sh`

## 常用流程

```bash
bash workspace/create_ros_workspace.sh --workspace "$HOME/ros_ws"
bash workspace/init_rosdep.sh
bash workspace/install_workspace_dependencies.sh --workspace "$HOME/ros_ws"
bash workspace/build_workspace.sh --workspace "$HOME/ros_ws"
```

将额外参数传给 `colcon`：

```bash
bash workspace/build_workspace.sh \
  --workspace "$HOME/ros_ws" \
  -- --parallel-workers 4 --event-handlers console_direct+
```

构建指定包：

```bash
bash workspace/build_package.sh \
  --workspace "$HOME/ros_ws" \
  --package my_robot_package
```

加载环境时必须使用 `source`：

```bash
source workspace/source_workspace.sh --workspace "$HOME/ros_ws"
```

## 清理保护

`clean_package.sh`、`clean_workspace.sh` 和 `rebuild_workspace.sh` 会先验证工作空间结构并显示目标路径，默认要求确认。

## 路径约定

```text
WORKSPACE/
├── src/
├── build/
├── install/
└── log/
```

- `src/` 是需要备份和版本控制的源码；
- `build/`、`install/`、`log/` 是可重新生成的构建结果；
- `backup_workspace_source.sh` 默认只归档源码和少量顶层元数据，不归档构建产物。
