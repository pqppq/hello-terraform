provider "aws" {
  region = "ap-northeast-1"
}

// HashiCorp Terraform Supports Amazon Linux 2
// https://www.hashicorp.com/blog/hashicorp-terraform-supports-amazon-linux-2
data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-example"
  }
}
