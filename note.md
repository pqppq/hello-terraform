
## Installation

`$ sudo pacman -S terraform` 

## Ansible, Packer, Vagarnt

- Ansible: サーバー設定の自動化
- Vagrant: 仮想化環境の構築・管理・配布
- Packer: Vagrantと同様にマシンイメージを自動でビルドするツール

## Example

```terraform
provider "aws" {
	region = "asia-northeast-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

## Variable

```
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
}
...
$ terraform plan -var "server_port=8080"
or
$ export TF_VAR_server_port=8080
$ terraform plan
```

## Commands

```
$ terraform init
$ terraform plan
$ terraform apply
$ terraform destroy
$ terraform graph
```

## State

[terraform: state](https://developer.hashicorp.com/terraform/language/state) 

`terraform.tfstate` file

```
{
  "version": 4,
  "terraform_version": "1.5.4",
  "serial": 30,
  "lineage": "648c5b54-794f-1514-cb9b-c33194b349c4",
  "outputs": {},
  "resources": [
    {
      "mode": "data",
      "type": "aws_subnets",
      "name": "default",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
  ...
```

`terraform.tfstate`ファイルにデプロイした環境のstateが保存されるときの問題点
- チーム開発しているときに状態をシェアする必要がある
- lockingしないと、同タイミングで`terraform apply`したときにコンフリクトが起きる
- development/staging/productionなど環境を切り分けるときにどう運用するか

Backend Configuration: https://developer.hashicorp.com/terraform/language/settings/backends/configuration
> A backend defines where Terraform stores its state data files.

version control via s3 bucket
[Resource: s3_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) 

```terraform
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

locking(awsだとDynamo DBのテーブルでlockを管理できる/GCPだとデフォルトでサポートされているらしい?)
[Backend/s3](https://developer.hashicorp.com/terraform/language/settings/backends/s3) 

## Isolation

workspace
```
$ terraform workspace -h
Usage: terraform [global options] workspace

  new, list, show, select and delete Terraform workspaces.

Subcommands:
    delete    Delete a workspace
    list      List Workspaces
    new       Create a new workspace
    select    Select a workspace
    show      Show the name of the current workspace
```

file layout base

example
```
/stage
/prod
/mgmt
  - an environment for DevOps tooling
/global
  - glboal resource, ex. S3, IAM
/vpc
/services
  - app or micro services to run
/data-storage
  - ex. MySQL, Redis, ...
variables.tf
outputs.tf
main.tf
```

[terraform console command](https://developer.hashicorp.com/terraform/cli/commands/console) 
> You can use it to test interpolations before using them in configurations and to interact with any values currently saved in state. 

## Modules
```terraform
module "<NAME>" {
    source = "<SOURCE>"

    [CONFIG ...]
}
```

### Gotchas

[telmpatefile FUnct](https://developer.hashicorp.com/terraform/language/functions/templatefilez) 

Path reference
- path.module
- path.root
- path.cwd

```terraform
user_data = templatefile("${path.module}/user-data.sh", {
  server_port = var.server_port,
  db_address = data.terraform_remote_state.db.outputs.address
  ...
})
```

## Tips and Tricks

```terraform
resource "aws_iam_user" "example" {
    count = 3
    name = "user.${count.index}" # -> user.1, user.2, user.3
}
```

```terraform
variable "user_names" {
  description = "Crate IAM users with these names"
  type        = list(string)
  default     = ["neo", "trinity", "morpheus"]
}

...

resource "aws_iam_user" "example" {
  count = length(var.user_names) # -> 3
  name = var.user_names[count.index] # -> "neo", "trinity", "morpheus"
}

...

output "first_arn" {
  value = aws_iam_usre.example[0].arn
  description = "The ARN for first iam user"
}

output "all_arn" {
  # shellの@的な
  value = aws_iam_usre.example[*].arn
  description = "The ARNs for all users"
}
```

count.indexはinline-blockでは使えない。

listでvariableを定義しリソースを生成した場合、たとえばaws_iam_user.exampleはリソースの配列になるので、listを変更したときに予期せぬ不具合を招くおそれがある。たとえば、["neo", "trinity", "morpheus"]を["neo", "morpheus"]に変更するとterraformは"trinity"->"morpheus", "morpheus"->"null"の変更だと認識してしまう。

[The for_each Meta-Argument](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each) 

for_eachを使うと、今度はリソースの配列からマップに変わるので意図した挙動になる。

inline-blockを動的に生成するにはfor_eachと`dynamic`を組み合わせて使う。

[dynamic Blocks](https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks) 

```terraform
dynamic "<VAR_NAME>" {
  for_each = <COLLECTION>
  
  content {
    [CONFIG...]  
  }
}
```

pythonのforっぽい構文も用意されている

[for Expressions](https://developer.hashicorp.com/terraform/language/expressions/for) 

```terraform
[for s in var.list : upper(s)]
[for i, v in var.list : "${i} is ${v}"]
{for s in var.list : s => upper(s)}
```

ディレクティブ的なものも使えるらしく`"%{ for ... }"<expression>%{ endfor }`みたいな書き方もできるっぽい。

```terraform
output "for_directive_index" {
	value = "%{ for i, name in var.user_names }(${i}) ${name}%{ endfor }"
	# => "(0) neo, (1) trinity, (2) morpheus"
}
```

terraformで条件分岐を記述するには三項演算子かifディレクティブ(とヒアドキュメント)を使う。

```terraform
output "for_directive_index_if" {
  value = <<EOF
    %{ for i, name in var.user_names }
      ${name}%{ if i < length(var.user_names) -1 }, %{ endif }
    %{ endfor }
  EOF
}
```

[The lifecycle Meta-Argument](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle) 

[Command: state mv](https://developer.hashicorp.com/terraform/cli/commands/state/mv) 
    - リソース名の変更(tfstateの書き換え)

## Secrets

[99designs/aws-vault](https://github.com/99designs/aws-vault) 

secretを使用するいくつかの方法
- variableとして定義してTF_VAR_として渡す
    - pros
        - tfファイルから手軽にsecretを取り除くことができる
    - cons
        - secretの管理がTerraformの枠組みの外になる(securityに対してTerraformは制約をかけられない)
        - secretのバージョニングが原因で問題が起こる可能性が高まる
- encrypt
    - secretを各プロバイダーのCLIなどでencryptする
        - [Data Source: aws_kms_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_secrets) 
- secret store
    - AWS Secret Manager, Google Secet Manager, HashiCorp Vault, etc

ex. encrypt(with aws kms)
```
# db-creds.yml
username: admin
password: password

data "aws_kms_secrets" "creds" {
    secret {
        name = "db"
        # Base64 encoded payload, as returned the Encryption Context for the secret
        payload = file("${path.module}/db-creds.yml.encrypted")
    }
}

locals {
    db_creds = yamldecode(data.aws_kms_secrets.creds.plaintext["db"])
}
```

### Multiple Region

```terraform
provider "aws" {
  region = "us-east-2"
  alias = "region_1"
}

data "aws_ami" "ubuntu_region_1" {
  provider = aws.region_1
  ...
}

resource "aws_instance" "region_1" {
  provider = aws.region_1

  ami = data.aws_ami.ubuntu_region_1.id
  instance_type = "t2.micro"
}
```

warning
- マルチリージョンをTerraformで管理するのは大変
    - リージョン間の遅延、可用性の設計、複数リージョンでの一意なID生成、データ規制、etc.
- aliasの多用を避ける
    - どこかのリージョンが落ちていたらterraform planの結果を実行することが出来ない(共通のmoduleを使ってる場合?)ので、障害時にインフラの変更が出来なくなってしまう(?)
    - 原則として各環境はisolatedな状態を保つように作成するべき
    - Cloud Front(とTLS証明書の設定)を使うなどの特定のケースを除けばaliasが絶対に必要なケースは少ない


[getsops/sops](https://github.com/getsops/sops) 

## Validation

```terraform
variable "instance_type" {
  description = "The type of EC2 instances to run"
  type = string

  validation {
    condition = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "Only free tier is allowed: t2.micro or t3.micro"
  }
}
```

[Input Variable Validation](https://developer.hashicorp.com/terraform/language/expressions/custom-conditions#input-variable-validation) 

- validation block
    - for basic input sanitization
- precondition block
    - for checking basic assumptions
- postcondition block
    - for enforcing basic asswguarantees

## Tests



## Related

- [Terragrunt](https://terragrunt.gruntwork.io/) 
    - Terraform wrapper
- [OPA](https://github.com/open-policy-agent/opa)
    - An open source, general-purpose policy engine
- [Packer](https://github.com/hashicorp/packer)
    - Tool for creating identical machine images for multiple platforms 
   
## MISC

- [HashiCorp Terraform Supports Amazon Linux 2](https://www.hashicorp.com/blog/hashicorp-terraform-supports-amazon-linux-2) 
- [alias: Multiple Provider Configurations](https://developer.hashicorp.com/terraform/language/providers/configuration#alias-multiple-provider-configurations) 
- [gruntwork-io/cloud-nuke](https://github.com/gruntwork-io/cloud-nuke) 
- [gruntwork-io/terratest](https://github.com/gruntwork-io/terratest) 
