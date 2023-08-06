
## Installation
`$ sudo pacman -S terraform` 

## Ansible, Packer, Vagarnt
- Ansible: サーバー設定の自動化
- Vagrant: 仮想化環境の構築・管理・配布
- Packer: Vagrantと同様にマシンイメージを自動でビルドするツール

## Example
```
provider "aws" {
	region = "asia-northeast-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

```
$ terraform init
$ terraform plan
$ terraform apply
$ terraform destroy
```

## Related
- [Terragrunt](https://terragrunt.gruntwork.io/) 
    - Terraform wrapper
- [OPA](https://github.com/open-policy-agent/opa)
    - An open source, general-purpose policy engine
- [Packer](https://github.com/hashicorp/packer)
    - Tool for creating identical machine images for multiple platforms 
   
## MISC
- [HashiCorp Terraform Supports Amazon Linux 2](https://www.hashicorp.com/blog/hashicorp-terraform-supports-amazon-linux-2) 
