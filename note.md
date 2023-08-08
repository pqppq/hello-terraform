
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

## Related

- [Terragrunt](https://terragrunt.gruntwork.io/) 
    - Terraform wrapper
- [OPA](https://github.com/open-policy-agent/opa)
    - An open source, general-purpose policy engine
- [Packer](https://github.com/hashicorp/packer)
    - Tool for creating identical machine images for multiple platforms 
   
## MISC

- [HashiCorp Terraform Supports Amazon Linux 2](https://www.hashicorp.com/blog/hashicorp-terraform-supports-amazon-linux-2) 
