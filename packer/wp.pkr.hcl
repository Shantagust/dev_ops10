variable "aws_access_key" {
  type = string
  default = "" # Значение по умолчанию, если переменная не передана
}

variable "aws_secret_key" {
  type = string
  default = "" # Значение по умолчанию, если переменная не передана
}

# Поставщики
source "amazon-ebs" "wordpress" {
  region           = "eu-central-1"
  source_ami       = "ami-0c55b159cbfafe1f0"  # Example base AMI (Amazon Linux 2)
  instance_type    = "t2.micro"
  ami_name         = "wordpress-ami-{{timestamp}}"
  ssh_username     = "ubuntu"
  ami_description  = "AMI для WordPress"
  access_key       = var.aws_access_key
  secret_key       = var.aws_secret_key
}

# Provisioners
build "wordpress" {
  source = "amazon-ebs.wordpress"
  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
  }
}
