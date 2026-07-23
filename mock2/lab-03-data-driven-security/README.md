# Lab 03 — 数据驱动的安全组规则

## 场景

平台团队已经在 LocalStack 中维护了一套基础网络环境，包括一个 VPC、两个子网和三个安全组。你的任务是读取 `CSV`、`JSON` 或 `YAML` 格式的规则目录，将数据统一转换成 Terraform 使用的结构，并且只为启用的入站规则创建资源。

这是一个原创练习实验，并非官方考试题，也不声称复现官方考试内容。

目标用时：45–55 分钟  
目标难度：Terraform Professional，92–96/100

## 环境要求

- Terraform CLI 1.11.x
- Docker Desktop 和 Docker Compose
- LocalStack
- Bash 或 PowerShell
- Python 3（仅用于打乱输入文件顺序的辅助脚本）

## 开始实验

Bash：

```bash
./scripts/setup.sh
cd student
terraform plan
```

PowerShell：

```powershell
./scripts/setup.ps1
Set-Location student
terraform plan
```

初始化配置会创建基线环境。不要在 `student/` 中重新创建 VPC、子网或安全组。

## 基线资源

环境中已经存在以下资源：

- 一个 VPC；
- 一个 `public` 子网；
- 一个 `administration` 子网；
- 一个 `frontend` 安全组；
- 一个 `datastore` 安全组；
- 一个 `operations` 安全组。

请通过 data source 查询它们的 ID 和子网 CIDR，不要硬编码初始化时生成的 ID。

## 任务 1 — 读取外部数据

定义变量 `rules_format`，允许的值为：

- `csv`
- `json`
- `yaml`

默认值必须是 `csv`。

根据变量读取 `data/` 目录下对应的文件：

- CSV 使用 `csvdecode`；
- JSON 使用 `jsondecode`；
- YAML 使用 `yamldecode`。

三种格式必须进入同一条后续规则处理流程，不要为每种格式分别创建一套安全组规则资源。

## 任务 2 — 统一输入结构

创建 `local.normalized_rules`。其中每个元素必须具有以下结构：

- `direction`
- `source`
- `destination`
- `from_port`
- `to_port`
- `protocol`
- `source_selector`
- `description`
- `enabled`

统一处理要求：

- 端口必须转换为 `number` 或 `null`；
- `enabled` 必须转换为 `bool`；
- `protocol` 和 `direction` 必须统一大小写；
- CSV、JSON 和 YAML 应产生等价的规范化结果；
- 不得针对某一行数据编写特殊处理逻辑。

## 任务 3 — 过滤规则

只保留同时满足以下条件的规则：

- `direction` 为 `ingress`；
- `enabled` 为 `true`。

因此，egress 规则和被禁用的 ingress 规则都不得创建资源。

## 任务 4 — 创建安全组规则

只能使用一个 `aws_vpc_security_group_ingress_rule` 资源块。

要求：

- 使用 `for_each` 和 `for` 表达式；
- 不得使用 `count`；
- 不得为每一行输入数据单独创建资源块；
- 不得使用输入列表的位置作为长期资源 key；
- key 必须唯一、稳定，并且与输入顺序无关；
- key 必须区分 source、destination、protocol、`from_port` 和 `to_port`；
- `operations` 上的两个 TCP/8082 规则必须同时存在，因为它们的来源安全组不同；
- 另有一条规则会与某条 TCP/8082 规则共享 source、destination 和端口，但协议为 UDP；
- 当 `source` 为 `-` 时，将 `source_selector` 解析为子网 CIDR，并且只设置 `cidr_ipv4`；
- 当 `source` 是安全组角色时，只设置 `referenced_security_group_id`；
- `cidr_ipv4` 和 `referenced_security_group_id` 必须互斥；
- 当协议为 `-1` 时，必须使用 provider 兼容的端口表示方式。

## 任务 5 — 输出结果

创建以下 output：

- `normalized_rules`
- `ingress_rule_keys`
- `rules_by_destination`
- `rules_count_by_protocol`
- `source_types`
- `created_rule_ids`

`ingress_rule_keys` 必须能够验证 `operations` 上两条 TCP/8082 规则具有不同的资源地址。

## 任务 6 — 验证资源地址稳定性

成功 apply 后，打乱三个输入文件中所有规则的顺序：

Bash：

```bash
../scripts/shuffle-input.sh
terraform plan -var='rules_format=csv'
terraform plan -var='rules_format=json'
terraform plan -var='rules_format=yaml'
```

PowerShell：

```powershell
../scripts/shuffle-input.ps1
terraform plan -var='rules_format=csv'
terraform plan -var='rules_format=json'
terraform plan -var='rules_format=yaml'
```

改变输入顺序不得改变资源地址，也不得删除或重新创建规则。三种格式最终都应收敛到无变更的 plan。

## 完成条件

完成后的结果应满足：

- 创建 10 条启用的 ingress 规则；
- 协议数量为：TCP 8 条、UDP 1 条、全协议 1 条；
- `operations` 上存在两条来源安全组不同的 TCP/8082 规则；
- 不创建 egress 规则或被禁用的规则；
- 打乱输入顺序后，资源地址不发生变化；
- apply 后最终 plan 为：`0 to add, 0 to change, 0 to destroy`。

## 重置环境

基线资源设置了 `prevent_destroy`。重置脚本会停止并删除临时 LocalStack 环境，然后只删除本地生成的 state 和缓存文件。

```bash
./scripts/reset.sh
```

```powershell
./scripts/reset.ps1
```
