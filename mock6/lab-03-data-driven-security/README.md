# 实验 03：数据驱动的网络策略

## 场景

Quartz Relay 在预先配置好的 AWS 网络中运行内部服务平台。网络基线由另一团队管理，必须通过发现获取，不能重新创建。安全策略由治理工具以 CSV、JSON 或 YAML 格式提供。

当前 Terraform 配置来自一次未完成的迁移。它接近目标设计，但无法稳定地将所有受支持格式编译为稳定的安全组规则资源。

## 实验条件

- 建议用时：**45 分钟**；
- 将 bootstrap 基础设施视为另一团队管理的已有基础设施；
- 只能在 `student/` 中工作；
- 不得修改源数据来降低配置难度；
- 三个输入文件描述同一套逻辑策略，必须生成等价的受管规则；
- 下方各项结果独立评估，字母顺序不代表推荐顺序。

## 已有环境

初始化会在 LocalStack 中创建一个 VPC、两个子网和三个安全组。名称包含环境专属后缀。学生配置只接收该后缀，必须通过只读数据源发现资源 ID 和 CIDR block。

| 逻辑角色 | 已有对象 |
|---|---|
| `dmz` | 面向公网流量的子网 |
| `admin` | 管理流量子网 |
| `edge` | 入口服务安全组 |
| `ledger` | 有状态数据服务安全组 |
| `control` | 运维服务安全组 |

请运行匹配 shell 的 setup 或 reset 脚本。需要 Docker Desktop、Docker Compose、Terraform CLI 1.11.x，以及 Bash 或 PowerShell。

## 必需结果

### A. 稳定的受管规则

使用恰好一个 `aws_vpc_security_group_ingress_rule` 资源 block 管理所有启用的 ingress 策略行。

- 使用 `for_each` 和 `for` 表达式；
- 不得使用 `count` 或为每行创建资源 block；
- 永久地址不得依赖数组位置或文件顺序；
- 身份必须区分 source、destination、protocol、start port 和 end port；
- 两条启用规则都指向 TCP `8082` 的 `control`，由于来源不同，两条都必须存在。

### B. 外部策略格式

变量 `rules_format` 接受 `csv`、`json` 或 `yaml`，默认值为 `csv`。使用匹配的 Terraform 解码器，保持一条共享处理路径和一个资源 block，不得按源文件行号硬编码行为。

### C. 规范化策略模型

创建 `local.normalized_rules`，使每种输入都产生相同的 Terraform 值结构和逻辑值：`direction`、`source`、`destination`、`from_port`、`to_port`、`protocol`、`source_selector`、`description`、`enabled`。

端口必须是数字或 `null`，`enabled` 必须是布尔值，协议值必须规范化。空端口字段和 `null` 表示同样的“无端口”。

### D. 来源解析与过滤

只管理启用的 ingress 行：`-` 形式的 source 必须通过 `source_selector` 解析为已有子网 CIDR；命名安全组来源必须解析为已有安全组 ID；CIDR 规则只设置 `cidr_ipv4`，安全组规则只设置 `referenced_security_group_id`；两个参数对每条规则互斥；协议 `-1` 不得带无效端口参数；VPC、子网和安全组必须动态获取，不得使用固定 ID 或固定环境 CIDR。

### E. 检查输出

提供以下输出，值必须来自规范化策略和受管资源：`normalized_rules`、`ingress_rule_keys`、`rules_by_destination`、`rules_count_by_protocol`、`source_types`、`created_rule_ids`。

`ingress_rule_keys` 必须能证明两个 `control` TCP `8082` 规则拥有不同地址。以 list 暴露的集合必须保持 list 语义。

## 完成约束

- 重新排列任意输入文件的行，不得改变资源地址集合；
- 不得管理 egress 和禁用行；
- 三种格式必须描述相同策略；
- 不得修改 bootstrap 资源；
- 不得提交真实凭据、provider 二进制、生成的 plan 或本地状态文件；
- 本实验为原创练习场景，不代表官方考试题目。
