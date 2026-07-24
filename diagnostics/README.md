# `diagnostics/` 目录

> 状态：已实现。

`diagnostics/` 负责健康检查、启动前检查、诊断采集、进程处理、ROS2 daemon、网络观察、日志与 Docker 清理、磁盘检查，以及工具箱自身质量验证。

## 功能分组

### 健康检查

- `check_ros2_health.sh`
- `check_workspace_health.sh`
- `check_robot_stack_health.sh`
- `preflight_check.sh`
- `task_preflight_check.sh`

### 诊断与恢复

- `collect_system_diagnostics.sh`
- `collect_ros_diagnostics.sh`
- `collect_robot_diagnostics.sh`
- `find_stale_ros_processes.sh`
- `cleanup_ros_processes.sh`
- `reset_ros_daemon.sh`
- `inspect_network_usage.sh`
- `generate_failure_report.sh`

### 清理与容量

- `clean_ros_logs.sh`
- `clean_docker_cache.sh`
- `prune_docker_resources.sh`
- `check_disk_usage.sh`

### 仓库质量

- `lint_shell_scripts.sh`
- `format_shell_scripts.sh`
- `check_secrets.sh`
- `validate_toolbox.sh`

## 推荐顺序

```text
只读健康检查
→ 收集诊断快照
→ 分析证据
→ 执行最小恢复操作
→ 再次运行健康检查
```

## 常用命令

```bash
bash diagnostics/preflight_check.sh
bash diagnostics/check_robot_stack_health.sh
bash diagnostics/collect_system_diagnostics.sh
bash diagnostics/collect_ros_diagnostics.sh
bash diagnostics/generate_failure_report.sh --notes "Execute failed after planning succeeded"
```

仓库验证：

```bash
bash diagnostics/validate_toolbox.sh
bash diagnostics/validate_toolbox.sh --shellcheck
```

清理脚本默认只预览：

```bash
bash diagnostics/clean_ros_logs.sh --older-than 14
bash diagnostics/clean_docker_cache.sh --until 168h
bash diagnostics/prune_docker_resources.sh --until 168h
```

明确执行：

```bash
bash diagnostics/clean_ros_logs.sh --older-than 14 --execute --yes
bash diagnostics/clean_docker_cache.sh --until 168h --execute --yes
```

## 安全原则

- 先收集证据，再尝试恢复；
- 清理操作默认预览；
- 进程清理必须显式提供 PID；
- Docker volume 不会默认参与清理；
- 格式化脚本默认只显示 diff，只有 `--write` 才改文件；
- 敏感信息扫描只做基础检测，不能替代专业 Secret Scanner。
