packer {
    required_plugins {
        amazon = {
            version = ">= 1.0.0"
            source = "github.com/hashicorp/amazon"
            }
        ansible = {
            version = ">= 1.0.0"
            source = "github/hashicorp/ansible"
            }
    }
}

variable "ami_prefix" {
    default = "wp-serv"
}


variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

source "amazon-ebs" "wordpress" {
    region = var.region

    source_ami_filter {
        filters = {
            name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
            root-device-type = "ebs"
            virtualization-type = "hvm"
            }
        }

        owners = ["099720109477"]
        most_recent = true

        instance.type = var.instance_type
        ssh_username = var.ssh_username
        ami_name = "${var.ami_prefix} - ${uuidv4()}"
}

build {
    source = ["source.amazon-ebs.wordpress"]

    provisioner "shell" {
        inline = [
            "export DEBIAN_FRONTEND=noninteractive",
            "sudo add-apt-repository universe -y",
            "sudo apt-get update -y",
            "sudo apt-get install -y python3 python3-pip",
            "sudo apt-get install -y apache2 php php-mysql",
            "sudo systemctl enable apache2"
            "sudo systemctl start apache2"
            ]
        }


    provisioner "ansible" {
        playbook_file = "../ansible/playbook.yml"
        extra_arguments = ["--extra-vars", "ansible_python_interpreter=/usr/bit/python3"]
    }
}