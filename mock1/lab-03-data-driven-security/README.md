# Lab 03 — 数据驱动的网络策略

> 本实验是一项独立设计的 Terraform Professional 实践练习，并非官方考试题目，也不包含或复现任何官方考试内容。

## 实验目标

修复一个未完成的 Terraform 配置。该配置需要从 CSV、JSON 或 YAML 文件中读取语义相同的网络策略记录，并创建 AWS VPC 安全组入站规则，同时保证资源地址稳定。

**建议完成时间：**45–55 分钟
**难度定位：**高级 Terraform Professional 实践

## 实验环境

* Terraform CLI 1.11.x
* Docker Desktop 与 Docker Compose
* LocalStack
* Bash 或 PowerShell

初始化配置会预先创建以下基础设施，这些资源在实验开始前已经存在：

* 一个 VPC；
* 两个子网，分别代表公网网段和管理网段；
* 三个安全组，分别代表边缘服务、记录服务和控制服务。

AWS 资源的实际名称中包含随机生成的后缀。你必须通过标签及资源之间的关系发现这些资源，不得依赖自动生成的名称，也不得使用从 Terraform State 中复制出来的资源 ID。

## 学员工作目录

仅允许在 `student/` 目录中进行操作。

不得修改以下内容：

* `bootstrap/`；
* `student/data/`；
* `docker-compose.yml`；
* Provider 的服务端点配置和测试凭据配置；
* 已预先创建的 VPC、子网或安全组。

不得创建新的 VPC、子网或安全组来替代已有资源。

不得使用真实云环境凭据。

## 环境初始化

在实验根目录执行：

```bash
./scripts/setup.sh
cd student
terraform init
terraform validate
terraform plan
```

PowerShell：

```powershell
./scripts/setup.ps1
Set-Location student
terraform init
terraform validate
terraform plan
```

初始代码中包含一些刻意设置的错误。即使 `terraform validate` 执行成功，也不代表所有任务已经完成。

## 数据约定

`student/data/rules.csv`、`rules.json` 和 `rules.yaml` 表达的是同一组网络策略记录。

每条记录包含以下字段：

* `direction`
* `source`
* `destination`
* `from_port`
* `to_port`
* `protocol`
* `source_selector`
* `description`
* `enabled`

当 `source` 的值为 `-` 时，`source_selector` 用于指定一个子网的 CIDR。

其他情况下，`source` 用于指定另一个安全组。

## 任务 1 — 读取外部数据

定义变量 `rules_format`，要求如下：

* 允许的值为：`csv`、`json`、`yaml`；
* 默认值为：`csv`。

根据所选格式，只读取对应的一个文件：

* CSV 使用 `csvdecode`；
* JSON 使用 `jsondecode`；
* YAML 使用 `yamldecode`。

不得针对不同文件格式分别创建资源块，也不得为每种格式建立独立的策略处理流程。

## 任务 2 — 规范化输入数据

创建 `local.normalized_rules`，确保无论选择 CSV、JSON 还是 YAML，最终生成的 Terraform 数据结构都完全一致。

每个规范化后的对象必须包含以下字段：

* `direction`
* `source`
* `destination`
* `from_port`
* `to_port`
* `protocol`
* `source_selector`
* `description`
* `enabled`

具体要求：

* 端口必须为数字或 `null`；
* `enabled` 必须为布尔值；
* 协议名称以及方向、来源、目标等标识必须采用一致的规范化方式；
* 不得通过列表位置或硬编码行号来识别和处理任何记录。

## 任务 3 — 筛选策略记录

只有同时满足以下两个条件的记录，才可以创建资源：

* `direction` 为 `ingress`；
* `enabled` 为 `true`。

被禁用的入站规则以及出站规则，都不得出现在资源映射中。

## 任务 4 — 创建入站规则

必须且只能使用一个 `aws_vpc_security_group_ingress_rule` 资源块。

必须使用：

* `for` 表达式；
* `for_each`。

不得使用：

* `count`；
* 每条记录对应一个独立资源块；
* 列表索引作为持久化资源键。

`for_each` 的键必须满足以下要求：

* 唯一；
* 确定性；
* 不受输入顺序影响；
* 能够区分来源、目标、协议、起始端口和结束端口。

数据中有两条 `destination = "control"`、`protocol = "tcp"` 且端口为 `8082` 的规则。这两条规则必须同时存在，并且必须拥有不同的 Terraform 资源地址。

所有 VPC、subnet、subnet CIDR 和 security group ID 都必须通过 data source 查询获得。

当规则来源是 subnet CIDR（即 `source = "-"`）时，只能设置 `cidr_ipv4`。

当规则来源是 security group（例如 `source = "edge"`）时，只能设置 `referenced_security_group_id`。

`cidr_ipv4` 与 `referenced_security_group_id` 互斥，不能同时设置。

当 `protocol = "-1"` 时，必须按 AWS provider schema 处理 `from_port` 和 `to_port`；不得人为填入虚构端口。

## 任务 5 — 创建输出并验证资源地址稳定性

创建以下输出：

* `normalized_rules`
* `ingress_rule_keys`
* `rules_by_destination`
* `rules_count_by_protocol`
* `source_types`
* `created_rule_ids`

这些输出应能够用于确认以下结果：

* 一共有 10 条已启用的入站规则；
* 有两个不同来源为控制安全组创建了 TCP/8082 入站规则；
* 出站规则和被禁用的规则均已被排除；
* CSV、JSON 和 YAML 三种输入格式能够产生相同的逻辑结果。

成功执行 `apply` 后，运行输入顺序打乱脚本，然后再次生成执行计划：

```bash
../scripts/shuffle-input.sh student
terraform plan -var='rules_format=csv'
```

PowerShell：

```powershell
../scripts/shuffle-input.ps1 -Target student
terraform plan -var='rules_format=csv'
```

无论三个输入文件中的数组顺序如何调整，都不得改变 Terraform 资源地址，也不得导致已有规则被替换。

## 完成标准

完成后的提交应通过以下检查：

```bash
terraform fmt -check -recursive
terraform validate
terraform plan
```

在 LocalStack 正常运行并成功应用配置后，再次执行 `terraform plan` 时，不应报告任何资源变更。

完整的人工验证流程请参阅讲师资料包中的 `VALIDATION.md`。
