# `docs/` 目录

> 状态：已实现。

`docs/` 同时保存长期说明文档和用于生成实验记录、系统快照、日志归档、Git 状态以及脚本索引的工具。

体积较大的原始日志、快照和压缩包默认应写到 `LOG_DIR`、`ARCHIVE_DIR` 或 `BACKUP_DIR`，而不是直接提交进 Git 仓库。

## 已实现脚本

| 脚本 | 用途 |
|---|---|
| `create_run_record.sh` | 创建带时间戳的实验记录目录和元数据 |
| `record_git_state.sh` | 保存分支、状态、最新提交、远程和可选 diff |
| `snapshot_ros_system.sh` | 组合生成 ROS2 快照，可选机器人状态 |
| `archive_run_logs.sh` | 将指定日志目录归档并验证，不删除来源 |
| `generate_script_index.sh` | 扫描仓库生成 `SCRIPT_INDEX.md` |

## 示例

```bash
record_dir="$(bash docs/create_run_record.sh \
  --name panda_moveit_test \
  --notes 'Test planning and execution')"
```

```bash
bash docs/record_git_state.sh \
  --repository . \
  --output "$record_dir/git-state.txt" \
  --include-diff
```

```bash
bash docs/snapshot_ros_system.sh \
  --output "$record_dir/system-snapshot" \
  --include-robot \
  --joint-states /joint_states \
  --manager /controller_manager
```

```bash
bash docs/archive_run_logs.sh \
  --input "$record_dir" \
  --compression gz
```

生成脚本索引：

```bash
bash docs/generate_script_index.sh
```

## 记录原则

一次可复现实验至少应记录：

```text
时间
Git commit 与未提交改动
ROS_DISTRO 和 ROS_DOMAIN_ID
工作空间路径
启动参数
关键节点、Topic、Action 和 Controller
输入目标
执行结果
异常日志与修复过程
```

## 边界

- `archive_run_logs.sh` 不自动删除来源；
- 配置文件疑似包含敏感字段时，`create_run_record.sh` 不会复制该配置；
- 自动生成的索引用于导航，具体任务说明仍以 `WORKFLOW_INDEX.md` 和各目录 README 为准。
