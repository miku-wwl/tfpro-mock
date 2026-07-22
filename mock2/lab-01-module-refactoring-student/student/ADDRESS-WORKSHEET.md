# Address and Ownership Worksheet

Complete this before changing state.

| Existing state | Existing address | Address kind | Final state | Final address | Baseline ID checked? |
|---|---|---|---|---|---|
| monolith | `random_pet.cohort` | ordinary | shared | `module.shared.random_pet.cohort` | yes: `shining-kingfish` |
| monolith | `aws_vpc.fabric` | ordinary | shared | `module.shared.module.shared.aws_vpc.fabric` | yes: `vpc-7fe9f32f337e09d5a` |
| monolith | `aws_subnet.zone[0]` | indexed | shared | `module.shared.module.shared.aws_subnet.segment["edge-a"]` | yes: `subnet-5de44ed9efc39835c` |
| monolith | `aws_subnet.zone[1]` | indexed | shared | `module.shared.module.shared.aws_subnet.segment["edge-b"]` | yes: `subnet-dd4b0afc72a141297` |
| monolith | `aws_security_group.tier["ops-admin"]` | keyed | shared | `module.shared.module.security.aws_security_group.tier["ops-admin"]` | yes: `sg-1002b5037b4b5ca28` |
| monolith | `aws_security_group.tier["service-core"]` | keyed with hyphen | shared | `module.shared.module.security.aws_security_group.tier["service-core"]` | yes: `sg-fa6f04d8dc56feee6` |
| monolith | `aws_security_group.tier["web-edge"]` | keyed with hyphen | shared | `module.shared.module.security.aws_security_group.tier["web-edge"]` | yes: `sg-01aaa3c442c72e551` |
| monolith | `aws_vpc_security_group_ingress_rule.path["ops-admin\|tcp\|22\|office"]` | keyed composite | shared | `module.shared.module.security.module.rule_set.aws_vpc_security_group_ingress_rule.path["ops-admin\|tcp\|22\|office"]` | yes: `sgr-4a0560f95592c76e3` |
| monolith | `aws_vpc_security_group_ingress_rule.path["ops-admin\|tcp\|443\|web-edge"]` | keyed composite | shared | `module.shared.module.security.module.rule_set.aws_vpc_security_group_ingress_rule.path["ops-admin\|tcp\|443\|web-edge"]` | yes: `sgr-233aab4aabe79aa27` |
| monolith | `aws_vpc_security_group_ingress_rule.path["service-core\|tcp\|8443\|web-edge"]` | keyed composite | shared | `module.shared.module.security.module.rule_set.aws_vpc_security_group_ingress_rule.path["service-core\|tcp\|8443\|web-edge"]` | yes: `sgr-ee706427097f4ee7b` |
| monolith | `aws_vpc_security_group_ingress_rule.path["service-core\|tcp\|9100\|ops-admin"]` | keyed composite | shared | `module.shared.module.security.module.rule_set.aws_vpc_security_group_ingress_rule.path["service-core\|tcp\|9100\|ops-admin"]` | yes: `sgr-b830c5aec9f630989` |
| monolith | `aws_vpc_security_group_ingress_rule.path["web-edge\|tcp\|443\|internet"]` | keyed composite | shared | `module.shared.module.security.module.rule_set.aws_vpc_security_group_ingress_rule.path["web-edge\|tcp\|443\|internet"]` | yes: `sgr-24c7170a40afae14c` |
| monolith | `aws_vpc_security_group_ingress_rule.path["web-edge\|tcp\|8080\|service-core"]` | keyed composite | shared | `module.shared.module.security.module.rule_set.aws_vpc_security_group_ingress_rule.path["web-edge\|tcp\|8080\|service-core"]` | yes: `sgr-b599119eae9d2c94d` |
| monolith | `aws_iam_role.workload` | ordinary | application | `module.application.aws_iam_role.workload` | yes: `harbor-grid-shining-kingfish-runtime-role` |
| monolith | `aws_iam_instance_profile.workload` | ordinary | application | `module.application.aws_iam_instance_profile.workload` | yes: `harbor-grid-shining-kingfish-runtime-profile` |
| monolith | `aws_instance.node["api-blue"]` | keyed with hyphen | application | `module.compute.aws_instance.node["api-blue"]` | yes: `i-ac712f4d6c0ca0a28` |
| monolith | `aws_instance.node["jobs-green"]` | keyed with hyphen | application | `module.compute.aws_instance.node["jobs-green"]` | yes: `i-4cc229d211a348190` |
| monolith | `aws_s3_bucket.artifact_store` | ordinary | shared | `module.shared.aws_s3_bucket.artifact_store` | yes: `harbor-grid-shining-kingfish-artifacts` |
| monolith | `aws_s3_object.seed_manifest` | ordinary | shared | `module.shared.aws_s3_object.seed_manifest` | yes: `bootstrap/manifest.json` |
| monolith | `aws_s3_bucket.state_store` | ordinary | shared | `module.shared.aws_s3_bucket.state_store` | yes: `harbor-grid-shining-kingfish-state` |

## Plan checkpoints

| Checkpoint | Adds | Changes | Destroys | Replacements | Notes |
|---|---:|---:|---:|---:|---|
| Initial monolith | 0 | 0 | 0 | 0 | Confirmed with `terraform plan`. |
| Shared root after migration |  |  |  |  |  |
| Application root after migration |  |  |  |  |  |
