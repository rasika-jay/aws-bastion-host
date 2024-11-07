packer {
  required_plugins {
    amazon = {
      version = "~> 1.3"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = "~> 1.1"
      source  = "github.com/hashicorp/ansible"
    }
    goss = {
      version = "~> 3.2"
      source  = "github.com/YaleUniversity/goss"
    }
  }
}

source "amazon-ebs" "bastion" {
  ami_name      = "${var.ami_name}-{{timestamp}}"
  instance_type = "t2.nano"
  region        = var.aws_region
  ssh_username  = "ec2-user"

  # force_deregister = true
  # force_delete_snapshot = true

  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.6.20241031.0-kernel-6.1-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  vpc_filter {
    filters = {
      "tag:Name" : "main", ## todo
    }
  }

  tags = {
    Name = var.ami_name
  }

}

build {
  name = var.ami_name
  sources = [
    "source.amazon-ebs.bastion"
  ]

  provisioner "ansible" {
    playbook_file = "./provisioners/ansible/playbook.yml"
    user          = "ec2-user"
  }

  provisioner "goss" {
    tests = [
      "./provisioners/goss/goss.yml"
    ]
    goss_file = "goss.yml"
    sleep     = "2s"
  }
}


