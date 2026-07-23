# lib 目录

> 状态：模块 01 已实现。

## 目录定位

`lib/` 保存多个工作脚本都会复用的公共 Shell 能力。业务脚本只描述自己的工作流程，把配置加载、日志、错误处理、路径检查、命令检查和用户确认等通用逻辑集中放在这里。

本目录不是独立工作流入口。除 `load_toolbox_config.sh` 需要通过 `source` 加载外，正常情况下不应直接运行这些文件。

## 已实现文件

### `load_toolbox_config.sh`

统一加载工具箱配置：

- 定位仓库根目录；
- 使用稳定的内置默认值；
- 读取用户本机配置；
- 允许当前 Shell 环境变量覆盖配置文件；
- 区分宿主机与容器内路径；
- 导出 Docker 镜像完整引用等派生变量；
- 配置缺失或加载失败时返回明确错误；
- 防止同一配置被无意重复加载。

使用方式：

```bash
source lib/load_toolbox_config.sh
```

加载完成后可直接使用：

```bash
echo "$ROS_DISTRO"
echo "$HOST_WORKSPACE"
echo "$DOCKER_IMAGE_REFERENCE"
```

需要强制重新加载时：

```bash
TOOLBOX_CONFIG_RELOAD=1 source lib/load_toolbox_config.sh
```

### `common.sh`

提供通用基础函数：

- 检查一个或多个命令是否存在；
- 检查文件和目录；
- 生成绝对路径；
- 判断当前位于宿主机还是容器；
- 检查 root 或普通用户权限；
- 检查 ROS2 工作空间结构；
- 提供用户确认、命令重试、安全退出、时间戳和临时目录能力。

### `logging.sh`

提供统一日志输出：

- 支持 `DEBUG`、`INFO`、`SUCCESS`、`WARN`、`ERROR`；
- 自动加入时间和调用脚本名称；
- 终端支持颜色，重定向时自动使用纯文本；
- 支持 `TOOLBOX_LOG_LEVEL`、`TOOLBOX_QUIET` 和 `TOOLBOX_VERBOSE`；
- 设置 `TOOLBOX_LOG_FILE` 后同时写入日志文件；
- 警告和错误写入标准错误流。

调用示例：

```bash
source lib/logging.sh
toolbox_log_info "开始执行"
toolbox_log_success "执行成功"
toolbox_log_warn "存在风险"
toolbox_log_error "执行失败"
```

### `error_handling.sh`

提供统一异常和退出处理：

- 定义稳定退出码；
- 捕获未处理错误并显示退出码、行号和失败命令；
- 捕获 `INT` 和 `TERM` 信号；
- 支持注册多个清理动作，并按后进先出顺序执行；
- 防止清理动作被重复执行；
- 提供致命错误、可恢复错误和结果检查函数。

调用示例：

```bash
source lib/error_handling.sh
toolbox_enable_error_handling

temp_dir="$(mktemp -d)"
toolbox_register_cleanup rm -rf "$temp_dir"
```

## 推荐加载顺序

业务脚本通常按以下顺序加载：

```bash
source "$TOOLBOX_ROOT/lib/logging.sh"
source "$TOOLBOX_ROOT/lib/common.sh"
source "$TOOLBOX_ROOT/lib/error_handling.sh"
source "$TOOLBOX_ROOT/lib/load_toolbox_config.sh"

toolbox_enable_error_handling
```

配置初始化和配置校验脚本不需要先加载本机配置，因为它们本身就是负责创建和检查配置的入口。

## 设计原则

- 公共函数小而明确；
- 不在公共库中隐藏大段业务流程；
- 不静默修改系统关键状态；
- 函数统一使用 `toolbox_` 前缀；
- 调用者获得一致的日志和退出状态；
- 后续模块优先复用这些公共能力，避免复制粘贴。

## 边界

- 不直接构建镜像、创建容器或构建工作空间；
- 不保存用户本地配置；
- 不承担 ROS2、MoveIt2 或 ros2_control 业务逻辑；
- 除配置加载器外，不作为用户日常直接运行的命令入口。
