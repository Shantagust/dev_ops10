variable "aws_region" {
  default = "us-west-2"
}
variable "ami_name" {
  default = "wordpress-ami-{{timestamp}}"
}

# Поставщики
source "amazon-ebs" "wordpress" {
  region           = var.aws_region
  source_ami       = "ami-0c55b159cbfafe1f0" # пример базового AMI (Amazon Linux 2)
  instance_type    = "t2.micro"
  ami_name         = var.ami_name
  ssh_username     = "ubuntu"
  ami_description  = "AMI for WordPress"
}

# Provisioners
build "wordpress" {
  source = "amazon-ebs.wordpress"

  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
  }
}
