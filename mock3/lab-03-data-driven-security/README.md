# Lab 03：数据驱动的安全组规则

> 这是 Terraform Professional 独立练习环境，不是官方认证考试题目。

## 练习目标

本练习考察外部数据解码、数据规范化、集合类型处理、稳定资源地址、data source，以及 provider 身份边界和显式映射。

建议用时：45～55 分钟。  
难度：92～96 / 100。  
Terraform CLI：1.11.x。  
运行环境：Docker Desktop、Docker Compose、LocalStack，以及 Bash 或 PowerShell。

## 场景

平台团队已经创建了一个 VPC、两个子网和三个安全组。学生配置不得重新创建这些资源，必须通过 data source 动态发现它们，然后根据外部文件创建 ingress 规则。

同一组逻辑规则同时提供 CSV、JSON 和 YAML 三种格式。配置必须支持三种格式，并将它们送入同一条后续处理流程，不能为每种格式分别维护一套资源实现。

环境故意划分了三个 AWS 身份：

- `readonly`：发现已有网络资源；
- `rules`：创建安全组入站规则；
- `audit`：读取 provider 返回的 caller identity 信息。

仅仅能够成功执行 `terraform apply` 并不代表完成任务。provider alias 和模块映射必须符合题目要求。

## 启动环境

环境已经准备好。进入学生目录：

```powershell
Set-Location student
```

预创建资源包括：

| 资源 | 逻辑标签 |
|---|---|
| VPC | `core` |
| 公有子网 | `public` |
| 管理子网 | `administration` |
| 前端安全组 | `frontend` |
| 数据库安全组 | `datastore` |
| 运维安全组 | `operations` |

学生配置必须动态发现 VPC ID、子网 ID、子网 CIDR、安全组 ID 和 caller account ID。不得硬编码 ID、CIDR 或 provider 返回的 account ID。

## 任务 1：读取外部数据

定义变量 `rules_format`，允许的值为 `csv`、`json`、`yaml`，默认值必须是 `csv`。

要求：

- CSV 使用 `csvdecode`；
- JSON 使用 `jsondecode`；
- YAML 使用 `yamldecode`；
- 根据 `rules_format` 选择一组解码后的规则；
- 三种格式必须进入同一条后续处理流程；
- 不得为每种格式分别创建资源实现。

## 任务 2：规范化输入

创建 `local.normalized_rules`，每条规则必须具有以下逻辑字段：

```text
direction, source, destination, from_port, to_port,
protocol, source_selector, description, enabled
```

要求：端口统一转换为 `number` 或 `null`，`enabled` 统一转换为 `bool`，协议值统一规范化；三种格式必须得到等价的 Terraform 值；不得根据输入文件行号硬编码逻辑。

## 任务 3：过滤规则

只保留 `direction` 为 `ingress` 且 `enabled` 为 `true` 的规则。提供的 egress 规则和禁用的 ingress 规则都不得创建资源。

## 任务 4：使用指定身份发现基础设施

使用 `inventory` 子模块和 data source 发现所有预创建资源。

- 网络 data source 必须使用 `readonly` provider alias；
- caller identity 必须使用 `audit` provider alias；
- root 调用子模块时必须显式传入 `providers` map；
- 子模块必须通过 `configuration_aliases` 声明接收的 alias；
- 不得用默认 provider 替代指定 alias。

## 任务 5：创建安全组入站规则

实现中只能有一个 `aws_vpc_security_group_ingress_rule` 资源块。

要求：

- 使用 `for_each` 和 `for` 表达式；
- 不得使用 `count`；
- 不得为每条输入规则单独创建资源块；
- 不得使用列表索引作为长期资源 key；
- 必须通过 `rule_engine` 子模块创建规则；
- root 必须显式映射 `rules` provider alias；
- 子模块必须通过 `configuration_aliases` 声明对应 alias。

`for_each` key 必须唯一、稳定、与输入顺序无关，并能区分 source、destination、protocol、from-port 和 to-port。

来源处理规则：

- `source` 为 `-` 时，用 `source_selector` 查找子网 CIDR，并且只设置 `cidr_ipv4`；
- `source` 是安全组名称时，只设置 `referenced_security_group_id`；
- `cidr_ipv4` 与 `referenced_security_group_id` 必须互斥；
- `protocol = -1` 时，必须使用 provider 支持的端口表示方式；
- description 必须使用 `audit` provider 返回的 caller account ID，不得硬编码。

输入中有两条目标为 `operations`、协议为 TCP、端口为 `8082` 的规则。它们来源安全组不同，必须同时存在。

## 任务 6：创建输出

创建以下 output：

```text
normalized_rules
ingress_rule_keys
rules_by_destination
rules_count_by_protocol
source_types
created_rule_ids
```

`ingress_rule_keys` 必须能证明 `operations:8082` 的两条规则使用了不同且稳定的资源 key。

## 任务 7：证明地址稳定性

使用提供的 shuffle 脚本随机打乱 CSV、JSON 和 YAML 的行顺序。打乱后资源地址必须保持不变，不得仅因输入顺序改变而删除并重新创建规则，最终 plan 也必须稳定。

## 完成条件

每种输入格式都应生成 10 条有效 ingress 规则。apply 后再次 plan 应为：

```text
0 to add, 0 to change, 0 to destroy
```

## 重置环境

如需重新开始，应先确认再执行资源销毁操作。不要直接编辑 state JSON，也不要手工修改 state 内容。
