# Lab 02 — 多 AWS Provider 配置与安全的 State 迁移

这是一套独立编写的 Terraform Professional 实践 Lab，并非官方考试题目。

## 场景

某平台团队将日常运维职责拆分给了计算、身份和审计三个角色。现有 Terraform 配置已经进行过部分重构，但共享 AWS 配置文件、Provider 绑定关系、依赖锁定文件、S3 对象迁移流程，以及 Auto Scaling 漂移处理规则仍不完整。

LocalStack 环境中已经存在以下对象：

* 三个供命名配置文件使用的 IAM 角色；
* 一个启动模板和一个 Auto Scaling 组；
* 一个 IAM 用户；
* 一个 S3 Bucket；
* 一个 key 为 `artifact.txt` 的 S3 对象，其内容必须严格保持为 `ORIGINAL-CONTENT`。

初始化脚本会将现有资源导入起始 state。不得直接修改 `terraform.tfstate`。

## 目标时间与难度

* 目标完成时间：50–60 分钟
* 目标级别：Terraform Authoring and Operations Professional
* 预期最终结果：执行 `plan` 时不产生任何变更

## 前置条件

* Terraform CLI 1.11.x
* 已安装 Docker Compose 的 Docker Desktop
* Bash 或 PowerShell
* 本 Lab 不需要使用真实 AWS 凭证，也不允许使用真实 AWS 凭证

## 环境初始化

在 Lab 根目录中运行：

```bash
./scripts/setup.sh
```

PowerShell：

```powershell
./scripts/setup.ps1
```

初始化过程只会使用 LocalStack 测试凭证。脚本会创建远程对象，将自动生成的 Bucket 名称写入 `student/lab.auto.tfvars.json`，把现有资源导入起始 state，并将基线证据保存到 `bootstrap/baseline/`。

## 规则

* 只能修改 `student/` 目录下的内容。
* 不得修改 `bootstrap/`，也不得修改自动生成的 `student/lab.auto.tfvars.json`。
* 不得直接编辑 state JSON。
* 不得删除或重新创建现有 S3 对象。
* 不得将 Auto Scaling 组从 state 中移除。
* 不得使用范围过大的 lifecycle 忽略规则来掩盖无关变更。
* 必须保留现有的 Bucket、对象 key、对象内容、启动模板、Auto Scaling 组和 IAM 用户。

## 任务 1 — 创建共享 AWS 配置文件

创建以下两个文件，路径必须完全一致：

* `student/.aws/config`
* `student/.aws/credentials`

`config` 文件中必须且只能包含以下三个角色配置，不得添加 `default` 配置：

* `compute-operator`
* `identity-operator`
* `readonly-auditor`

每个角色配置都必须使用：

* `us-east-1` 区域；
* `json` 输出格式；
* `bootstrap/terraform output` 中显示的对应角色 ARN；
* 一个有效的 `source_profile`。

在 `student/.aws/credentials` 中使用以下仅供 LocalStack 使用的源凭证配置名称：

* `compute-seed`
* `identity-seed`
* `audit-seed`

每个源凭证配置中的 Access Key 和 Secret Key 都必须使用 LocalStack 测试值 `test` / `test`。不得添加任何真实凭证。

## 任务 2 — 修复 Provider 与模块绑定关系

根模块必须为受管操作定义且仅定义以下三个带别名的 AWS Provider 配置：

* `aws.compute`
* `aws.identity`
* `aws.readonly`

必须同时满足以下所有要求：

* compute 模块使用 `aws.compute`；
* identity 模块使用 `aws.identity`；
* storage 模块必须显式接收指定的 Provider；
* `data.aws_caller_identity.current` 使用 `aws.readonly`；
* 每个模块调用都必须显式设置 `providers` map；
* 每个子模块都必须通过 `configuration_aliases` 声明其允许接收的 Provider 别名；
* 子模块不得自行创建不受控制的默认 AWS Provider；
* 共享 config 和 credentials 路径必须正确指向任务 1 中创建的文件。

必须保留现有 LocalStack endpoint 配置，不得破坏或删除。

## 任务 3 — 升级并锁定 AWS Provider

修复 Provider 版本要求，使根模块与所有子模块使用一致、明确，并且与题目基线方案兼容的 AWS Provider 版本范围。

要求：

* 使用有明确上下界或合理边界的版本约束；
* 不得使用 `latest`；
* 不得删除 Provider 版本约束；
* 必须通过 Terraform CLI 命令更新 `.terraform.lock.hcl`；
* 执行 `terraform init -backend=false` 时不得出现版本选择冲突。

## 任务 4 — 安全迁移现有 S3 对象

该对象已经存在于远程环境中，当前由以下 state 地址跟踪：

```text
aws_s3_bucket_object.legacy_artifact
```

最终 state 地址必须变为：

```text
aws_s3_object.artifact
```

要求：

* 从配置和 state 中移除已弃用的资源类型；
* Bucket 必须保持不变；
* 对象 key `artifact.txt` 必须保持不变；
* 对象内容必须严格保持为 `ORIGINAL-CONTENT`；
* 不得删除、替换、重新创建或覆盖远程对象；
* 最终 `plan` 中不得出现针对该对象的创建、删除或替换操作。

请自行选择合适的 Terraform state 操作与 import 流程。题目不会直接提供具体命令和导入标识符。

## 任务 5 — 接受一项受控漂移

远程 Auto Scaling 组当前的期望容量为 `1`。

将配置中声明的期望容量改为 `2`，但必须保留远程实际值 `1`，同时确保 `plan` 不会针对该属性生成更新操作。

要求：

* 只能忽略 `desired_capacity`；
* 不得使用 `ignore_changes = all`；
* 不得忽略其他无关属性；
* 不得将该资源从 state 中移除。

## 完成检查

运行以下命令：

```bash
./scripts/validate.sh student
terraform -chdir=student state list
terraform -chdir=student plan -out=final.tfplan
terraform -chdir=student show -no-color final.tfplan
```

完成后的 Lab 应满足以下条件：

* 旧的 S3 state 地址已经不存在；
* `aws_s3_object.artifact` 已存在于 state 中；
* 所有模块资源仍然存在；
* 远程对象的内容和标识与基线保持一致；
* 远程 Auto Scaling 组的期望容量仍然为 `1`；
* 最终结果为零个资源新增、零个资源变更、零个资源销毁。
