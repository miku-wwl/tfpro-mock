# Terraform Professional 闭卷模拟练习：实验 04

## 状态恢复与资源归属迁移

**建议用时：**45 分钟
**形式：**闭卷能力评估
**环境：**Terraform CLI 1.11.x、Docker Desktop、Docker Compose、LocalStack

本实验为独立编写的练习内容，不代表 HashiCorp 官方考试题目。

## 场景

平台团队在将本地 Terraform 状态迁移到 S3 后端的过程中中断了操作。底层 AWS 兼容资源仍然存在，但归属分散在旧状态地址、缺失的状态记录和未纳入管理的远端对象之间。`student/` 中提供了一份部分修订过的配置。

你必须在不替换已有基础设施的前提下恢复一份唯一权威状态。其中一个保留对象要退出 Terraform 管理，但远端对象必须保持不变；同时还要将一个新对象纳入管理。

## 实验边界

只能在 `student/` 中工作。不得修改 `bootstrap/` 或 `scripts/` 下的文件，也不得直接编辑任何 Terraform 状态 JSON。

开始前运行一次环境准备脚本：

- Bash：`./scripts/setup.sh`
- PowerShell：`./scripts/setup.ps1`

初始化过程会创建 `.lab/baseline.json`、`student/runtime.auto.tfvars.json`、`student/backend.hcl` 和可恢复的初始状态。基线用于证明资源身份，不是解决方案。

## 初始状态

实验开始时：

- LocalStack 中有两个工作负载 S3 存储桶、一个 S3 后端存储桶、两个已有对象、三个 IAM 用户、一个安全组和两条入站规则；
- `student/` 提供的本地状态只记录了其中一部分资源；
- 多条记录使用旧地址；
- 有一条过时状态记录没有对应配置；
- 后端设置存在，但没有正确指向最终要求的位置；
- 修订后的配置与已有资源存在漂移；
- `retained.txt` 当前由 Terraform 管理。

## 最终要求

### 任务 A：建立权威后端

最终状态必须存储在初始化脚本创建的已有 S3 后端存储桶中。后端 key 必须严格为：

```text
tfpro-sim/lab-04/terraform.tfstate
```

本地状态记录必须在不丢失、不重复和不重建基础设施的情况下完成迁移。最终工作目录不得再依赖本地状态作为权威状态。

### 任务 B：恢复已有基础设施的归属

最终状态必须包含以下精确地址：

```text
aws_s3_bucket.assets
aws_s3_bucket.logs
aws_iam_user.members["alpha"]
aws_iam_user.members["beta"]
aws_iam_user.members["gamma"]
aws_security_group.application
aws_vpc_security_group_ingress_rule.client_https
aws_vpc_security_group_ingress_rule.operations_https
```

两条入站规则虽然使用相同协议和端口，但必须继续分别代表两个不同的已有规则。

### 任务 C：消除旧的和过时的归属

最终状态不得包含：三个原始独立 IAM 用户地址中的任何一个、`aws_s3_bucket.primary`、原始入站规则地址，或任何仅存在于状态中的过时记录。

同一个真实远端资源不能同时由两个状态地址管理。不得通过销毁并重新创建来修正地址。

### 任务 D：释放 `retained.txt`，但不得删除

完成时：

- 没有 Terraform 资源 block 管理 `retained.txt`；
- 没有状态地址表示 `retained.txt`；
- 远端对象仍存在于 assets 存储桶中；
- 内容仍精确为 `KEEP-ME`；
- 基线中记录的身份和内容证据仍然有效。

### 任务 E：完成受管对象集合并生成报告

Assets 存储桶必须包含：

```text
key: new.txt
content: Success
```

`base.txt` 必须继续受 Terraform 管理，内容保持为 `BASE-CONTENT`。

创建并保留以下 Terraform 输出：

```text
bucket_names
iam_user_names
security_group_id
security_group_rule_ids
managed_object_keys
```

配置必须动态维护：

```text
generated/s3.txt
generated/iam-users.txt
generated/security.txt
```

文件要求：`s3.txt` 只包含两个工作负载存储桶名称，每行一个；`iam-users.txt` 只包含三个 IAM 用户名称，每行一个；`security.txt` 先写安全组 ID，再写两条入站规则 ID，每行一个。资源 ID 必须来自 Terraform 管理的值，不得硬编码，且排序必须具有确定性。

## 完成标准

所需变更应用完成后，最终 plan 必须报告 **0 to add, 0 to change, and 0 to destroy**。

以下做法均不允许：直接编辑状态 JSON；删除并重新创建已有存储桶、IAM 用户、安全组或任一已有入站规则；删除或重新创建 `retained.txt`；使用宽泛生命周期抑制规则掩盖漂移；为同一资源使用第二个状态地址；在输出或生成文件中硬编码远端资源 ID。

`.lab/baseline.json` 中记录的关键资源身份和属性必须保持不变。恢复过程中唯一允许的远端基础设施变更是创建所需的 `new.txt` 对象；已有资源的配置漂移必须在不修改远端资源的情况下解决。

## 重启实验

- 在不重建 LocalStack 容器的情况下恢复初始状态：`./scripts/corrupt-state.sh` 或 `./scripts/corrupt-state.ps1`；
- 重新创建整个隔离的 LocalStack 环境：`./scripts/reset.sh` 或 `./scripts/reset.ps1`。

两种重置方式只会破坏本实验的本地容器数据和生成的工作文件。
