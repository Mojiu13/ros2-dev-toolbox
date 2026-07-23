# diagnostics 目录规划

> 状态：规划阶段。当前仅记录职责，不包含脚本实现。

## 目录定位

`diagnostics/` 负责健康检查、启动前检查、故障信息收集、残留进程处理、ROS2 daemon 重置、网络观察、日志清理、Docker 清理、磁盘检查以及工具箱自身质量检查。

本目录的原则是：

1. 先收集证据，再尝试恢复；
2. 先执行只读检查，再执行会改变系统状态的操作；
3. 清理和删除必须明确展示范围；
4. 不把“暂时恢复”误写成“根因已解决”。

## 健康检查

### `check_ros2_health.sh`

负责检查 ROS2 基础运行状态：

- 检查 ROS2 环境是否加载；
- 检查发行版是否符合配置；
- 检查 ROS2 CLI 和 daemon；
- 检查节点发现是否正常；
- 启动最小通信测试；
- 检查 ROS_DOMAIN_ID、RMW 和 localhost_only；
- 区分环境未加载、daemon 缓存和 DDS 发现问题；
- 只检查，不修改运行中的机器人系统。

### `check_workspace_health.sh`

负责检查工作空间：

- 检查目录结构和权限；
- 检查 `install/setup.bash`；
- 检查最近构建状态；
- 检查工作空间包是否可发现；
- 检查 overlay 顺序；
- 检查缺失依赖和残留构建错误；
- 检查 Git 状态和源码目录异常；
- 输出是否适合继续启动系统。

### `check_robot_stack_health.sh`

负责检查完整机械臂系统：

- 检查 robot description；
- 检查 `/joint_states`；
- 检查关键 TF；
- 检查 controller_manager 和 controller；
- 检查 hardware interface；
- 检查 `move_group`；
- 检查 MoveIt2 controller 映射和关键 action；
- 检查 RViz 仅作为可选显示项；
- 汇总系统在哪一层失败。

### `preflight_check.sh`

负责完整系统启动前检查：

- 检查宿主机、Docker 服务和容器状态；
- 检查 GPU 与 GUI 配置是否符合本次启动需求；
- 检查容器网络和工作空间挂载；
- 检查工作空间构建与环境加载；
- 检查配置文件和关键资源；
- 发现阻塞问题时终止启动；
- 把非阻塞警告与阻塞错误分开输出。

### `task_preflight_check.sh`

负责机械臂任务执行前检查：

- 检查完整机器人系统健康状态；
- 检查 joint state 是否持续更新；
- 检查 TF 是否新鲜；
- 检查 controller 是否 active；
- 检查 MoveIt2 与 controller action server；
- 检查当前状态是否有效；
- 检查是否已有任务正在执行；
- 检查目标任务需要的 arm、gripper 或其他资源；
- 未通过时禁止提交新任务。

## 诊断信息收集

### `collect_system_diagnostics.sh`

负责收集宿主机和容器基础环境：

- 记录操作系统、内核、架构、CPU、内存和磁盘；
- 记录 Docker 版本、服务状态和容器配置；
- 记录 NVIDIA 驱动、设备节点和 runtime；
- 记录网络、DNS 和代理摘要；
- 记录时间、时区和用户权限；
- 输出到独立时间戳目录；
- 对可能包含隐私或凭据的信息进行过滤。

### `collect_ros_diagnostics.sh`

负责收集 ROS2 通信状态：

- 记录 ROS2 环境变量；
- 保存 node、topic、service 和 action 列表；
- 保存关键节点信息；
- 保存关键 topic 类型与一次消息样本；
- 保存 parameter 摘要；
- 保存 ROS2 daemon 状态；
- 记录采集时间和 ROS_DOMAIN_ID；
- 对无限数据流使用明确采样窗口。

### `collect_robot_diagnostics.sh`

负责收集机械臂系统状态：

- 保存 robot description 基本摘要；
- 保存 `/joint_states` 样本和频率；
- 保存 TF 树和关键 frame 变换；
- 保存 controller 状态；
- 保存 hardware interface；
- 保存 FollowJointTrajectory action 信息；
- 保存 MoveIt2 系统和 controller 映射；
- 保存 Planning Scene 或碰撞摘要；
- 把不同层证据放入同一次运行记录。

### `generate_failure_report.sh`

负责生成可复现的故障报告：

- 记录问题标题、时间和环境；
- 记录预期行为和实际行为；
- 记录最小复现步骤；
- 汇总相关命令输出和日志；
- 标明第一个错误和连锁错误；
- 记录已经尝试的恢复动作；
- 附上 Git commit、配置摘要和诊断归档位置；
- 生成适合放入 GitHub Issue 或 `ERROR_LOG.md` 的 Markdown；
- 不凭猜测写入未经证实的根因。

## 进程、daemon 与网络恢复

### `find_stale_ros_processes.sh`

负责只读查找残留进程：

- 查找 RViz、move_group、controller_manager 和用户任务节点；
- 检查进程启动时间、父进程和命令行；
- 检查是否仍持有终端或容器；
- 标记可能属于旧运行的进程；
- 不自动结束任何进程。

### `cleanup_ros_processes.sh`

负责清理经确认的残留进程：

- 先调用残留进程检查；
- 显示拟停止进程；
- 优先发送正常终止信号；
- 等待后再升级强制终止；
- 避免误杀当前 shell、Docker daemon 或无关进程；
- 清理后重新检查 ROS2 图；
- 保存实际停止的进程清单。

### `reset_ros_daemon.sh`

负责重置 ROS2 daemon：

- 显示重置前 daemon 状态；
- 停止 daemon；
- 等待相关进程退出；
- 重新启动或在下一次 CLI 调用时恢复；
- 检查节点与 topic 列表是否刷新；
- 明确指出该操作不能修复真实 DDS 网络或节点故障。

### `inspect_network_usage.sh`

负责检查网络、端口和接口：

- 显示宿主机和容器网络接口；
- 检查路由、DNS、代理端口和防火墙；
- 检查 Docker 网络模式；
- 检查 DDS 可能使用的网络接口；
- 检查端口占用和多网卡影响；
- 保存网络快照；
- 不默认修改防火墙或路由。

## 清理与资源维护

### `clean_ros_logs.sh`

负责清理过旧 ROS2 和 colcon 日志：

- 扫描配置允许的日志目录；
- 按时间和大小列出候选项；
- 保留最近运行和故障归档；
- 删除前显示范围；
- 不触碰源码、配置和当前正在写入的日志。

### `clean_docker_cache.sh`

负责清理 Docker 构建缓存：

- 查看构建缓存占用；
- 识别可安全删除的缓存；
- 避免删除当前构建仍需要的对象；
- 删除前显示预计释放空间；
- 清理后重新统计占用；
- 不自动删除稳定镜像和运行容器。

### `prune_docker_resources.sh`

负责执行更广泛的 Docker 资源清理：

- 列出停止容器、悬空镜像、未使用网络和 volume；
- 区分可重建资源和可能含数据的 volume；
- 默认不删除 volume；
- 要求用户明确选择范围；
- 执行后保存删除清单；
- 属于高风险维护入口，不作为日常启动步骤。

### `check_disk_usage.sh`

负责分析磁盘占用：

- 查看系统分区可用空间；
- 统计 Docker 镜像、容器、volume 和缓存；
- 统计 ROS2 工作空间的 build、install 和 log；
- 统计实验记录和备份；
- 按大小排序主要占用来源；
- 只提供清理建议，不自动删除。

## 工具箱自身质量检查

### `lint_shell_scripts.sh`

负责检查 Shell 脚本质量：

- 检查 Bash 语法；
- 调用 ShellCheck；
- 检查 shebang、严格模式和公共库加载；
- 检查明显的未引用变量和危险路径展开；
- 汇总警告和错误；
- 不自动改变脚本行为。

### `format_shell_scripts.sh`

负责统一脚本格式：

- 使用统一 Shell 格式化工具；
- 检查格式化前后差异；
- 只处理工具箱声明支持的文件；
- 不执行语义重写；
- 支持检查模式与实际写入模式。

### `check_secrets.sh`

负责检查提交前敏感信息：

- 检查密码、Token、私钥和访问凭据；
- 检查 `.env`、代理认证信息和私有地址；
- 检查误提交的 SSH 文件；
- 区分示例占位值和真实凭据；
- 发现高风险内容时阻止发布流程；
- 只报告必要位置，避免在日志中再次完整输出秘密。

### `validate_toolbox.sh`

负责检查工具箱整体完整性：

- 检查约定目录和文档；
- 检查配置示例；
- 检查脚本可执行权限；
- 检查公共库引用；
- 检查脚本名称和索引一致性；
- 检查目录 README 是否覆盖实际脚本；
- 检查未实现、已废弃和重复入口；
- 输出工具箱发布前验收报告。

## 推荐诊断顺序

1. 不做修改地运行对应健康检查；
2. 收集系统、ROS2 和机器人诊断信息；
3. 找到第一个失败层；
4. 只对该层执行最小恢复；
5. 重新运行健康检查；
6. 生成故障报告；
7. 最后才处理日志和缓存清理。

## 边界

- 不负责实现 ROS2、MoveIt2 或 controller 业务功能；
- 不在诊断阶段自动修改源码或配置；
- 不在未确认时删除 volume、镜像、工作空间或日志；
- 不把重启、清缓存或杀进程当作默认解决方案；
- 诊断结论必须能回溯到保存的证据。
