# Lab 03 —— 数据驱动的安全组规则

## 场景

平台团队已经在 LocalStack 中运行一套小型网络。VPC、两个子网和三个安全组都已在你接手前创建完成。你的任务是修复 Terraform 配置，从 CSV、JSON 或 YAML 读取同一份规则目录，并只创建要求的入站规则。

这是原创练习题，不是 HashiCorp 官方考试题，也不复刻官方考试内容。

目标用时：45～55 分钟；难度：Terraform Professional 高级练习。

## 环境要求

- Terraform CLI 1.11.x
- Docker Desktop 和 Docker Compose
- LocalStack
- Bash 或 PowerShell

环境初始化会使用随机名称。不要在配置中硬编码生成的 AWS ID 或 CIDR。

## 初始环境

通过数据源发现现有基础设施。初始化环境会创建：

- 一个带有 `Lab = lab-03-data-driven-security`、`Role = network` 标签的 VPC；
- 两个角色分别为 `public` 和 `administration` 的子网；
- 三个角色分别为 `edge`、`ledger` 和 `control` 的安全组。

不要在练习配置中重新创建或替换这些资源。

## 任务 1：读取外部数据

定义变量 `rules_format`，允许值为 `csv`、`json`、`yaml`，默认值必须为 `csv`。

- CSV 使用 `csvdecode`；
- JSON 使用 `jsondecode`；
- YAML 使用 `yamldecode`；
- 三种格式必须进入同一条后续规则处理流程，不能为每种格式分别维护资源块。

三份目录描述的是同一组逻辑规则，但原始标量类型有意不同。

## 任务 2：规范化规则目录

创建 `local.normalized_rules`，并把每条记录统一为以下对象结构：

- `direction`
- `source`
- `destination`
- `from_port`
- `to_port`
- `protocol`
- `source_selector`
- `description`
- `enabled`

要求：

- 端口必须是 number 或 `null`；
- `enabled` 必须是 boolean；
- protocol 和 selector 的值要统一规范；
- JSON/YAML 的 `null` 与 CSV 的空字符串含义相同；
- 缺失 selector 必须保持为 `null`，不能悄悄变成有意义的空字符串；
- 不能使用输入行号作为特殊处理依据。

## 任务 3：筛选规则

只保留同时满足以下条件的记录：

- `direction == "ingress"`；
- `enabled == true`。

egress 记录和 disabled ingress 记录都不能创建资源。

## 任务 4：解析来源并创建规则

只能使用一个 `aws_vpc_security_group_ingress_rule` 资源块，并且必须使用：

- `for_each`；
- 一个或多个 `for` 表达式；
- 数据源获取 VPC、子网 CIDR 和安全组 ID。

禁止使用：

- `count`；
- 重复的资源块；
- 为每条输入记录手写一个资源；
- 将列表位置作为长期资源 key。

来源语义：

- `source == "-"` 表示通过 `source_selector` 选择 CIDR 来源；
- 其他 `source` 值表示安全组角色；
- CIDR 规则只能设置 `cidr_ipv4`；
- 安全组来源只能设置 `referenced_security_group_id`；
- 两个字段必须互斥；
- `protocol == "-1"` 时必须使用 provider 兼容的端口表示方式。

`for_each` key 必须唯一、稳定、与输入顺序无关，并区分所有决定资源身份的字段。特别是，指向 `control` 的两条 TCP/8082 规则必须拥有不同地址。

## 任务 5：输出结果

创建以下 output：

- `normalized_rules`：规范化对象 map；
- `ingress_rule_keys`；
- `rules_by_destination`；
- `rules_count_by_protocol`；
- `source_types`；
- `created_rule_ids`；
- `unique_protocols`。

这些输出应能证明：

- 指向 `control` 的两条 TCP/8082 规则都存在；
- CIDR 来源与安全组来源被分别解析；
- 三种输入格式产生相同的逻辑结果。

## Shuffle 测试

成功 apply 后，运行：

```powershell
./scripts/shuffle-input.ps1
```

或：

```bash
./scripts/shuffle-input.sh
```

脚本会打乱 CSV 行、JSON 数组和 YAML 列表。正确的实现应保持 Terraform resource address 不变，不能仅因输入顺序变化而产生 delete/create。

## 完成标准

- 格式化通过；
- 初始化成功；
- 修复后 validation 成功；
- CSV、JSON、YAML 产生等价 plan；
- 创建 15 条 enabled ingress 规则；
- 恰好两条 TCP/8082 规则指向 `control`，且来源安全组不同；
- egress 和 disabled 记录不创建任何规则；
- all-protocol 规则使用 `null` 端口；
- shuffle 测试不产生基础设施变更。

完成闭卷尝试后，再使用 Solution package 中的 `VALIDATION.md` 进行核验。
