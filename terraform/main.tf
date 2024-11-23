

variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

provider "aws" {
  region = "eu-central-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_instance" "web_server" {
  ami           = "ami-0b0c836a737ee51d7"
  instance_type = "t2.micro"
  user_data = <<-EOF
            #!/bin/bash
            echo "Hello Terraform!" > /var/www/html/index.html
            EOF
  timeouts {
    create = "10m"
    delete = "5m"
  }
  tags = {
    Name = "TerraformWebServer"
  }
}

output "instance_ip" {
  value = aws_instance.web_server.public_ip
}
