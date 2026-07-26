# 实验 03：数据驱动的安全规则

> 独立的 Terraform Professional 练习材料。本实验不代表 HashiCorp 官方考试题目，也不声称复现官方题目。

## 场景

平台团队已经在 LocalStack AWS 账户中创建了一个 VPC、两个子网和三个安全组。现在，安全策略行可能来自 CSV、JSON 或 YAML。你的任务是修复初始配置，使同一套 Terraform 实现能够根据任意一种受支持的格式生成相同的安全组规则。

初始代码看似接近完成，但故意包含多个实现陷阱。仅仅让 AWS 中的结果看起来正确并不足够；资源类型、block 数量、文件归属、数据源、输出接口和稳定资源地址都会被检查。

**建议用时：**45–55 分钟
**目标难度：**Terraform Professional 92–96 / 100

## 工作边界

- 从 `bootstrap/` 执行基础设施初始化；实验期间将该目录视为只读。
- 候选代码只能修改 `student/` 下的内容。
- 候选配置必须是**仅包含根模块**的实现，不得引入子模块。
- 所有 AWS 数据源和入站规则资源都必须保留在候选根模块中。即使能够正常运行，由子模块读取或管理它们也不符合要求。
- 不得在 `student/` 中创建 VPC、子网或安全组，必须动态发现它们。
- 不得直接编辑 Terraform 状态 JSON。

## 执行约定

| 项目 | 必需约定 |
|---|---|
| Terraform CLI | `1.11.x` |
| Provider 身份 | 配置为 LocalStack endpoint 的未命名/默认 `hashicorp/aws` provider |
| 后端 | 仅使用本地后端 |
| 后端 key | **不适用于本地后端**；不得添加 S3、HCP Terraform 或其他远程后端。活动状态文件仍为工作目录中的 `terraform.tfstate`。 |
| 候选模块边界 | 仅根模块，不得有子模块 |
| 资源类型 | `aws_vpc_security_group_ingress_rule` |
| Resource block 数量 | 候选代码中恰好 1 个入站资源 block |
| 资源位置 | `student/main.tf` |
| 迭代方式 | 由 `for` 表达式提供数据的 `for_each` |
| 禁止的迭代方式 | `count`、`count.index`，或将输入列表索引作为持久 key |
| 数据源位置 | `student/data_sources.tf` |
| 规范化位置 | `student/locals.tf` |
| 输出位置 | `student/outputs.tf` |

使用其他资源类型、重复资源 block、手动声明规则，或宽泛的 `lifecycle.ignore_changes`，均不符合约定。

## 环境初始化

前置条件：

- Docker Desktop 和 Docker Compose；
- Terraform CLI 1.11.x；
- Bash 或 PowerShell；
- Python 3，用于运行 shuffle 辅助脚本。

启动 LocalStack 并创建已有资源：

```bash
./scripts/setup.sh
```

PowerShell：

```powershell
./scripts/setup.ps1
```
初始化脚本会创建一个带标签的 VPC、两个带标签的子网（角色为 `public` 和 `administration`），以及三个带标签的安全组（角色为 `frontend`、`datastore` 和 `operations`）。它们的 AWS 名称包含生成的后缀。候选代码必须使用数据源和标签，而不能使用复制的 ID 或固定名称。

## 任务 1：读取一种外部格式

在 `student/variables.tf` 中定义并保留 `variable "rules_format"`。

- 允许的值：`csv`、`json`、`yaml`；
- 默认值：`csv`；
- CSV 必须使用 `csvdecode` 解码；
- JSON 必须使用 `jsondecode` 解码；
- YAML 必须使用 `yamldecode` 解码；
- 不得复制三套资源逻辑。

`student/data/` 下的文件描述同一组策略。CSV 中的端口和布尔值以字符串形式提供；JSON 和 YAML 可能包含数字、布尔值或 `null`。

## 任务 2：发现已有网络

使用 AWS 数据源，在运行时获取：

- VPC ID；
- 两个子网的 ID 和 CIDR block；
- 三个安全组的 ID。

使用 bootstrap 标签识别资源。初始代码中包含故意设置的固定值后备方案，完成后不得保留。不得将 CLI 输出中的 ID 复制到 Terraform 代码中。

## 任务 3：规范化策略对象

在 `student/locals.tf` 中创建 `local.normalized_rules`。每个元素都必须暴露以下属性，并确保 CSV、JSON 和 YAML 的 Terraform 类型一致：

- `direction`：字符串；
- `source`：字符串；
- `destination`：字符串；
- `from_port`：数字或 `null`；
- `to_port`：数字或 `null`；
- `protocol`：字符串；
- `source_selector`：字符串；
- `description`：字符串；
- `enabled`：布尔值。

应在适当位置统一大小写，不得根据行号或当前位置对记录进行特殊处理。

## 任务 4：在创建资源前完成过滤

只有同时满足以下条件的记录才能进入资源：

- `direction == "ingress"`；
- `enabled == true`。

题目提供的数据中故意包含一条 egress 记录和一条禁用的 ingress 记录。两者都不得出现在受管资源实例中。

## 任务 5：构建稳定的规则实例

在 `student/main.tf` 中保留恰好一个 `aws_vpc_security_group_ingress_rule` block，并使用 `for_each`。

永久实例 key 必须唯一、确定性，并且与输入顺序无关。至少必须区分：

- 源身份；
- 目标；
- 协议；
- 起始端口；
- 结束端口。

有两条启用规则都指向 `operations` 安全组的 TCP 端口 `8082`，但来源安全组不同。两条规则都必须存在，并且资源地址不同。

源的处理语义：

- 当 `source == "-"` 时，使用 `source_selector` 选择已发现的子网 CIDR，只设置 `cidr_ipv4`；
- 当 `source` 命名安全组角色时，只设置 `referenced_security_group_id`；
- 对每个实例而言，`cidr_ipv4` 和 `referenced_security_group_id` 互斥；
- 对于协议 `-1`，端口参数必须按缺省值处理，而不是空字符串。

即使远端规则看起来相似，使用 `count`、多个入站资源 block、基于索引的 key 或其他安全组规则资源类型，也属于部分完成失败。

## 任务 6：生成精确输出

在 `student/outputs.tf` 中创建全部六个输出。值必须来自解码后的数据、数据源、locals 或受管资源，禁止硬编码输出内容。

| 输出名称 | 必需 Terraform 类型 |
|---|---|
| `normalized_rules` | `list(object({ direction=string, source=string, destination=string, from_port=number|null, to_port=number|null, protocol=string, source_selector=string, description=string, enabled=bool }))` |
| `ingress_rule_keys` | `list(string)`，按确定性排序 |
| `rules_by_destination` | `map(list(object(...)))`，根据启用的 ingress 规则分组 |
| `rules_count_by_protocol` | `map(number)` |
| `source_types` | `set(string)`，包含启用 ingress 规则所代表的来源类别 |
| `created_rule_ids` | `map(string)`，以永久 `for_each` key 为 key |

`ingress_rule_keys` 必须能够证明两个 `operations:8082` 规则使用了不同的 key。

## 任务 7：证明格式和顺序无关

分别对每种格式执行：

```bash
terraform -chdir=student plan -var='rules_format=csv'
terraform -chdir=student plan -var='rules_format=json'
terraform -chdir=student plan -var='rules_format=yaml'
```

正确 apply 后，三次 plan 都必须描述相同的十条启用 ingress 规则。

然后随机调整行/列表顺序：

```bash
./scripts/shuffle-input.sh
```

PowerShell：

```powershell
./scripts/shuffle-input.ps1
```

正确实现必须保持每个 `aws_vpc_security_group_ingress_rule.managed["..."]` 地址稳定。重新排序不得导致删除/创建操作，也不得产生仅由输出变化造成的漂移。

## 完成标准

完成的实验必须满足全部实现约定，而不只是远端 AWS 状态看起来正确：

- 在指定文件中恰好有一个要求的入站资源 block；
- 只使用带稳定语义 key 的 `for_each`；
- 基于数据源查找 VPC、子网、CIDR 和安全组；
- CSV、JSON 和 YAML 规范化结果等价；
- 十个启用的 ingress 实例；
- 两个来自不同源安全组的 `operations` TCP/8082 实例；
- 不存在 egress 或禁用实例；
- CIDR 与引用安全组来源参数互斥；
- 正确处理全协议规则；
- 六个输出的名称和类型均正确；
- 切换格式和打乱输入顺序后 plan 仍然干净。

完整检查流程请使用随 solution package 单独提供的 `VALIDATION.md`。本实验没有自动评分器。

## 清理环境

```bash
./scripts/reset.sh
```

PowerShell：

```powershell
./scripts/reset.ps1
```
